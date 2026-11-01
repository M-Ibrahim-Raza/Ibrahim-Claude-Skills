# Open Questions Instructions (Human-in-the-Loop)

### Rules

- You MUST NOT make assumptions. If something is unclear, missing, or has more than one valid answer, add it as an open question
- You MUST ask every open question with the AskUserQuestion tool. Don't ask questions in plain chat text
- You MUST stop after each AskUserQuestion call and wait for my answers before you continue
- You MUST NOT write any spec section that depends on an open question until that question is closed
- spec.md is complete only when every open question is closed

### Steps

1. Read the task and list every ambiguity, missing detail, and decision you would otherwise guess
2. Add each one to the **Open Questions** section with status `Open`
3. Ask them with AskUserQuestion, up to 4 per call, most blocking first. Give 2–4 concrete options for each and put your recommended option first, marked "(Recommended)"
4. Write my answer under its question, set its status to `Closed`, and update the sections it affects
5. If an answer raises new questions, add them as `Open` and go back to step 3
6. Repeat until no question is `Open`

### Checkpoints

Stop and confirm with AskUserQuestion at each of these points, even if nothing seems unclear:

1. The task type and the sections you chose for spec.md
2. Goals and Non-Goals (the scope)
3. Final approval: call ExitPlanMode only when no question is `Open`. Save spec.md only after I approve

### Format

```markdown
## Open Questions

### Q1: <question>
- **Status:** Open | Closed
- **Answer:** <my answer, or "—" while open>
- **Affects:** <sections this answer changes>
```
