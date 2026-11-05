# Getting started

This guide walks you from a fresh Claude Code install to running any plugin in this marketplace.
For what each skill does in detail, see the [README](README.md).

The marketplace lives at `M-Ibrahim-Raza/Ibrahim-Claude-Skills` on GitHub and registers in Claude Code
under the name `ibrahim-claude-skills`. It has nine plugins:

| Plugin | Use it for | Install (inside Claude Code) |
|---|---|---|
| [`sdd-toolkit`](plugins/sdd-toolkit/) | Spec-driven development: spec → plan → tasks → implementation | `/plugin install sdd-toolkit@ibrahim-claude-skills` |
| [`update-app-docs`](plugins/update-app-docs/) | Keeping a project's `docs/` folder in sync with shipped features | `/plugin install update-app-docs@ibrahim-claude-skills` |
| [`obsidian-notes`](plugins/obsidian-notes/) | Adding diagrams and content to an Obsidian vault | `/plugin install obsidian-notes@ibrahim-claude-skills` |
| [`communication-tools`](plugins/communication-tools/) | Writing, rewriting, and formatting messages for Slack and ClickUp | `/plugin install communication-tools@ibrahim-claude-skills` |
| [`git-tools`](plugins/git-tools/) | Committing, pushing, switching branches, cherry-picking, and opening PRs | `/plugin install git-tools@ibrahim-claude-skills` |
| [`prompt-tools`](plugins/prompt-tools/) | Restructuring prompts for coding agents and making scoped prompt edits | `/plugin install prompt-tools@ibrahim-claude-skills` |
| [`learning-tools`](plugins/learning-tools/) | Learning a concept with a tutor that guides you instead of handing over answers | `/plugin install learning-tools@ibrahim-claude-skills` |
| [`stack-tools`](plugins/stack-tools/) | Mapping your app's tech stack into a file, and researching and choosing new tools to add to it | `/plugin install stack-tools@ibrahim-claude-skills` |
| [`claude-notify-tools`](plugins/claude-notify-tools/) | Getting a desktop alert, soft sound, or phone push when Claude finishes or needs you | `/plugin install claude-notify-tools@ibrahim-claude-skills` |

Each plugin installs on its own. Install only the ones you need.

## Before you start

