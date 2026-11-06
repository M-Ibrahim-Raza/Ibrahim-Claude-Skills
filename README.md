# Ibrahim-Claude-Skills

A Claude Code plugin marketplace. Each plugin lives in its own folder under [`plugins/`](plugins/),
with its own `.claude-plugin/plugin.json`, so more plugins can be added here over time without
touching the ones already installed from this marketplace.

## Add this marketplace

One-time step, then install any plugin listed below:

```
/plugin marketplace add M-Ibrahim-Raza/Ibrahim-Claude-Skills
```

New here? [SETUP.md](SETUP.md) covers scopes, shell installs, updating, and what each plugin needs first.

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

### [`communication-tools`](plugins/communication-tools/)

Skills for writing, rewriting, and formatting messages in a clear, human voice, and for coaching you to write them yourself.

| Skill | What it does |
|---|---|
| `/write-naturally` | Rewrites or drafts content so it sounds simple, clear, and natural — not robotic or AI-generated. |
| `/rewrite-for-slack` | Rewrites a message into a short, simple, casual Slack tone, then runs it through `/format-slack-message`. |
| `/message-clarity-coach` | Coaches you to improve your own message — quotes the exact problem, explains why it matters, and shows a direction — without rewriting it for you. |
| `/format-slack-message` | Formats a given message for Slack — bolds key terms, backticks code-like tokens, linkifies bare URLs — without changing a single word. |
| `/format-clickup-message` | Formats a given message for ClickUp — bolds key terms and backticks code-like tokens and named message types — without changing a single word. |

#### Install

```
/plugin install communication-tools@ibrahim-claude-skills
```

### [`git-tools`](plugins/git-tools/)

Skills for git workflow tasks.

