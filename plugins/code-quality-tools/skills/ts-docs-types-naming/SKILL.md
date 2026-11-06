---
name: ts-docs-types-naming
description: Manual-only. Use ONLY when the user explicitly invokes /ts-docs-types-naming. Applies doc comment, type, and naming conventions to scoped TypeScript/Next.js code.
disable-model-invocation: true
argument-hint: "<files | folders | feature>"
---

1. Scope is `$ARGUMENTS`. If empty, propose files changed in this chat or `git diff` and confirm; if unclear, ask.
2. Read scoped files fully. Edit only docs, types, and names there; never change runtime behavior.
3. Conventions the repo already enforces (lint config, CLAUDE.md) win over the rules below.
4. Reply with a short list per file: what changed, and anything skipped with the reason.

## Documentation
- Add TSDoc to exports only when name and signature leave questions; summary is one plain present-tense sentence.
- Document units, side effects, thrown errors, preconditions, and auth or cache behavior types cannot show.
- Use `@param`/`@returns` only when they add meaning, never with types; `@example` for non-obvious utils.
- `@deprecated` names the replacement via `{@link}`. Link only repo symbols; never URLs, tickets, or outside references.
- Inline `//` comments explain why, invariants, or edge cases; never restate what the code does.
- Every `as`, `!`, or `@ts-expect-error` gets a short comment saying why it is safe.
- Delete or fix stale and redundant comments in scope; a wrong comment is worse than none.

## Types
- Annotate parameters and return types of exported functions; let inference type locals.
- Never annotate tRPC procedure, router, or query return types; end-to-end inference depends on them.
- Use `type` for object shapes; use `interface` only for declaration merging or library augmentation.
- Never use `any`; use `unknown` and narrow. Prefer `satisfies` or narrowing over `as`.
- No `enum`: use an `as const` object with a `(typeof X)[keyof typeof X]` union.
- Derive types from one source (`z.infer`, `RouterOutputs`, `Pick`, `Omit`); never redeclare a shape.
- Use `import type` for types; model exclusive states as unions keyed by `status` or `kind`.

## Naming
- Files and folders are kebab-case and match their main export (`task-card.tsx` → `TaskCard`); Next.js reserved files keep their names.
- Zod schemas end in `Schema` (`createTaskSchema`); their inferred types drop it (`CreateTaskInput`, `Task`).
- Query keys come only from the tRPC proxy or one `xQueries` factory; never hand-type key arrays.
- camelCase values, PascalCase types and components, UPPER_SNAKE only for fixed module-level constants.
- No `I` or `T` prefixes on types; generics are `T` or `TData`; acronyms as words (`userId`).
- Booleans read as questions (`isOpen`, `canEdit`); functions start with a verb; hooks are `useX` by purpose.
- Names carry domain meaning (`overdueTasks`), never vague words like `data`, `info`, `tmp`, or `list2`.
- Renaming an export updates all callers; never rename DB columns, env vars, routes, or procedure paths.

## Formats
```ts
// Task server actions: validate input, write through the data layer, revalidate.   (file header)
/**
 * Cancels a task and notifies its assignee.
 * @remarks Idempotent: cancelling an already-cancelled task is a no-op.
 * @param reason - Shown to the assignee; max 200 characters.
 * @throws {@link TaskLockedError} When the task is already done.
 */
// TODO(tasks): Replace polling with a subscription once events exist.   (also FIXME)
type TaskCardProps = { task: Task; onCancel?: (id: TaskId) => void };   // handler: handleCancel
export const taskRouter = router({ list, byId, create, cancel });   // mounted as `task`
type Task = RouterOutputs['task']['byId'];   // client: trpc.task.byId.queryOptions({ id })
export const taskQueries = { all: () => ['tasks'] as const, detail: (id: TaskId) => queryOptions({...}) };   // no useQuery-only wrapper hooks
export async function cancelTask(formData: FormData) {}   // actions.ts, verb-first; prop: cancelAction
export default async function Page({ params }: PageProps<'/tasks/[id]'>) {}
```
