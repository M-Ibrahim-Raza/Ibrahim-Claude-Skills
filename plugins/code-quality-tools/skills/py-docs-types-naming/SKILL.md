---
name: py-docs-types-naming
description: Manual-only. Use ONLY when the user explicitly invokes /py-docs-types-naming. Applies docstring, type hint, Pydantic, and PEP 8 naming conventions to scoped Python code.
disable-model-invocation: true
argument-hint: "<files | folders | feature>"
---

1. Scope is `$ARGUMENTS`. If empty, propose files changed in this chat or `git diff` and confirm; if unclear, ask.
2. Read scoped files fully. Edit only docs, types, and names there; never change runtime or validation behavior.
3. Repo conventions (ruff/pyright config, CLAUDE.md, an existing docstring style) win. Use only syntax `requires-python` allows.
4. Reply per file: what changed, what was skipped and why, and validation fixes to consider (v1 APIs, no `extra="forbid"`, untagged unions).

## Docstrings and comments
- Every public module, class, function, and method gets a `"""` docstring; skip tests, `@override`, dunders, `__init__`.
- Summary is one imperative line ending in a period ("Return…", not "Returns…"); classes say what an instance is, exceptions what the error means.
- Google style: `Args:`, `Returns:`/`Yields:`, `Raises:` in that order. Never repeat annotated types; omit `Returns:` for `None`.
- Say what types cannot: units, ranges, side effects, edge cases, and only errors a caller can act on.
- Never put URLs, tickets, or outside references in docs or comments; name repo symbols in backticks.
- `#` comments explain why, invariants, or edge cases; never restate code. No banners, commented-out code, or stale comments.
- Every `# noqa`/`# type: ignore` names its rule and a reason (`# type: ignore[import-untyped]  # No stubs.`).

## Type hints
- Annotate every parameter and return, `-> None` included, never `self`/`cls`; annotate variables only when the value hides the type.
- Built-in generics and `|` unions with `None` last (`list[str] | None`); never `List`, `Dict`, `Optional`, `Union`.
- Accept `collections.abc` types (`Iterable`, `Mapping`), return concrete ones; `object` for "anything", `Any` only with a why comment.
- When supported: PEP 695 generics (`def f[T]`, `class C[T]`), `type X = ...` aliases, no `__future__` annotations or quoted hints.
- `Self` for own-class returns, `@override` on overrides, `Final`, `ClassVar`, `Literal`, `Protocol`, `TypeIs`, `TypedDict` where they fit.

## Pydantic v2
- Document fields with attribute docstrings and `use_attribute_docstrings=True`; `Field(description=)` only if schema text must differ, never both; no `Attributes:` on models.
- Put constraints in types (`Annotated[int, Field(ge=1)]`, `StringConstraints`, `PositiveInt`, `AwareDatetime`, `SecretStr`); reuse via `type` aliases, but keep `default`, `alias`, `description` on the field.
- No default means required; drop `Field(...)` markers. `X | None` is required-but-nullable; `X | None = None` is optional.
- `@field_validator` goes above `@classmethod`; after-model validators are instance methods returning `Self`; before validators take and return `object`; `@computed_field` needs a typed `@property`.

## Naming (PEP 8)
- `snake_case` functions, variables, modules; `PascalCase` classes and type aliases; `UPPER_SNAKE` module constants.
- Acronyms stay capitalized in classes (`HTTPError`) and lowercase elsewhere (`http_error`); never `l`, `O`, or `I` as names.
- `_` prefix for private names, including validators (`_check_dates`); exceptions end in `Error`; type params `T`, `KeyT`.
- Booleans read as questions (`is_billable`); functions start with a verb; models by direction (`TaskCreate`, `TaskUpdate`, `TaskOut`).
- Names carry domain meaning (`overdue_tasks`), never vague words like `data`, `info`, `tmp`, or `list2`.
- Renaming updates all callers; never rename DB columns, env vars, JSON/API fields (add an alias), routes, or CLI flags.

## Formats
```python
def cancel_task(task_id: TaskId, *, reason: str) -> Task:
    """Cancel a task and notify its assignee.

    Args:
        task_id: Task to cancel; cancelling twice is a no-op.
        reason: Shown to the assignee; at most 200 characters.

    Raises:
        TaskLockedError: If the task is already done.
    """
# TODO(tasks): Replace polling with a subscription once events exist.   (also FIXME)
class TaskCreate(BaseModel):
    model_config = ConfigDict(extra="forbid", use_attribute_docstrings=True)
    title: Annotated[str, Field(min_length=1, max_length=200)]
    """Short summary shown in task lists."""
```