| Skill | What it does |
|---|---|
| `/commit` | Writes and creates git commits following best practices — atomic, Conventional Commits, no AI attribution. |
| `/push-branch` | Pushes the current branch to origin safely — refuses protected branches, sets upstream, stops on divergence, and force-pushes only with `--force-with-lease` when asked. |
| `/open-pr` | Opens a GitHub PR for the current branch with `gh` — self-reviews the diff, drafts a clear title and description (using the repo's PR template if present), and confirms before creating. |
| `/merge-pr` | Merges a GitHub PR with `gh`. It checks that the PR is open, approved, conflict-free and green, then asks you for the merge method (normal merge by default) and whether to delete the branch before merging. |
| `/switch-branch` | Switches the current repo to a given branch (creating it if it does not exist), stashing and restoring any local changes, pulling the latest from origin. |
| `/cherry-pick-branch` | Cherry-picks a QA'd feature branch's commits onto a fresh branch off the production branch, ready to open a PR from. |

#### Install

```
/plugin install git-tools@ibrahim-claude-skills
```

### [`prompt-tools`](plugins/prompt-tools/)

Skills for restructuring prompts for coding agents and editing existing prompts without breaking their instructions.

| Skill | What it does |
|---|---|
| `/prompt-optimizer-for-code` | Rewrites a rough prompt into clean, structured markdown for a coding agent. Reorders and reformats only, never adds requirements or drops details. |
| `/prompt-instruction-editor` | Adds, clarifies, or changes only the instructions a change request touches, leaves every other line untouched, and shows a diff to prove it. Flags conflicts with existing rules instead of quietly editing them. |

#### Install

```
/plugin install prompt-tools@ibrahim-claude-skills
```

### [`learning-tools`](plugins/learning-tools/)

Skills for learning concepts with Claude as a tutor that finds where you're stuck and guides you to the answer instead of handing it over.

| Skill | What it does |
|---|---|
| `/learn` | Tutors you through a concept. It first finds where you're stuck, then moves you forward one step per turn with hints, worked parallel examples, and quick checks, instead of handing over the answer. It makes flashcards, quizzes, and study guides when you ask for them. |

#### Install

```
/plugin install learning-tools@ibrahim-claude-skills
```

### [`stack-tools`](plugins/stack-tools/)

Skills for mapping your app's tech stack into a stack file from what the code actually uses, and for researching, comparing, and choosing new tools to add to it.

```
/tech-stack-mapper  →  /tech-picker
  tech_stack.md         a new tool, recorded in tech_stack.md
```

| Skill | What it does |
|---|---|
| `/tech-stack-mapper` | Scans your codebase (manifests, lockfiles, config, and imports) and builds a stack file grouped by domain. It lists only tools that are installed and actually used, with exact lockfile versions. It never guesses why a tool was chosen. It shows you the draft and writes the file only after you accept it. On an existing file, it adds missing tools and leaves your entries alone. |
| `/tech-picker` | Picks a library, framework, or service for one need in your app. It reads your tech stack file and manifests, asks only the questions that change the answer, and researches current options on the web. Then it compares them in a table and recommends one. After you choose, it adds the tool to your stack file in the file's existing format. |

#### Install

```
/plugin install stack-tools@ibrahim-claude-skills
```

### [`claude-notify-tools`](plugins/claude-notify-tools/)

Skills that make Claude tell you when it finishes or needs you, so a session never sits waiting unnoticed. Alerts can be a desktop notification, a soft chime, or a phone push via ntfy.sh. They work on macOS, Linux, WSL, and Windows.

```
/setup-notifications  →  hook installed (project by default, or user level)
/notify-toggle        →  on / off / mute a channel / status / test
```

| Skill | What it does |
|---|---|
| `/setup-notifications` | Asks which channels you want (desktop, sound, phone), which moments to alert on (needs permission, asked a question, finished, error, idle reminder), and how to cut noise (skip when your terminal is focused, phone only for turns longer than 2 minutes, quiet hours). Then it installs a dependency-free hook script for your OS, merges the hooks into your settings without touching anything else, sends test alerts, and confirms with you that they arrived. |
| `/notify-toggle` | Turns alerts on or off, mutes or unmutes a single channel, switches individual events on or off, shows status, or sends a test alert. It edits only the config file, so changes apply immediately. |

#### Install

```
/plugin install claude-notify-tools@ibrahim-claude-skills
```

### [`code-quality-tools`](plugins/code-quality-tools/)

Skills that make code easier for humans and AI agents to read: doc comments, type annotations, and naming for TypeScript + Next.js (React, tRPC, TanStack Query) and Python + Pydantic codebases.

```
/ts-docs-types-naming <files | folders | feature>  →  edits in place + short change list
/py-docs-types-naming <files | folders | feature>  →  edits in place + short change list
```

| Skill | What it does |
|---|---|
| `/ts-docs-types-naming` | Manual only. Applies one consistent set of rules for doc comments (TSDoc), type annotations, and naming to the files you give it. If you give no scope, it proposes the files changed in the chat and asks you to confirm. It adds TSDoc only where the name and signature leave questions, and keeps comments plain, with no outside links. It annotates exported boundaries but leaves tRPC and TanStack Query types to inference. It renames vague or misnamed identifiers and updates every caller. It never changes runtime behavior, and your repo's own lint rules and CLAUDE.md take precedence. The rules and fixed formats for the repeating structures fit in 50 lines. |
| `/py-docs-types-naming` | Manual only. The Python + Pydantic version. It gives every public module, class, function and method a Google-style docstring (or keeps your repo's existing style), with no outside links or ticket IDs. It annotates every parameter and return type using the newest syntax your `requires-python` allows. It documents Pydantic fields with attribute docstrings and moves constraints into `Annotated` types. It applies PEP 8 names and updates every caller, but never renames DB columns, env vars, JSON fields, routes or CLI flags. It never changes runtime or validation behavior: v1 APIs, missing `extra="forbid"` and untagged unions are reported, not fixed. Fits in 60 lines. |

#### Install

```
/plugin install code-quality-tools@ibrahim-claude-skills
```

## License

No explicit license is attached to this repository.
