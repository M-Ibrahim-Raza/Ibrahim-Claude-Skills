# Open Items Instructions (Human-in-the-Loop)

### Rules

- You MUST NOT fill a gap in plan.md yourself. Add it as an open item
- You MUST ask every open item with the AskUserQuestion tool. Don't ask questions in plain chat text
- You MUST stop after each AskUserQuestion call and wait for my answers before you continue
- You MUST NOT write any task that depends on an open item until that item is closed
- Never proceed after a conflict between spec.md, plan.md and your tasks — flag it and wait
- You MUST NOT edit spec.md or plan.md while in plan mode. Approved changes are applied after I approve tasks.md
- tasks.md is complete only when every open item is closed

### What Counts As An Open Item

- A plan step too vague to split into tasks with a clear done check
- A technical decision the plan doesn't make
- A file the plan doesn't list but a task needs to touch
- An AC with no task that proves it, or a task with no AC
- A conflict between plan.md and spec.md, or between plan.md and the code today
- A value, secret, manual step or deploy that only I can provide
- Anything you would otherwise guess

### Sort Each Answer

- **Spec change**: changes behavior, scope, ACs, edge cases or user-facing copy → add to **Upstream Changes** for spec.md (and plan.md if affected)
- **Plan change**: changes how the code is built (new file, new decision, changed step) → add to **Upstream Changes** for plan.md
- **Task detail**: only changes how the work is split or ordered → update the tasks; nothing upstream changes
- If you're not sure which one it is, ask me with AskUserQuestion

### Steps

1. Read spec.md and plan.md and list every gap you would otherwise guess
2. Add each one to the **Open Items** section with status `Open`
3. Ask them with AskUserQuestion, up to 4 per call, most blocking first. Give 2–4 concrete options and put your recommended option first, marked "(Recommended)"
4. Write my answer under its item, set its status to `Closed`, sort it, and update the tasks it affects
5. If an answer raises new items, add them as `Open` and go back to step 3
6. Repeat until no item is `Open`

### Checkpoints

Stop and confirm with AskUserQuestion at each of these points, even if nothing seems unclear:

1. The task outline: IDs, titles, dependencies and `[P]` markers only, before writing the task details
2. Final approval: before calling ExitPlanMode, show the AC → task coverage table, list every Upstream Change and every task with a ⛔ STOP block. Call ExitPlanMode only when no item is `Open`. Apply upstream changes and save tasks.md only after I approve

### Upstream Changes Flow

1. During this phase, record each approved spec or plan change in the **Upstream Changes** section of the draft. Don't edit spec.md or plan.md yet
2. After I approve, apply every change **before** saving tasks.md:
   - spec.md: edit the affected sections and log each change in its **Open Questions** as a new `Closed` question with my answer, in the `/sdd-specify` format
   - plan.md: edit the affected sections and add how-only choices to **Decisions Not In The Spec**
3. Save tasks.md, then re-run the Coverage Checks

### Format

```markdown
## Open Items

### O1: <gap to resolve>
- **Status:** Open | Closed
- **Answer:** <my answer, or "—" while open>
- **Type:** Spec change | Plan change | Task detail
- **Affects:** <tasks and files this answer changes>
```

```markdown
## Upstream Changes

### U1: <short title>
- **From:** O<n>
- **File and section:** spec.md › <section> | plan.md › <section>
- **Old:** <current text, or "—" if new>
- **New:** <new text>
- **Reason:** <why the tasks need this change>
```
