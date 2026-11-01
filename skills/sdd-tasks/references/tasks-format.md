# tasks.md Format

### Task Fields

- **ID and title**: `T001`, `T002`, … plus one clear action, e.g. "Add `Booking` model to the schema"
- **`[P]`**: only when the task can run alongside others (no shared files, no dependency between them)
- **Depends on**: task IDs that must finish first, or `—`
- **Covers**: AC IDs from spec.md and the plan.md step or section it comes from
- **Files**: exact paths, each marked `create`, `modify` or `test`
- **Steps**: short numbered actions with exact commands and expected results. No implementation code
- **Done check**: the command that proves the task is finished, and its expected result
- **⛔ STOP** (only if needed): what I must provide or confirm before or after the task

### Ordering Rules

Group tasks into phases in this order, and follow plan.md's Implementation Order inside each phase:

1. **Setup**: config, dependencies, schema, migrations
2. **Tests first**: failing tests for the ACs
3. **Core**: models → services → endpoints → UI
4. **Integration**: wiring parts together across modules
5. **Polish**: cleanup, docs the plan asks for
6. **Verification**: full test suites and an AC-by-AC check

### First Task By Task Type

- **Feature**: data models and schema
- **Bug**: a failing regression test
- **Refactor**: safety-net tests
- **Performance**: a baseline benchmark
- **Chore**: mapping the breaking changes
- **Spike**: defining the evaluation criteria

### Template

````markdown
# <Feature name> Tasks

**Spec:** `<path>/spec.md`
**Plan:** `<path>/plan.md`

## Execution Rules

- Run tasks in order. Start each task only when everything in its **Depends on** is checked
- One fresh subagent per task. It reads spec.md, plan.md and its task before starting
- Touch only the files the task lists
- Run tasks one after another without waiting for my approval between them
- Stop and ask me only when:
  - a task has a ⛔ STOP block
  - a step or done check fails and the fix isn't clear from the task, plan.md or spec.md
  - you find a gap or conflict that tasks.md, plan.md and spec.md don't answer
- Never skip a task or work around a failure
- Don't skip, delete or weaken tests (`.skip`, `.only`, `xit`, commented-out asserts)
- Code comments and code documentation must not mention ACs, requirement IDs or spec details
- Don't commit. I commit when I choose
- Mark a task `[x]` only after its done check passes

## Phase 1: Setup

### - [ ] T001: <action>
- **Depends on:** —
- **Covers:** AC1, AC2 · plan.md › Data Models
- **Files:**
  - modify `<path>`
- **Steps:**
  1. <action> (see plan.md › <section>)
  2. Run `<command>` → expect `<result>`
- **Done check:** `<command>` → `<expected result>`

### - [ ] T002 [P]: <action>
...

### ⛔ STOP block (only when the task needs me)

```markdown
- **⛔ STOP — before starting:** confirm <value / secret / manual step>
- **⛔ STOP — after finishing:** <manual check or deploy I must do>
```

## Phase 6: Verification

### - [ ] T0NN: Verify all acceptance criteria
- **Depends on:** all tasks
- **Steps:**
  1. Run the `lint`, type-check (`tsc --noEmit`) and `test` scripts in `package.json` → expect all pass
  2. Fill the coverage table below with the result of each check

## AC Coverage

| AC | Task(s) | Done check | Result |
|---|---|---|---|
| AC1 | T001, T004 | `<command>` | — |

## Open Items

## Upstream Changes
````
