---
name: py-loguru-logging
description: Manual-only. Use ONLY when the user explicitly invokes /py-loguru-logging. Applies Loguru structured-logging conventions (setup, levels, placement, messages, fields, context, exceptions, secrets) to scoped Python code.
disable-model-invocation: true
argument-hint: "<files | folders | feature>"
---

1. Scope is `$ARGUMENTS`. If empty, propose files changed in this chat or `git diff` and confirm; if unclear, ask.
2. Find the Loguru setup (`logger.remove/add/configure`) and repo logging rules; repo config and CLAUDE.md win over the rules below. If setup is missing or breaks Setup, propose [references/setup.py](references/setup.py) adapted to the repo; write it only on approval.
3. In scope: rewrite logs to these rules, replace `print()` and stdlib `logging` calls (`%s` → kwargs, `exc_info` → `opt(exception=True)`), and add logs at the points under Where. Change no other behavior.
4. Self-check (`grep -rnP` if no `rg`), then fix or justify each hit: `rg -nP 'print\(|\.(trace|debug|info|success|warning|error|critical|exception|log)\(f["\x27]|"[^"]*%[sdr]|diagnose=True|serialize=True|getLogger\(|@logger\.catch(?!\(.*(reraise|onerror))|str\((e|err|exc)\)' <scope>`
5. Reply per file: logs changed, added, removed; anything skipped and why.

## Setup
- Configure once at startup: `logger.remove()`, then one stdout sink writing flat JSON built in a `patcher` (not `serialize=True`); no log files in containers. Pin `loguru>=0.7.3,<0.8`.
- Always `diagnose=False` (prints local variables, secrets included), `backtrace=False`, `colorize=False`; level from `LOG_LEVEL`, upper-cased.
- Route stdlib (uvicorn, httpx, SQLAlchemy) through an `InterceptHandler`; disable `uvicorn.access` if middleware logs requests; httpx at `WARNING`. Libraries only `logger.disable("pkg")`, never `logger.add()`.

## Levels
- `CRITICAL` (as `fatal`): the process cannot continue. `ERROR`: an operation failed and nothing handled it.
- `WARNING` (as `warn`): unexpected but handled (retry, fallback, degraded). Not for normal branches.
- `SUCCESS` (as `info`): a long or multi-step job finished (import, migration, batch).
- `INFO`: a business or lifecycle event that worked. `DEBUG`: diagnostics, off in prod. `TRACE`: step-by-step, local only.
- User mistakes (validation, 4xx, wrong password) are `INFO`/`WARNING`, never `ERROR`.

## Where
- Entry-point outcome (request, job, CLI command); external calls (HTTP, DB, LLM, queue) with `duration_ms`; state changes; decision branches (fallback, skip, cache miss, retry); error boundaries. Never per item in loops, polling, or health checks. At most one `INFO`/`SUCCESS` per operation; extra detail is `DEBUG`.

## Messages
- Short constant past-tense event, sentence case, no period: `Order created`, `Payment capture failed`. No narration (`Entering foo`).
- Data goes in kwargs: `logger.info("Order created", order_id=order.id)`. No f-strings, `%`, or `+`: with kwargs, braces raise `KeyError`. Never pass user text as the message; it is formatted as a template.
- Costly debug values: `logger.opt(lazy=True).debug("Cache state: {}", lambda: dump())`, the only `{}` use.

## Fields
- snake_case IDs and measures with unit suffixes: `request_id`, `user_id`, `order_id`, `duration_ms`, `status_code`.
- Never shadow core keys `time`, `level`, `msg`, `logger`, `error`.
- Pick fields; never whole bodies, headers, DB rows, or ORM/Pydantic objects. Cap user text at ~200 chars.

## Context
- Per request or job: `with logger.contextualize(request_id=...)` once, in pure ASGI middleware (not `BaseHTTPMiddleware`) or the job entry; threads don't inherit it (use `contextvars.copy_context().run`).
- Per component: `log = logger.bind(component="billing")` at module level; `bind()` returns a new logger, so reassign it; never per line.

## Exceptions
- In `except`: `logger.exception("Payment capture failed", order_id=...)` once, at the boundary (handler, consumer, job). Outside `except`: `logger.opt(exception=err).error(...)`.
- Never log and re-raise; `raise AppError(...) from err` and let the boundary log. Never put `str(err)` in the message.
- `@logger.catch` only on entry points with `reraise=True` or `onerror=lambda _: sys.exit(1)`; on endpoints it swallows and returns `None`.
- Never log inside a sink, signal handler, or `__del__` (not re-entrant).

## Secrets and personal data
- Never log passwords, tokens, API keys, session IDs, connection strings, `Authorization`/`Cookie` headers, card/bank data, or government IDs; log `user_id`, not email or name. Exception text from DB/HTTP clients can carry DSNs or auth values; don't copy it into fields.
