# Execution Loop

### Pick The Next Batch

- A task is **ready** when it is unchecked and every task in its **Depends on** is checked
- If the next ready tasks are all marked `[P]` and share no files, run them together as one batch. Otherwise run the first ready task alone
- Never put two tasks that touch the same file in one batch, even if both are `[P]`
- Finish every task of a phase before starting the next phase

### Per Batch

1. **Check STOP blocks.** If a task has a ⛔ STOP block for "before starting", ask me with AskUserQuestion and wait. This is the only planned pause
2. **Dispatch implementers.** One fresh implementer subagent per task, all tasks of the batch at the same time. Use [implementer-brief.md](implementer-brief.md)
3. **Read each report.** Status is one of:
   - `DONE` → go to step 4
   - `NEEDS_CONTEXT` → answer from spec.md, plan.md or tasks.md and resume the same implementer. If the files don't answer it, it's a Stop Condition
   - `BLOCKED` → it's a Stop Condition
4. **Re-run done checks yourself**, one task at a time, after the whole batch finishes. Parallel tests can collide, so don't trust batch results alone
5. **Dispatch one reviewer per task.** Use [reviewer-brief.md](reviewer-brief.md). Give it the task, the diff of the task's files, and the done check output
6. **Fix rounds.** If the reviewer returns findings, resume the same implementer with them, then re-run the done check and re-review only the findings. Up to 3 rounds. After round 3 with findings still open, it's a Stop Condition
7. **Close the task.** Tick `[x]` in tasks.md and append a Progress Log line
8. If a ⛔ STOP block says "after finishing", ask me now and wait

### Stop Conditions

Stop and ask me with AskUserQuestion only when:

- a task has a ⛔ STOP block
- an implementer is `BLOCKED`, or `NEEDS_CONTEXT` the files don't answer
- a done check fails and 3 fix rounds didn't fix it
- the work needs a file outside the task's file list
- you find a gap or conflict between the code, tasks.md, plan.md and spec.md
- a step is destructive or reaches outside local dev: a schema push or migration on a non-local DB, deleting data, calling a live third-party API, changing shared config

When you stop:

- Explain what happened in 2–3 lines, with the evidence (command, output, file and line)
- Give 2–4 concrete options with your recommended option first
- If my answer changes spec.md, plan.md or tasks.md, edit those files first, log it in the Progress Log, then continue

### Model Choice

- **Implementer:** a fast model for mechanical tasks (one or two files, clear steps); a standard model for multi-file or integration tasks
- **Task reviewer:** a standard model; a stronger one for risky diffs (concurrency, auth, money, migrations)
- **Final reviewer:** the most capable model

### Progress Log

Keep it at the end of tasks.md. It is the recovery map if the session is compacted or restarted. Append one line per event, never rewrite old lines.

```markdown
## Progress Log

- Baseline: <repo> `<command>` → <N> already failing: <test names>
- T001: done · done check passed · review passed (0 fix rounds)
- T003, T004 [P]: done · done checks passed · review passed (T004: 1 fix round)
- T005: stopped · <reason> · asked me
- T005: my answer: <answer> · changed plan.md › <section>
- Final review: <N> findings · fixed · all ACs passed
```
