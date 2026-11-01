---
name: sdd-plan
description: Runs the Plan phase of spec-driven development (SDD) — reads an approved spec.md, explores the codebase, decides how the feature will be built, asks about every technical decision the spec doesn't cover with AskUserQuestion instead of assuming, and writes a plan.md that feeds the Tasks phase. Use when the user says "/sdd-plan", "plan phase", "write the plan", "create plan.md", or wants to plan a spec produced by /sdd-specify.
argument-hint: "[path to spec.md or feature folder]"
disable-model-invocation: true
---

# Plan Phase

Plan phase is the second phase of SDD. It turns an approved spec.md into a technical approach.

- The spec says **what** and **why**. The plan says **how**
- Use only plan mode: write the plan.md draft in the plan file and save it as plan.md only after I approve it
- Ask me about every decision the spec doesn't cover with the AskUserQuestion tool (Human-in-the-Loop) instead of making it yourself
- No code is written in this phase. Everything stays in markdown
- Read [tone.md](references/tone.md) and follow its tone rules when writing plan.md
- **Output:** A `plan.md` file saved next to its spec.md, ready to feed into the Tasks phase (tasks.md)

## Gate: Check The Spec First

1. Find the spec. Use the argument if given. Otherwise list the folders under `specs/` and ask me which one with AskUserQuestion
2. Read spec.md fully, plus `CLAUDE.md` (if present) and the `best_practices/` files that apply (`react.md`, `typescript.md`)
3. Stop and tell me to finish `/sdd-specify` first if:
   - any Open Question in spec.md still has status `Open`, or
   - spec.md has no Acceptance Criteria
4. Note the spec's task type (feature, bug fix, refactor, performance, chore, or spike). It decides the plan sections

## Explore Before Planning

- Read the code the spec touches before deciding anything. Use Explore subagents for wide searches
- If the app has no code yet for this area, say so and base decisions on `best_practices/`
- Find existing patterns to reuse: similar features, helpers, test setup, naming
- Record what you found as evidence (file paths and line numbers), not as memory

## Plan Writing Instructions

- It describes **how** the spec will be built. It doesn't change **what** the spec asks for
- Every plan decision must trace back to a requirement or acceptance criterion in spec.md
- If planning shows a gap or mistake in the spec, stop and ask me. An approved fix is a **Spec Change**: record it in the plan draft and apply it to spec.md after I approve, before saving plan.md (see the Spec Changes Flow in [references/open-items.md](references/open-items.md))
- Never proceed after a conflict between spec.md and your plan — flag it and wait
- Use exact file paths, function and type signatures, test names, and the command to run with its expected result
- Use code blocks only for contracts: schemas, API request/response shapes, type and function signatures. No full implementation code
- You MUST NOT include implementation detail that will cause the plan to decay
- Code comments and code documentation must not mention ACs, requirement IDs or spec details. This applies to code blocks in plan.md, and plan.md must state it as a rule for implementation
- **Implementation Order** is a short ordered list of steps with explicit dependencies and the AC each step covers. Don't break it into atomic tasks or checkboxes; that is the Tasks phase's job
- **Testing Strategy** must map every acceptance criterion in spec.md to at least one test. An AC with no test means the plan isn't done
- List every how-only decision the plan makes that the spec doesn't state in a **Decisions Not In The Spec** section. Each one must be confirmed by me. These stay in plan.md and don't change spec.md
- Keep plan.md focused on one spec. Don't plan work the spec lists as a Non-Goal

## Open Items Instructions (Human-in-the-Loop)

Read [references/open-items.md](references/open-items.md) before you start — it has the Rules, Steps, Checkpoints, and Format for open items.

## plan.md Sections Selection Instructions

- The sections of a plan.md change with the task type
- A few core sections appear in every plan; the rest depend on the work

Use the spec's task type, then reason about which plan sections the work actually needs and include only those — explaining briefly why each chosen section is needed and why any common section was skipped.

Read [references/plan-sections.md](references/plan-sections.md) for the common, essential, and per-task-type section lists.

## After Approval

1. Apply every **Spec Change** to spec.md first (see the Spec Changes Flow in [references/open-items.md](references/open-items.md))
2. Save plan.md in the same folder as spec.md
3. Re-check that every AC in the updated spec.md has a test in plan.md and nothing conflicts. If not, stop and tell me
4. Tell me the next step: run `/sdd-tasks` on plan.md **in this same session**, then implement in a **fresh session** that reads spec.md and plan.md with no memory of this discussion
