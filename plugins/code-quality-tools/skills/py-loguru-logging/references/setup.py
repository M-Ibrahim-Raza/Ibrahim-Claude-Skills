"""Loguru setup template for /py-loguru-logging. Adapt, don't copy blindly.

- Adapt the module paths, names, and settings source (e.g. LOG_LEVEL via the
  repo's config module) to the repo. Keep the behavior.
- Pin `loguru>=0.7.3,<0.8`: 0.8 changes the default format and message templating.
- Needs Python 3.11+. Use `uuid.uuid7()` on 3.14+, `uuid.uuid4()` otherwise.
- Sections: (1) logs.py, (2) middleware.py (FastAPI/Starlette), (3) conftest.py.
"""

# ============================================================ (1) app/logs.py
"""Loguru setup. Call `configure_logging()` once, at import time of the app module."""

import inspect
import json
import logging
import sys
import traceback
from datetime import UTC
from typing import TYPE_CHECKING

from loguru import logger

if TYPE_CHECKING:
    from loguru import Record

_LEVEL_LABELS = {"WARNING": "warn", "CRITICAL": "fatal", "SUCCESS": "info"}
_CORE_KEYS = frozenset({"time", "level", "msg", "logger", "error"})


class InterceptHandler(logging.Handler):
    """Forward stdlib `logging` records (uvicorn, httpx, SQLAlchemy) to Loguru."""

    def emit(self, record: logging.LogRecord) -> None:
        try:
            level: str | int = logger.level(record.levelname).name
        except ValueError:
            level = record.levelno
        # Walk past logging's own frames so `logger` names the real caller.
        frame, depth = inspect.currentframe(), 0
        while frame and (depth == 0 or frame.f_code.co_filename == logging.__file__):
            frame = frame.f_back
            depth += 1
        logger.opt(depth=depth, exception=record.exc_info).log(level, record.getMessage())


def _to_json(record: "Record") -> str:
    entry: dict[str, object] = {
        "time": record["time"].astimezone(UTC).isoformat(timespec="milliseconds").replace("+00:00", "Z"),
        "level": _LEVEL_LABELS.get(record["level"].name, record["level"].name.lower()),
        "msg": record["message"],
        "logger": record["name"],
    }
    # Context fields never overwrite core keys.
    entry |= {k: v for k, v in record["extra"].items() if k not in _CORE_KEYS and k != "serialized"}
    if record["exception"] is not None:
        exc_type, exc_value, exc_tb = record["exception"]
        entry["error"] = {
            "name": exc_type.__name__ if exc_type else None,
            "message": str(exc_value),
            # Stdlib formatting: no local variable values in the stack.
            "stack": "".join(traceback.format_exception(exc_type, exc_value, exc_tb)),
        }
    return json.dumps(entry, default=str)


def _patch(record: "Record") -> None:
    # Serialize in the calling thread, while the live traceback still exists.
    record["extra"]["serialized"] = _to_json(record)


def configure_logging(*, level: str, service: str, version: str, env: str) -> None:
    """Send all logs to stdout as one flat JSON object per line.

    Args:
        level: Minimum level name such as "info"; case doesn't matter.
        service: Service name added to every line.
        version: Deployed version added to every line.
        env: Deployment environment label added to every line.
    """
    logger.remove()  # Drop Loguru's default stderr handler (else lines duplicate).
    logger.configure(extra={"service": service, "version": version, "env": env}, patcher=_patch)
    logger.add(
        sys.stdout,
        level=level.upper(),  # Loguru level names are case-sensitive.
        format=lambda _: "{extra[serialized]}\n",
        enqueue=False,  # Queued lines are lost if the process dies by signal.
        backtrace=False,
        diagnose=False,  # True prints local variable values, secrets included.
        colorize=False,  # `docker run -t` is a TTY; never emit ANSI codes.
    )
    logging.basicConfig(handlers=[InterceptHandler()], level=0, force=True)
    for name in ("uvicorn", "uvicorn.error"):
        std_logger = logging.getLogger(name)
        std_logger.handlers.clear()  # uvicorn adds its own handlers; route through Loguru.
        std_logger.propagate = True
    logging.getLogger("uvicorn.access").disabled = True  # The middleware logs requests.
    logging.getLogger("httpx").setLevel(logging.WARNING)  # It logs every request at INFO.


# ======================================================= (2) app/middleware.py
"""Request context: `request_id` on every line, one access line per request."""

import re
import time
import uuid
from http import HTTPStatus

from starlette.datastructures import Headers, MutableHeaders
from starlette.responses import PlainTextResponse
from starlette.types import ASGIApp, Message, Receive, Scope, Send

_VALID_REQUEST_ID = re.compile(r"[A-Za-z0-9._-]{1,64}")
_QUIET_PATHS = frozenset({"/health", "/health/live", "/health/ready"})


class RequestContextMiddleware:
    """Pure ASGI middleware (not BaseHTTPMiddleware) so contextvars flow to the endpoint."""

    def __init__(self, app: ASGIApp) -> None:
        self.app = app

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        incoming = Headers(scope=scope).get("x-request-id", "")
        # The header lands in every log line, so accept only a short, plain value.
        request_id = incoming if _VALID_REQUEST_ID.fullmatch(incoming) else str(uuid.uuid4())
        status_code = 0
        start = time.perf_counter()

        async def send_with_request_id(message: Message) -> None:
            nonlocal status_code
            if message["type"] == "http.response.start":
                status_code = message["status"]
                MutableHeaders(scope=message).append("x-request-id", request_id)
            await send(message)

        with logger.contextualize(request_id=request_id):
            try:
                await self.app(scope, receive, send_with_request_id)
            except Exception:
                logger.exception("Unhandled error")  # Outermost boundary: logged once, here.
                if status_code:  # Headers already sent: let the server drop the connection.
                    raise
                status_code = HTTPStatus.INTERNAL_SERVER_ERROR
                await PlainTextResponse("Internal Server Error", status_code=500)(
                    scope, receive, send_with_request_id
                )
            finally:
                if scope["path"] not in _QUIET_PATHS:
                    logger.log(
                        _level_for(status_code),
                        "Request completed",
                        req={"method": scope["method"], "path": scope["path"]},
                        res={"status_code": status_code},
                        duration_ms=round((time.perf_counter() - start) * 1000, 1),
                    )


def _level_for(status_code: int) -> str:
    if status_code >= HTTPStatus.INTERNAL_SERVER_ERROR:
        return "ERROR"
    if status_code >= HTTPStatus.BAD_REQUEST:
        return "WARNING"
    return "INFO"


# ======================================================== (3) tests/conftest.py
"""Capture log lines as parsed JSON so tests assert on fields, not strings."""

from collections.abc import Iterator

import pytest

if TYPE_CHECKING:
    from loguru import Message


@pytest.fixture
def log_records() -> Iterator[list[dict[str, object]]]:
    """Every line the code under test writes, as parsed JSON (needs configure_logging)."""
    records: list[dict[str, object]] = []

    def sink(message: "Message") -> None:
        records.append(json.loads(message.record["extra"]["serialized"]))

    handler_id = logger.add(sink, level="DEBUG")
    yield records
    logger.remove(handler_id)


# Example: a known secret must never reach the logs.
# def test_login_does_not_log_password(log_records, client):
#     client.post("/login", json={"email": "a@b.co", "password": "s3cr3t-XYZ"})
#     assert "s3cr3t-XYZ" not in json.dumps(log_records)
