---
name: notify-toggle
description: Turn Claude Code notification alerts (installed by /setup-notifications) on or off, mute or unmute a single channel (desktop, sound, ntfy), switch individual events on or off, show the current status, or send a test alert. Use when the user says "/notify-toggle", "turn off notifications", "mute the sound", "stop pinging my phone", "notifications on", "are claude notifications on?", or "test my notification".
argument-hint: "on | off | status | mute <desktop|sound|ntfy> | unmute <channel> | event <name> on|off | test [done|needs|error]"
---

# Notify Toggle

You change the settings in an existing claude-notify install. **Edit only `notify.conf`.** The hooks stay registered, and the handler re-reads the file on every event, so changes apply to the next alert without a restart.

## 1. Find the config

Look in this order and use the first file that exists:
1. `<project>/.claude/hooks/claude-notify/notify.conf`, where `<project>` is `$CLAUDE_PROJECT_DIR` or the current repo root.
2. `~/.claude/hooks/claude-notify/notify.conf`.

- If both exist, say which one you are changing. If the user said "global", "user", or "everywhere", use the user one.
- If neither exists, tell the user nothing is installed, offer `/setup-notifications`, and stop.

## 2. Apply the action from `$ARGUMENTS`

If there are no arguments, run `status` first, then ask with AskUserQuestion what to change. Options: Turn off, Turn on, Mute a channel, Send a test.

Edit only the matching `key=value` lines with the Edit tool, and keep any comments:

| Action | Change |
|---|---|
| `off` | `enabled=false` |
| `on` | `enabled=true` |
| `mute <ch>` | `channel_<ch>=false`, where ch is `desktop`, `sound`, or `ntfy` |
| `unmute <ch>` | `channel_<ch>=true`. For `ntfy`, check that a topic exists: `ntfy_topic` or the env var `CLAUDE_NOTIFY_NTFY_TOPIC`. If none does, tell the user to run `/setup-notifications`. |
| `event <name> on/off` | `event_<name>=true/false`, where name is `permission`, `question`, `elicitation`, `idle`, `stop`, `failure`, or `session_end` |
| `quiet <HH:MM-HH:MM>` / `quiet off` | `quiet_hours=<range>` / `quiet_hours=` |
| `debug on/off` | `debug=true/false` |
| `test [kind]` | Run the handler in test mode (below). Change nothing. |
| `status` | Change nothing. |

Map natural language onto these actions. For example, "silence the sound" means `mute sound`, "stop phone pings" means `mute ntfy`, and "don't tell me when it finishes" means `event stop off`.

If the user turns on `min_turn_seconds` (sets it above 0) but the settings file has no `UserPromptSubmit` hook containing `claude-notify/notify.`, the filter can't work. Say so, and suggest re-running `/setup-notifications`.

## 3. Test mode

Run the installed handler. It bypasses the filters and prints what it sent:
- mac / linux / wsl: `bash "<dir>/notify.sh" --test <done|needs|error>`
- windows (when `notify.ps1` exists and `notify.sh` doesn't): `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "<dir>/notify.ps1" -Test <kind>`

## 4. Report

Print a compact status after every action:
- the config path and scope;
- `enabled`;
- the channels with on/off for each;
- the events with on/off for each;
- the filters: focus skip, minimum turn length with its channels, quiet hours, dedupe seconds, and ntfy-only-idle;
- where the ntfy topic comes from: the env var, the file, or none. Never print the topic itself.

Remind the user once that `CLAUDE_NOTIFY=0` mutes every alert for a single shell without editing the file.
