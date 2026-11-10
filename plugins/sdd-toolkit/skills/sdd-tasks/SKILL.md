---
name: sdd-tasks
description: Runs the Tasks phase of spec-driven development (SDD) — reads an approved spec.md and plan.md, breaks the plan into small, ordered, verifiable tasks with dependencies, AC links and done checks, asks about every gap with AskUserQuestion instead of assuming, and writes a tasks.md that feeds the Implement phase. Use when the user says "/sdd-tasks", "tasks phase", "break the plan into tasks", or "create tasks.md".
argument-hint: "[path to plan.md or feature folder] [optional: agents or skills for context]"
disable-model-invocation: true
---

# Tasks Phase

Tasks phase is the third phase of SDD. It breaks an approved plan.md into an ordered list of small tasks that the Implement phase runs one by one.

- The spec says **what**. The plan says **how**. The tasks say **what to do next, in what order**
- Run this phase in the **same session** as `/sdd-plan`. Reuse what planning already explored and decided instead of exploring the code again
  - The saved spec.md and plan.md are still the source of truth. If the session context disagrees with them, follow the files and flag it
  - If this session didn't run `/sdd-plan`, tell me and ask with AskUserQuestion whether to continue here or go back to the planning session
- Implementation is the only phase that runs in a fresh session
- Use only plan mode: switch back to plan mode first if planning's approval took you out of it. Write the tasks.md draft in the plan file and save it as tasks.md only after I approve it
- Ask me about every gap with the AskUserQuestion tool (Human-in-the-Loop) instead of filling it yourself
- No code is written in this phase. Everything stays in markdown
- Read [tone.md](references/tone.md) and follow its tone rules when writing tasks.md
- **Output:** A `tasks.md` file saved next to spec.md and plan.md, ready for the Implement phase

## Gate: Check The Plan First

1. Find the feature folder. Use the argument if given. Otherwise list the folders under `specs/` that have a plan.md and ask me which one with AskUserQuestion
2. Read spec.md and plan.md fully, plus `CLAUDE.md` (if present) and the `best_practices/` files the plan relies on
3. Stop and tell me to finish the earlier phase first if:
   - there is no plan.md, or any Open Item in plan.md is still `Open` → `/sdd-plan`
   - any Open Question in spec.md is still `Open` → `/sdd-specify`
   - a Spec Change listed in plan.md is not in spec.md yet → `/sdd-plan`
4. Check that every file plan.md marks as "modify" still exists. If one is missing or moved, flag it and wait

## Task Writing Instructions

- Tasks come only from plan.md. Don't add work the plan doesn't have, and don't make new technical decisions
- If I give other agents or skills along with this one, run them during this phase to gather context on tools, skills, best practices and implementation (e.g. exact commands, test setup), and use it to write clearer tasks; they don't add work or technical decisions that plan.md doesn't have, and this skill still decides tasks.md's format, location and approval step
- Every task must trace to at least one plan step and one acceptance criterion in spec.md. A task with no AC may be out of scope; ask me
- Each task is **atomic**: one concern, about one commit's worth of work, and it touches only the files it lists
- Each task is **self-contained**: a fresh subagent can do it from tasks.md, plan.md and spec.md without guessing what other tasks do
- Each task is **verifiable**: it ends with a done check, a command and its expected result
- Follow the plan's Implementation Order. The first task depends on the task type (see [references/tasks-format.md](references/tasks-format.md))
- Write test-first steps: write the failing test → run it, expect fail → implement → run it, expect pass
- Use exact file paths, the signatures from plan.md, test names, and commands with expected output. No implementation code
- You MUST NOT include implementation detail that will cause the tasks to decay. Point to the plan.md section instead of copying it
- Code comments and code documentation must not mention ACs, requirement IDs or spec details. tasks.md must state this as an execution rule
- Mark tasks that can run in parallel with `[P]`. Two tasks that touch the same file are never `[P]`
- Tasks don't commit. Don't add commit steps or commit messages
- Add a task-level ⛔ STOP block only when the task needs something from me (a value, a secret, a manual step, a deploy). Implementation runs without stopping between tasks, so keep STOP blocks to what truly needs me
- End with a final verification task: run lint, type-check and the full test suite, and check every AC

## Coverage Checks

Before asking for approval, check all of these and fix any gap:

- Every step in plan.md's Implementation Order maps to at least one task
- Every AC in spec.md is proven by at least one task's done check
- Every file in plan.md's File Structure is touched by at least one task
- No task touches a file outside plan.md's File Structure or inside its Out-of-Scope Boundaries
- No task depends on a task that comes after it

## Open Items Instructions (Human-in-the-Loop)

Read [references/open-items.md](references/open-items.md) before you start — it has the Rules, Steps, Checkpoints, and Format for open items and for changes to plan.md or spec.md.

## tasks.md Format

Read [references/tasks-format.md](references/tasks-format.md) for the tasks.md template, the task fields, and the ordering rules.

## After Approval

1. Apply every approved Upstream Change to spec.md and plan.md first (see [references/open-items.md](references/open-items.md))
2. Save tasks.md in the same folder as spec.md and plan.md
3. Re-run the Coverage Checks against the updated files. If anything is off, stop and tell me
4. Tell me the next step: run `/sdd-implement` in a **fresh session** that reads spec.md, plan.md and tasks.md, with one subagent per task, starting from the first unchecked task
