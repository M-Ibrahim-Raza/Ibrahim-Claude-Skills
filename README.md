# Ibrahim-Claude-Skills

A Claude Code plugin marketplace. Each plugin lives in its own folder under [`plugins/`](plugins/),
with its own `.claude-plugin/plugin.json`, so more plugins can be added here over time without
touching the ones already installed from this marketplace.

## Add this marketplace

One-time step, then install any plugin listed below:

```
/plugin marketplace add M-Ibrahim-Raza/Ibrahim-Claude-Skills
```

## Plugins

### [`sdd-toolkit`](plugins/sdd-toolkit/)

A four-phase spec-driven development (SDD) workflow that turns a feature idea into an approved
spec, a technical plan, an ordered task list, and verified implementation — with a human checkpoint
between each phase.

#### Workflow

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

#### Install

```
/plugin install sdd-toolkit@ibrahim-claude-skills
```

### [`update-app-docs`](plugins/update-app-docs/)

Keeps a project's `docs/` folder in sync with what actually ships. Finds the docs a feature should
update, proposes the exact edit, and waits for approval before writing anything. It edits docs
only — it never changes code, opens tickets, or commits.

#### Install

```
/plugin install update-app-docs@ibrahim-claude-skills
```

### [`obsidian-notes`](plugins/obsidian-notes/)

Skills for maintaining an Obsidian vault, built around Mermaid diagrams and Obsidian's wikilink
behavior.

| Skill | What it does |
|---|---|
| `/add-diagram` | Adds one Mermaid diagram to a note in a single turn, picking a relationship map or a process flow based on what the note actually says, and wires it so Obsidian's links render correctly. |
| `/place-content` | Places a given point into the single most suitable **existing** note. Never creates a new file — says so and stops if nothing fits. |
| `/search-and-add-concept` | Two turns: search the web and explain a concept in chat, then (on request) add the refined content to the best note, creating a new one if needed. |

#### Install

```
/plugin install obsidian-notes@ibrahim-claude-skills
```

## License

No explicit license is attached to this repository.
