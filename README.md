# sdd-toolkit

A Claude Code plugin for spec-driven development (SDD): a four-phase workflow that turns a feature
idea into an approved spec, a technical plan, an ordered task list, and verified implementation —
with a human checkpoint between each phase.

## Workflow

```
/sdd-specify  →  /sdd-plan  →  /sdd-tasks  →  /sdd-implement
   spec.md         plan.md       tasks.md      shipped code
```

| Skill | What it does |
|---|---|
| `/sdd-specify` | Defines what a feature should do and why. Asks clarifying questions and writes a testable `spec.md`. |
| `/sdd-plan` | Reads the approved `spec.md`, explores the codebase, and decides the technical approach. Asks about every decision the spec doesn't cover instead of assuming. Writes `plan.md`. |
| `/sdd-tasks` | Reads the approved `spec.md` + `plan.md` and breaks the plan into small, ordered, independently verifiable tasks. Writes `tasks.md`. |
| `/sdd-implement` | Reads `spec.md` / `plan.md` / `tasks.md` and executes each task through a fresh implementer subagent, reviewed by a reviewer subagent, running independent tasks in parallel. Tracks progress and only stops when it genuinely needs you. |

Each phase is slash-command-only (no automatic triggering), so it only runs when you ask for it.

## Install

```
/plugin marketplace add M-Ibrahim-Raza/sdd-toolkit
/plugin install sdd-toolkit@sdd-toolkit
```

## License

No explicit license is attached to this repository.