- Install [Claude Code](https://code.claude.com/docs) and check it runs with `claude --version`.
- The repository is public, so you don't need GitHub access or git credentials to install from it.
- The one-command install shortcut in [Step 2](#step-2-install-a-plugin) needs Claude Code v2.1.275 or later inside a session, and v2.1.292 or later from your shell. Everything else works on any version that has `/plugin`.

## Step 1: Add the marketplace

You do this once per machine. Start Claude Code with `claude` in any folder, then run:

```text
/plugin marketplace add M-Ibrahim-Raza/Ibrahim-Claude-Skills
```

Or, from your shell without starting a session:

```bash
claude plugin marketplace add M-Ibrahim-Raza/Ibrahim-Claude-Skills
```

Either way, you should see `Successfully added marketplace: ibrahim-claude-skills`. The nine plugins now show up on the **Discover** tab of `/plugin`.

## Step 2: Install a plugin

Pick whichever way suits you. All three install the same thing.

**Inside a session.** Run `/plugin install` with the plugin name and the marketplace name:

```text
/plugin install git-tools@ibrahim-claude-skills
```

This doesn't install right away. It opens the plugin's details so you can see which skills it adds, then asks you to [choose a scope](#choose-a-scope). After you pick one, Claude Code installs the plugin and tells you whether it's active now or needs `/reload-plugins`.

**By browsing.** Run `/plugin` with nothing after it. The **Discover** tab lists every plugin from your marketplaces. Type to filter, press **Enter** on a plugin, and choose a scope.

**From your shell.** Good for setup scripts and for installing several plugins at once:

```bash
claude plugin install git-tools@ibrahim-claude-skills
```

This installs at user scope. Add `--scope project` or `--scope local` to change that. The plugin loads the next time you start Claude Code, or right away if you run `/reload-plugins` in an open session.

### Shortcut: add the marketplace and install in one command

If you skipped Step 1, name the marketplace source with `--marketplace` and give the plugin name without `@ibrahim-claude-skills`:

```bash
claude plugin install git-tools --marketplace M-Ibrahim-Raza/Ibrahim-Claude-Skills
```

The same works inside a session as `/plugin install git-tools --marketplace M-Ibrahim-Raza/Ibrahim-Claude-Skills`. Claude Code asks you to confirm the new marketplace first.

### Install all nine

```bash
claude plugin marketplace add M-Ibrahim-Raza/Ibrahim-Claude-Skills
for p in sdd-toolkit update-app-docs obsidian-notes communication-tools git-tools prompt-tools learning-tools stack-tools claude-notify-tools; do
  claude plugin install "$p@ibrahim-claude-skills"
done
```

## Choose a scope

The scope decides who gets the plugin and which settings file records it.

| Scope | Who gets it | Written to | Use it when |
|---|---|---|---|
| **User** (default) | You, in every project on this machine | `~/.claude/settings.json` | You want the plugin everywhere. Right for most of these plugins. |
| **Project** | Everyone who works in this repository | `.claude/settings.json` (commit it) | Your team should share the plugin in one repo, e.g. `sdd-toolkit` or `update-app-docs`. |
| **Local** | You, in this repository only | `.claude/settings.local.json` | You want to try a plugin in one repo without sharing it. |

Project scope turns the plugin on for your collaborators, but it doesn't download it to their machines.
Each collaborator still runs this once:

```bash
claude plugin install <plugin>@ibrahim-claude-skills --scope project
```

If the same plugin is set at more than one scope, local wins over project, and project wins over user.

## Step 3: Check it worked

Type `/` in Claude Code. Plugin skills appear under the plugin's name, in the form `/<plugin>:<skill>`.
After installing `git-tools` you should see `/git-tools:commit`, `/git-tools:push-branch`, and the rest.

You can also check in two other places:

- The **Installed** tab in `/plugin`, which lists each plugin with its scope.
- `claude plugin list` in your shell, which prints each plugin's version, scope, and status.

If the skills don't appear, run `/reload-plugins` or restart Claude Code. See [Troubleshooting](#troubleshooting) if that doesn't fix it.

## Using the skills

Run a skill by typing its full name, followed by any input:

```text
/git-tools:switch-branch feature/csv-export
/communication-tools:format-slack-message the deploy for PR 123 failed on staging
```

The [README](README.md) uses short names like `/commit`. Inside Claude Code the full name is `/git-tools:commit`.

Skills run in one of two ways:

- **Only when you type the command.** Claude never starts these on its own: `sdd-specify`, `sdd-plan`, `sdd-tasks`, `sdd-implement`, `write-naturally`, `rewrite-for-slack`, `message-clarity-coach`, `add-diagram`, `place-content`, `search-and-add-concept`, `learn`, `tech-stack-mapper`, and `tech-picker`.
- **When you type the command, or when you ask in plain words.** Claude picks these up from requests like "commit this" or "open a PR": `commit`, `push-branch`, `open-pr`, `switch-branch`, `cherry-pick-branch`, `format-slack-message`, `format-clickup-message`, `prompt-optimizer-for-code`, `prompt-instruction-editor`, and `update-app-docs`.

## Plugin by plugin

### `sdd-toolkit`

```text
/plugin install sdd-toolkit@ibrahim-claude-skills
```

```bash
claude plugin install sdd-toolkit@ibrahim-claude-skills
```

**What you need first:** start Claude Code in the repository you're building the feature in. The skills write their files to `specs/<feature>/` at the repo root.

| Skill | Input | Writes |
|---|---|---|
| `/sdd-toolkit:sdd-specify` | `[task or ticket]` | `specs/<feature>/spec.md` |
| `/sdd-toolkit:sdd-plan` | `[path to spec.md or feature folder]` | `specs/<feature>/plan.md` |
| `/sdd-toolkit:sdd-tasks` | `[path to plan.md or feature folder]` | `specs/<feature>/tasks.md` |
| `/sdd-toolkit:sdd-implement` | `[path to tasks.md or feature folder]` | Code changes, with each task checked off in `tasks.md` |

Run the phases in order. The first three work in plan mode: they ask you questions instead of guessing, show you a draft, and save the file only after you approve it.
If you leave out the path, `sdd-plan`, `sdd-tasks`, and `sdd-implement` list the folders under `specs/` and ask which one to use.

Start a **fresh session** for `sdd-implement`. It reads the three files as documents, with no memory of the planning chat. It runs the tasks without stopping between them, and it doesn't commit anything.

```text
/sdd-toolkit:sdd-specify Add CSV export to the reports page
/sdd-toolkit:sdd-plan specs/csv-export
```

### `update-app-docs`

```text
/plugin install update-app-docs@ibrahim-claude-skills
```

```bash
claude plugin install update-app-docs@ibrahim-claude-skills
```

**What you need first:** a project with its docs in `docs/` at the repo root, indexed by `docs/README.md`. If neither exists yet, the skill proposes creating them and asks before it writes.

| Skill | Input |
|---|---|
| `/update-app-docs:update-app-docs` | `[feature] [details…]` |

It proposes the exact edit and waits for your approval. It only edits docs. It never changes code, opens tickets, or commits.

```text
/update-app-docs:update-app-docs csv-export Reports over 50k rows now export in the background
```

### `obsidian-notes`

```text
/plugin install obsidian-notes@ibrahim-claude-skills
```

```bash
claude plugin install obsidian-notes@ibrahim-claude-skills
```

**What you need first:** start Claude Code inside your Obsidian vault folder. The skills search and edit the notes in that folder.

| Skill | Input | Notes |
|---|---|---|
| `/obsidian-notes:add-diagram` | The note to diagram | Adds one Mermaid diagram. Replaces an existing diagram in that note rather than adding a second one. |
| `/obsidian-notes:place-content` | The point to place | Puts it in the best **existing** note. If nothing fits, it stops and asks. It never creates a file on its own. |
| `/obsidian-notes:search-and-add-concept` | A concept | Two turns. First it searches the web and explains the concept in chat. When you ask, it adds the content to a note, creating one if needed. |

```text
/obsidian-notes:search-and-add-concept vector databases
/obsidian-notes:place-content HNSW trades memory for faster approximate search
```

If diagrams render left-aligned, your vault doesn't have a centering CSS snippet enabled (Settings → Appearance → CSS snippets). The skill won't try to center diagrams from inside the note.

### `communication-tools`

```text
/plugin install communication-tools@ibrahim-claude-skills
```

```bash
claude plugin install communication-tools@ibrahim-claude-skills
```

**What you need first:** nothing. Paste the message after the command. These skills only return text. They never post to Slack or ClickUp.

| Skill | What you get back |
|---|---|
| `/communication-tools:write-naturally` | Your content rewritten or drafted so it reads like a person wrote it |
| `/communication-tools:rewrite-for-slack` | A short, casual Slack version, already run through `format-slack-message` |
| `/communication-tools:message-clarity-coach` | Coaching on your message: the exact problems and why they matter. It doesn't rewrite the message for you. |
| `/communication-tools:format-slack-message` | Your exact words with Slack bold, backticks, and linked URLs added |
| `/communication-tools:format-clickup-message` | Your exact words with ClickUp bold and backticks added |

```text
/communication-tools:rewrite-for-slack Hi team, I wanted to let everyone know that the staging deployment has been completed successfully.
```

### `git-tools`

```text
/plugin install git-tools@ibrahim-claude-skills
```

```bash
claude plugin install git-tools@ibrahim-claude-skills
```

**What you need first:** a git repository with an `origin` remote. `/open-pr` also needs the [GitHub CLI](https://cli.github.com/) logged in. Run `gh auth login` once.

| Skill | Input | Notes |
|---|---|---|
| `/git-tools:commit` | None | Atomic Conventional Commits with no AI attribution |
| `/git-tools:push-branch` | None | Refuses `main`, `master`, `develop`, `staging`, `production`, and `release/*`. Force-pushes only when you ask, and only with `--force-with-lease`. |
| `/git-tools:open-pr` | `[base-branch]` | Base defaults to the repo's default branch. Shows you the title and description before it creates the PR. |
| `/git-tools:switch-branch` | `<branch>` | Creates the branch if it doesn't exist. Stashes your changes and restores them after. |
| `/git-tools:cherry-pick-branch` | `<branch> [source-branch] [target-branch]` | Source defaults to `staging`, target to `main` |

```text
/git-tools:switch-branch feature/csv-export
/git-tools:open-pr staging
/git-tools:cherry-pick-branch feature/csv-export
```

### `prompt-tools`

```text
/plugin install prompt-tools@ibrahim-claude-skills
```

```bash
claude plugin install prompt-tools@ibrahim-claude-skills
```

**What you need first:** nothing. Paste the prompt after the command. `prompt-instruction-editor` can also take a file path and edits that file in place.

| Skill | Input | Notes |
|---|---|---|
| `/prompt-tools:prompt-optimizer-for-code` | A rough prompt for a coding agent | Reorders and formats only. It never adds requirements or drops details. |
| `/prompt-tools:prompt-instruction-editor` | The existing prompt plus the change you want | Edits only the instructions the change touches and shows a diff. Flags conflicts with existing rules instead of quietly editing them. |

```text
/prompt-tools:prompt-instruction-editor In prompts/support-agent.md, make refund requests over $500 go to a human
```

### `learning-tools`

```text
/plugin install learning-tools@ibrahim-claude-skills
```

```bash
claude plugin install learning-tools@ibrahim-claude-skills
```

**What you need first:** nothing. Type the topic after the command. Claude only switches into tutoring mode when you run the command.

| Skill | Input | Notes |
|---|---|---|
| `/learning-tools:learn` | A concept, topic, or question you want to understand | Asks one question to find where you're stuck, then guides you one step per turn instead of handing over the answer. Makes flashcards, quizzes, and study guides when you ask. |

```text
/learning-tools:learn Galois theory
/learning-tools:learn quiz me on TCP vs UDP
```

### `stack-tools`

```text
/plugin install stack-tools@ibrahim-claude-skills
```

```bash
claude plugin install stack-tools@ibrahim-claude-skills
```

**What you need first:** start Claude Code in your app's repository. Both skills look for your tech stack file (`tech_stack.md` or a close variant, at the repo root or under `docs/`) and read your manifests, such as `package.json`. `tech-picker` also needs web search. If you don't have a stack file yet, run `tech-stack-mapper` first.

| Skill | Input | Notes |
|---|---|---|
| `/stack-tools:tech-stack-mapper` | `[repo path] [stack file path]`, both optional | Lists only tools that are installed **and** used in code, config, or scripts, with exact lockfile versions. Unused dependencies go in its review notes, not the file. It writes `-` for any reason or date it can't find in the code or docs. It writes only after you accept the draft. |
| `/stack-tools:tech-picker` | `[domain] [tools to compare] [stack file path]`, all optional | Compares 3–5 current options, or the tools you name plus 1–2 it adds, and recommends one. It writes to your stack file only after you choose, and it matches the file's existing format. |

```text
/stack-tools:tech-stack-mapper
/stack-tools:tech-stack-mapper apps/web docs/tech_stack.md
/stack-tools:tech-picker state management
/stack-tools:tech-picker auth clerk auth0 docs/tech_stack.md
```

### `claude-notify-tools`

```text
/plugin install claude-notify-tools@ibrahim-claude-skills
```

```bash
claude plugin install claude-notify-tools@ibrahim-claude-skills
```

**What you need first:** start Claude Code in the project you want alerts for. Install the plugin at user scope so you can run the setup skill in any project; the skill itself decides whether the hook is project-only or global.

Requirements per OS:
- **macOS** needs nothing extra.
- **Linux** needs `notify-send` (libnotify) and one of `pw-play`, `paplay`, or `aplay`.
- **Windows** uses the built-in `powershell.exe`.
- **WSL** also needs `powershell.exe` on PATH.
- **Phone alerts** need the free ntfy app.

| Skill | Input | Notes |
|---|---|---|
| `/claude-notify-tools:setup-notifications` | `[user\|project] [uninstall]`, optional | Asks which channels, events, and noise filters you want, copies the hook script into `.claude/hooks/claude-notify/`, merges the hooks into `.claude/settings.local.json` (or `~/.claude/settings.json` for user scope), then sends test alerts and asks you to confirm they arrived. Re-running it reconfigures without duplicating hooks. |
| `/claude-notify-tools:notify-toggle` | `on`, `off`, `status`, `mute <channel>`, `unmute <channel>`, `event <name> on\|off`, or `test` | Edits only `notify.conf`, so a change applies to the next alert without a restart. `CLAUDE_NOTIFY=0` mutes every alert for one shell. |

```text
/claude-notify-tools:setup-notifications
/claude-notify-tools:setup-notifications user
/claude-notify-tools:notify-toggle mute sound
/claude-notify-tools:notify-toggle off
```

## Keep plugins updated

Auto-update is **off** by default for this marketplace, as it is for every third-party marketplace.
New versions reach you only when you update. You have three ways to do that:

- **Turn on auto-update.** Run `/plugin`, open the **Marketplaces** tab, select `ibrahim-claude-skills`, and choose **Enable auto-update**. Claude Code then updates these plugins in the background after each session starts.
- **Update everything from this marketplace now.** Same place, choose **Update marketplace**. This refreshes the list and updates every plugin you installed from it.
- **Update one plugin from your shell:**

  ```bash
  claude plugin update git-tools@ibrahim-claude-skills
  ```

Updates apply to the next session, or to the current one after `/reload-plugins`.
`claude plugin marketplace update` on its own only refreshes the list of plugins. It doesn't update the ones you installed.

## Disable or uninstall

```bash
claude plugin disable git-tools@ibrahim-claude-skills    # turn it off, keep it installed
claude plugin enable git-tools@ibrahim-claude-skills     # turn it back on
claude plugin uninstall git-tools@ibrahim-claude-skills  # remove it (add --scope project if you installed it there)
```

Inside a session, the **Installed** tab in `/plugin` does the same. Select a plugin and press **Space** to toggle it, or **Enter** for update and uninstall.

To remove the whole marketplace:

```bash
claude plugin marketplace remove ibrahim-claude-skills
```

This also uninstalls every plugin you installed from it.

## Other places you run Claude Code

- **VS Code:** type `/plugins` in the Claude Code panel. Add `M-Ibrahim-Raza/Ibrahim-Claude-Skills` on the **Marketplaces** tab, then install from the **Plugins** tab.
- **Desktop app:** click **+** next to the prompt box, then **Add plugins**.
- **JetBrains and `claude -p`:** use the shell commands above.
- **Cloud sessions** (including claude.ai/code): plugins you installed on your own machine don't load there.

The terminal, the desktop app, and VS Code on one computer share the same settings files. A plugin you install at user scope in one of them is available in the other two.

## Troubleshooting

| Problem | Fix |
|---|---|
| `/plugin install` says the plugin isn't found | Add the marketplace first ([Step 1](#step-1-add-the-marketplace)). If it's already added, refresh it with `/plugin marketplace update ibrahim-claude-skills`. |
| The plugin installed but its skills don't show under `/` | Run `/reload-plugins` or restart Claude Code. If they still don't show, open `/plugin` and check the **Errors** tab. |
| A new skill from this repo is missing | Your copy is out of date. See [Keep plugins updated](#keep-plugins-updated). |
| A teammate is told a plugin is enabled for the project but not installed | The plugin is on at project scope but not downloaded on their machine. They run `claude plugin install <plugin>@ibrahim-claude-skills --scope project`. |
| `/git-tools:open-pr` stops before creating the PR | The GitHub CLI isn't logged in. Run `gh auth login`. |
| `/git-tools:push-branch` refuses to push | You're on a protected branch. Move your work to a feature branch first, e.g. with `/git-tools:switch-branch`. |

## Testing a local clone

If you're changing these plugins, load your working copy for one session instead of installing it:

```bash
claude --plugin-dir ./plugins/git-tools
```

Pass `--plugin-dir` more than once to load several plugins. Before you push, check the manifests:

```bash
claude plugin validate .
```
