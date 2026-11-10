---
name: sdd-specify
description: Runs the Specify phase of spec-driven development (SDD) — defines what a feature should do and why, asks clarifying questions with AskUserQuestion instead of assuming, and writes a testable spec.md that feeds the Plan phase. Use when the user says "/sdd-specify", "specify phase", "write a spec", "create spec.md", or starts SDD on a feature, bug fix, refactor, performance, chore, or spike task.
argument-hint: "[task or ticket] [optional: other skills or context]"
disable-model-invocation: true
---

# Specify Phase

Specify phase is the first phase of SDD where you will define specifications of a feature.

- It is the most important phase
- Use only plan mode: write the spec.md draft in the plan file and save it as spec.md only after I approve it
- In this phase, ask me clarifying questions with the AskUserQuestion tool (Human-in-the-Loop) instead of making assumptions
- If I give other skills or extra context (files, docs, links, notes) along with this one, apply the skills and read the context during this phase, and use what they provide as input for the spec; this skill still decides spec.md's sections, format, location and approval step
- In this phase, you will create spec.md
- Read [tone.md](references/tone.md) and follow its tone rules when writing spec.md
- **Output:** A `spec.md` file in `specs/<feature>/`, ready to feed into the Plan phase

## Spec Writing Instructions

- It should only describe **what** a feature should do and **why**.
- It should **describe behavior, not implementation**: it covers what the system does and leaves out how the code is organized
- It should act as source of truth: the plan, tasks, code and tests all come from it and point back to it
- It should be precise, testable and focused on one feature
- Requirements in spec.md should be **testable**: every requirement can be checked as met or not met
- It should be **written in simple natural language** but structured, using headings, numbered requirements and acceptance criteria
- Read [tone.md](references/tone.md) and follow its tone rules when writing spec.md
- It should have an Open Questions section — follow the Open Questions Instructions in [references/open-questions.md](references/open-questions.md)
- Save it as `specs/<feature>/spec.md` at the repo root, with a kebab-case feature folder name

## Open Questions Instructions (Human-in-the-Loop)

Read [references/open-questions.md](references/open-questions.md) before you start — it has the Rules, Steps, Checkpoints, and Format for open questions.

## spec.md Sections Selection Instructions

- The sections of a spec.md change with the type of task. 
- A few core sections appear in every spec; the rest depend on the work.

You should analyze the task, identify its type (feature, bug fix, refactor, performance, chore, or spike), then reason about which spec sections it actually needs and include only those — explaining briefly why each chosen section is needed and why any common section was skipped.

Read [references/spec-sections.md](references/spec-sections.md) for the common, essential, and per-task-type section lists.
