# Open Items Instructions (Human-in-the-Loop)

### Rules

- You MUST NOT make a technical decision the spec doesn't cover. Add it as an open item
- You MUST ask every open item with the AskUserQuestion tool. Don't ask questions in plain chat text
- You MUST stop after each AskUserQuestion call and wait for my answers before you continue
- You MUST NOT write any plan section that depends on an open item until that item is closed
- You MUST NOT change what the spec asks for on your own. A spec change needs my approval and goes through the Spec Changes flow below
- You MUST NOT edit spec.md while in plan mode. Approved spec changes are applied after I approve the plan
- plan.md is complete only when every open item is closed

### Sort Each Answer: Spec Change Or Plan Decision

- **Spec change**: the answer changes behavior, scope, acceptance criteria, edge cases, or user-facing copy. It changes **what** the feature does
- **Plan decision**: the answer only changes **how** the code is built. spec.md stays the same
- If you're not sure which one it is, ask me with AskUserQuestion

### What Counts As An Open Item

- More than one valid approach (e.g. new table vs new column, cache vs no cache)
- A new library, service, table, endpoint, env var or feature flag
- A change to shared code, a public API, or a DB schema
- Deploy order, migration, or data repair choices
- A conflict between the spec and how the code works today
- Anything you would otherwise guess

### Steps

1. After exploring the code, list every decision the plan needs that spec.md doesn't answer
2. Add each one to the **Open Items** section with status `Open`
3. Ask them with AskUserQuestion, up to 4 per call, most blocking first. Give 2–4 concrete options with their trade-offs and put your recommended option first, marked "(Recommended)". Cite the code you found as the reason
4. Write my answer under its item, set its status to `Closed`, and sort it:
   - **Spec change** → add it to **Spec Changes**
   - **Plan decision** → add it to **Decisions Not In The Spec**

   Then update the plan sections it affects
5. If an answer raises new items, add them as `Open` and go back to step 3
6. Repeat until no item is `Open`

### Checkpoints

Stop and confirm with AskUserQuestion at each of these points, even if nothing seems unclear:

1. The task type and the sections you chose for plan.md
2. The approach: Overview / Architecture, with the main alternative you rejected
3. The scope: File Structure and Out-of-Scope Boundaries
4. Final approval: before calling ExitPlanMode, summarize the architecture decisions, list every Spec Change, list every file that will change, and confirm every AC (including changed ACs) has a test. Call ExitPlanMode only when no item is `Open`. Apply spec changes and save plan.md only after I approve

### Spec Changes Flow

1. During planning, record each approved spec change in the **Spec Changes** section of the plan draft. Don't edit spec.md yet
2. After I approve the plan, apply every Spec Change to spec.md **before** saving plan.md:
   - Edit the affected spec.md sections (e.g. Acceptance Criteria, Edge Cases, Non-Goals)
   - Log each change in spec.md's **Open Questions** as a new `Closed` question with my answer, in the `/sdd-specify` format
3. Save plan.md
4. Re-read the updated spec.md. Check every AC has a test in plan.md and no plan section conflicts with it. If anything is off, stop and tell me

### Format

```markdown
## Open Items

### O1: <decision to make>
- **Status:** Open | Closed
- **Answer:** <my answer, or "—" while open>
- **Type:** Spec change | Plan decision
- **Affects:** <sections this answer changes>
```

```markdown
## Spec Changes

### S1: <short title>
- **From:** O<n>
- **spec.md section:** <section name>
- **Old:** <current spec text, or "—" if new>
- **New:** <new spec text>
- **Reason:** <why planning needs this change>
```
