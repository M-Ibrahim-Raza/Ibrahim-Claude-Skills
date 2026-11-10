---
name: sdd-implement
description: Runs the Implement phase of spec-driven development (SDD) — reads approved spec.md, plan.md and tasks.md in a fresh session, runs each task with a fresh implementer subagent, reviews each task with a reviewer subagent, runs [P] tasks in parallel, tracks progress in tasks.md, and stops only when it truly needs the user. Use when the user says "/sdd-implement", "implement phase", "run the tasks", or "implement tasks.md".
argument-hint: "[path to tasks.md or feature folder] [optional: agents or skills for context]"
disable-model-invocation: true
---

# Implement Phase

Implement phase is the fourth phase of SDD. It turns an approved tasks.md into working, tested code.

- Run it in a **fresh session**, not the one that ran `/sdd-plan` and `/sdd-tasks`. It reads spec.md, plan.md and tasks.md as documents, with no memory of the discussion behind them
- You are the **coordinator**. Implementer subagents write the code, reviewer subagents check it. Keep your own context for tracking and decisions
- spec.md is the source of truth. plan.md explains how; tasks.md says what to do next
- Run tasks one after another without asking me between them. Stop only for the reasons in **Stop Conditions**
- **Output:** code changes in the repo, every task checked `[x]` in tasks.md, and an Implementation Summary in chat. Nothing is committed

## Gate: Check Before Starting

1. Find the feature folder. Use the argument if given. Otherwise list the folders under `specs/` that have a tasks.md and ask me which one with AskUserQuestion
2. If this session ran `/sdd-plan` or `/sdd-tasks`, tell me to open a fresh session and ask with AskUserQuestion whether to continue anyway
3. Read spec.md, plan.md and tasks.md fully, plus `CLAUDE.md` (if present) and the `best_practices/` files that apply (`react.md`, `typescript.md`)
4. Stop and send me back to `/sdd-tasks` if tasks.md has an `Open` item or an Upstream Change that isn't in spec.md or plan.md yet
5. Check the repo:
   - If it isn't a git repo, stop and ask me. Reviews and resume both rely on `git diff`
   - If the branch is `main`, stop and ask me
   - If files the tasks touch already have uncommitted changes, stop and ask me
6. **Resume, don't redo.** Tasks checked `[x]` are done. Read the **Progress Log** in tasks.md and `git diff` and start at the first unchecked task. Trust the files over your memory
7. Run the done check commands of the first tasks once as a **baseline**, and record tests that already fail in the Progress Log so they are not blamed on this work

## Execution

Read [references/execution-loop.md](references/execution-loop.md) before the first task — it has the loop, parallel rules, review and fix rounds, stop conditions and the Progress Log format.

- Brief every implementer with [references/implementer-brief.md](references/implementer-brief.md)
- Brief every reviewer with [references/reviewer-brief.md](references/reviewer-brief.md)
- Build each brief from the files. Never pass this session's history to a subagent
- If I give other agents or skills along with this one, use them for context on tools, skills, best practices and implementation: name the skills that fit a task in its implementer and reviewer briefs so the subagent loads them, and use a given agent as the implementer or reviewer subagent where it fits, briefed the same way. spec.md, plan.md, tasks.md and the Rules below still win on any conflict

## Rules

- Never commit, push, merge or deploy. I commit when I choose
- Touch only the files the task lists. A needed file outside that list is a Stop Condition
- Never skip, delete or weaken tests (`.skip`, `.only`, `xit`, commented-out asserts, loosened expectations)
- Code comments and code documentation must not mention ACs, requirement IDs or spec details
- Never mark a task `[x]` until its done check passes and its review passes
- Never change spec.md, plan.md or tasks.md on your own. You may only tick checkboxes, append to the Progress Log and fill the AC Coverage table in tasks.md. Any other change needs my approval first
- Never work around a failure or a spec conflict silently

## Finish

1. After the last task, dispatch one **final reviewer** subagent on the whole diff, against every AC in spec.md and the plan.md File Structure (see [references/reviewer-brief.md](references/reviewer-brief.md)). Use the most capable model
2. Send its findings to one fix round, then run the affected done checks again
3. Fill the AC Coverage table in tasks.md with the real results
4. Write the **Implementation Summary** in chat:
   - tasks done, and any task still open with the reason
   - AC → result table
   - every decision or approved change made during implementation
   - files changed, and baseline failures that are still failing
5. Tell me the next step: review the diff and commit, then run the Validate phase in a fresh session, then run `/update-app-docs`
