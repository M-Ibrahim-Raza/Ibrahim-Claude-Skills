---
name: ts-pino-logging
description: Manual-only. Use ONLY when the user explicitly invokes /ts-pino-logging. Applies Pino structured-logging conventions (levels, messages, fields, child loggers, errors, redaction) to scoped TypeScript/Next.js server code.
disable-model-invocation: true
argument-hint: "<files | folders | feature>"
---

1. Scope is `$ARGUMENTS`. If empty, propose files changed in this chat or `git diff` and confirm; if unclear, ask.
2. Find the repo's Pino logger and its config (errorKey, redact, field case, an AsyncLocalStorage `getLogger()`); repo config and CLAUDE.md win over the rules below. If no logger exists, stop and propose a minimal `server-only` one following these rules; write it only on approval.
3. In scope: rewrite logs to these rules, replace server `console.*`, and add missing logs only at error boundaries, external calls, and state changes. Change no other behavior.
4. Reply per file: logs changed, added, removed; anything skipped and why.

## Levels
- `fatal`: the process cannot continue.
- `error`: an operation failed and nothing handled it.
- `warn`: unexpected but handled (retry, fallback, degraded).
- `info`: one business or lifecycle event per operation.
- `debug`: diagnostic detail, off in prod.
- `trace`: not used.
- User mistakes (validation, wrong password, 4xx) are `info`/`warn`, never `error`. Never log health checks, polling, or per-item loops.

## Messages
- Short constant past-tense event, sentence case, no period: `Order created`, `Payment failed`.
- One line per event; no narration (`Entering createOrder`) or duplicates.
- Variable data goes in fields, never the string: no template literals, concatenation, or `JSON.stringify`.
- Guard costly debug data with `log.isLevelEnabled('debug')`.

## Fields
- camelCase IDs and measures with unit suffixes: `orderId`, `userId`, `durationMs`, `statusCode`.
- Pick explicit keys; never pass an untrusted object as the first arg (its keys can overwrite `msg`/`level`).
- Never log whole request/response bodies, headers, DB rows, or query strings.
- Cap user-supplied text you must log (about 200 chars); it is data, never a template.

## Context
- Per module: `const log = logger.child({ module: 'billing' })` at top level.
- Per request, action, or job: `log.child({ requestId, userId })` once, then pass it down; use the repo's ALS `getLogger()` if one exists.
- Never call `child()` per log line.

## Errors
- `log.error({ err, orderId }, 'Payment failed')`. Never `log.error('Payment failed', err)` (Pino drops `err`) or `err.message` in the message.
- Log once where the error is handled; when rethrowing, wrap with `{ cause: err }` and do not log.
- Uncaught server errors: export `onRequestError` from `instrumentation.ts` and log `{ err, digest, routePath, routeType }` once there.

## Secrets and personal data
- Never log passwords, tokens, API keys, secrets, `authorization`/`cookie` headers, card/CVV/IBAN/account numbers, IP, or date of birth; log `userId`, not email or name.
- The logger's `redact` must list each key at root and one level deep (`password`, `*.password`): `*` matches one level, paths are case-sensitive. Redaction matches keys only, so never put these values in messages.

## Next.js runtime
- Logger module starts with `import 'server-only'`; no Pino in Client Components or Edge code; leave client `console.*` unless a browser logger exists.
- Prod writes JSON to stdout with no transport; `pino-pretty` dev only. Guard Node imports in `instrumentation.ts` with `process.env.NEXT_RUNTIME === 'nodejs'`.
