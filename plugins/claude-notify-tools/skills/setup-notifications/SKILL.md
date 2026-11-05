---
name: setup-notifications
description: Set up Claude Code hooks that alert you when Claude finishes, needs permission, asks a question, or stops on an error, using a desktop notification, a soft sound, and/or a phone push via ntfy.sh. Works on macOS, Linux, WSL, and Windows. Installs for the current project by default, or at user level when asked. Use when the user says "/setup-notifications", "notify me when Claude stops", "play a sound when Claude needs me", "set up claude notifications", "ping my phone when Claude is done", or wants to reconfigure or uninstall these alerts.
argument-hint: "[user|project] [uninstall]"
---

# Setup Notifications

You install a notification hook so the user never waits on a Claude session that is idle or blocked. Hooks do the alerting. This skill only interviews the user, copies the handler, writes the config, wires up the hooks, and tests them.

Bundled files (copy them, never edit them in place):
- `${CLAUDE_SKILL_DIR}/assets/notify.sh` is the handler for macOS, Linux, WSL, and Git Bash.
- `${CLAUDE_SKILL_DIR}/assets/notify.ps1` is the handler for Windows (Windows PowerShell 5.1+).
- `${CLAUDE_SKILL_DIR}/assets/notify.conf` is the config template. Every switch and filter lives in it, and it is re-read on every event.
- `${CLAUDE_SKILL_DIR}/assets/sounds/{done,needs-you,error}.wav` are three soft chimes.
- `${CLAUDE_SKILL_DIR}/references/events.md` covers hook events, matchers, and stdin fields.
- `${CLAUDE_SKILL_DIR}/references/platforms.md` covers per-OS behavior, dependencies, manual steps, and troubleshooting.

## 1. Detect

Run the detection with Bash. On native Windows, Claude's Bash tool is Git Bash and `uname` prints `MINGW…`.

```bash
uname -s; grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null && echo WSL
for t in jq python3 curl wget notify-send pw-play paplay aplay osascript afplay lsappinfo xdotool xprop powershell.exe; do command -v "$t" >/dev/null 2>&1 && echo "have: $t"; done
echo "session=${XDG_SESSION_TYPE:-?} project=${CLAUDE_PROJECT_DIR:-$PWD}"
ls -d .claude/hooks/claude-notify ~/.claude/hooks/claude-notify 2>/dev/null
grep -l 'claude-notify' .claude/settings.local.json .claude/settings.json ~/.claude/settings.json 2>/dev/null
```

Classify the platform as `mac`, `linux`, `wsl`, or `windows`, where `MINGW*`, `MSYS*`, and `CYGWIN*` count as `windows`. Note any missing dependencies (see `references/platforms.md`). Do not stop because of them; they become manual steps.

**Scope.**
- The default is **project**.
- Use **user** only if `$ARGUMENTS` contains `user`, `global`, or `all projects`, or the user said so. If neither scope was given, ask in step 2.
- Project scope installs to `<project>/.claude/hooks/claude-notify/` and writes hooks to `<project>/.claude/settings.local.json`.
- User scope installs to `~/.claude/hooks/claude-notify/` and writes hooks to `~/.claude/settings.json`.

**Existing install.**
- If the target scope already has claude-notify, ask the user to choose: **Reconfigure** (re-run the interview and keep their sound/ntfy values as defaults), **Just toggle** (point them to `/notify-toggle` and stop), or **Uninstall** (go to step 7).
- If `$ARGUMENTS` contains `uninstall`, go straight to step 7.
- If the *other* scope also has claude-notify hooks, warn that every alert will arrive twice. Offer to remove the other scope's hook entries.

## 2. Interview

Use AskUserQuestion, put the recommended option first, and label it "(Recommended)". Ask everything in one call, then one optional follow-up call.

**Call 1** (drop the Scope question if the scope is already known):
1. **Scope:** "This project only (Recommended)" or "All projects (user level)".
2. **Channels** (multiSelect):
   - "Desktop notification (Recommended)"
   - "Sound (Recommended)": soft chimes, with a different chime for done, needs-you, and error.
   - "Phone via ntfy.sh": free, no account, uses a secret topic.
3. **Alert me when** (multiSelect):
   - "Claude needs me (Recommended)": permission prompt, AskUserQuestion, MCP input.
   - "Claude finished its turn (Recommended)"
   - "Claude stopped on an error (Recommended)"
   - "Idle reminder (Recommended)": fires after 60s+ of waiting.
   - Mention that "session end" is available through Other.
4. **Reduce noise** (multiSelect):
   - "Skip desktop/sound while my terminal is focused (Recommended)"
   - "Phone only for turns longer than 2 min (Recommended)": show only if ntfy may be chosen. It works by saving a timestamp on UserPromptSubmit and comparing it when Stop fires.
   - "Quiet hours for sound"
   - "Phone only for idle reminders and errors"
   - State that duplicate alerts within 5 seconds are always merged.

**Call 2** (only the questions that apply):
- **ntfy topic:** "Generate a secret topic (Recommended)" or "I already have one". Generate the topic with `echo "claude-$(od -An -N8 -tx1 /dev/urandom | tr -d ' \n')"`.
- **Where to keep the topic:** "Environment variable CLAUDE_NOTIFY_NTFY_TOPIC (Recommended)" or "In notify.conf". Anyone who knows the topic can read the alerts.
- **Sound volume:** "Medium 0.6 (Recommended)", "Soft 0.35", or "Loud 0.9".
- **Quiet hours:** "22:00-08:00 (Recommended)", "23:00-07:00", or "18:00-09:00".

## 3. Install files

Set `DIR` to the install folder for the chosen scope. Use the Bash tool:

```bash
DIR="<install folder>"; SRC="${CLAUDE_SKILL_DIR}/assets"
mkdir -p "$DIR/sounds" && cp "$SRC"/sounds/*.wav "$DIR/sounds/"
cp "$SRC/notify.sh" "$DIR/" && chmod +x "$DIR/notify.sh"        # mac, linux, wsl
cp "$SRC/notify.ps1" "$DIR/"                                       # windows, wsl
[ -f "$DIR/notify.conf" ] || cp "$SRC/notify.conf" "$DIR/"         # keep an existing config on reconfigure
```

On `mac` and `linux` you may skip `notify.ps1`. On `windows` you may skip `notify.sh`. **WSL needs both**, because `notify.sh` hands the desktop toast and the sound to `notify.ps1` through `powershell.exe`.

Then edit `$DIR/notify.conf` with the Edit tool to match the answers. Change only the lines below:
- `channel_desktop`, `channel_sound`, and `channel_ntfy`.
- `event_permission`, `event_question`, and `event_elicitation` follow "needs me". `event_stop` follows "finished". `event_failure` follows "error". `event_idle` follows "idle". `event_session_end` follows "session end".
- `skip_local_when_focused`.
- `min_turn_seconds`: 120 if chosen, otherwise 0.
- `quiet_hours` and `ntfy_only_idle_and_errors`.
- `sound_volume`.
- `ntfy_topic`, only if the user chose to keep the topic in the file.

## 4. Wire the hooks

**Handler command.** Pick the one for the platform and scope:

| Platform | Project scope | User scope |
|---|---|---|
| mac / linux / wsl | `bash "$CLAUDE_PROJECT_DIR/.claude/hooks/claude-notify/notify.sh"` | `bash "$HOME/.claude/hooks/claude-notify/notify.sh"` |
| windows | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "<ABS>/notify.ps1"` | same, with `<ABS>` = the user-scope folder |

On Windows, `<ABS>` is the absolute install folder written with forward slashes, for example `C:/Users/me/proj/.claude/hooks/claude-notify`. Get it from `cygpath -m "$DIR"`. The command must work whether Claude Code runs hooks through Git Bash or through PowerShell, so it must not use `$CLAUDE_PROJECT_DIR` or `$HOME` there.

**Entries to register.** Register all of them so `/notify-toggle` can switch events on and off later without touching settings. `notify.conf` decides what actually alerts.

```json
{
  "hooks": {
    "Notification": [{ "matcher": "permission_prompt|idle_prompt|elicitation_dialog",
                       "hooks": [{ "type": "command", "command": "<CMD>", "timeout": 10 }] }],
    "PreToolUse":   [{ "matcher": "AskUserQuestion",
                       "hooks": [{ "type": "command", "command": "<CMD>", "timeout": 10 }] }],
    "Stop":         [{ "hooks": [{ "type": "command", "command": "<CMD>", "timeout": 10 }] }],
    "StopFailure":  [{ "hooks": [{ "type": "command", "command": "<CMD>", "timeout": 10 }] }],
    "SessionEnd":   [{ "hooks": [{ "type": "command", "command": "<CMD>", "timeout": 5 }] }]
  }
}
```

- Add `"UserPromptSubmit": [{ "hooks": [{ "type": "command", "command": "<CMD>", "timeout": 5 }] }]` **only** when `min_turn_seconds > 0`. Each hook spawns a process, which costs about 0.3 s per prompt on Windows.
- Never register `auth_success`.
- Don't add PermissionRequest or Elicitation hooks, because they duplicate the Notification matchers above.

**Merge into the settings file. Never overwrite it.**
1. Read the settings file. If it doesn't exist, start from `{}`.
2. For each event above, remove any existing matcher group whose `hooks[].command` contains `claude-notify/notify.`, then append the new group. This makes a re-run idempotent.
3. Leave every other key and every other hook exactly as it was.
4. Write the file with the Write tool, then validate it with `jq . FILE` or `python3 -m json.tool FILE`. If neither is available, Read it back and check it.

**Keep it out of git (project scope only).**
- Run `git check-ignore -q .claude/settings.local.json .claude/hooks/claude-notify/notify.conf`.
- If either path is not ignored, ask the user to choose: "Add to .git/info/exclude (Recommended, local only)", "Add to .gitignore", or "Leave it".
- The ignore entries are `.claude/hooks/claude-notify/` and `.claude/settings.local.json`.

## 5. Manual steps

Print only the steps that apply, taken from `references/platforms.md`:
- **Missing dependencies.** For example `sudo apt install libnotify-bin pipewire-bin` on Linux.
- **OS notification permission.** On macOS: System Settings → Notifications → Script Editor. On Windows: Settings → System → Notifications → Windows PowerShell, and check Focus Assist / Do Not Disturb.
- **ntfy.** Install the ntfy app (iOS/Android) or open `https://ntfy.sh/<topic>`, then subscribe to the topic. If the user chose the env var, show the line for their shell profile:
  - bash/zsh: `export CLAUDE_NOTIFY_NTFY_TOPIC=<topic>`
  - PowerShell: `[Environment]::SetEnvironmentVariable('CLAUDE_NOTIFY_NTFY_TOPIC','<topic>','User')`
  - Tell them to restart the terminal and Claude Code afterwards.
- **Focus detection limits.**
  - Wayland and tmux cannot detect focus, so alerts always fire there.
  - iTerm2 falls back to matching the app name.

## 6. Test and verify

1. **Channels.** Run the installed handler in test mode. Test mode bypasses the filters and prints what it did:
   - mac / linux / wsl: `bash "$DIR/notify.sh" --test needs`
   - windows: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "<ABS>/notify.ps1" -Test needs`
2. **Hook path.** Pipe a fake event through the exact command you registered, with filters bypassed:
   `echo '{"hook_event_name":"Notification","notification_type":"permission_prompt","message":"Test: Claude needs your permission","cwd":"'"$PWD"'","session_id":"setup-test"}' | CLAUDE_NOTIFY_FORCE=1 CLAUDE_PROJECT_DIR="<project root>" <CMD>`
   It must exit 0 and print nothing. The Bash tool may not have `CLAUDE_PROJECT_DIR` set, which is why the command passes it explicitly.
3. **Confirm with the user.** Use AskUserQuestion (multiSelect) and ask what arrived: desktop notification, sound, phone push, or nothing.
4. **Troubleshoot anything missing.**
   - Set `debug=true` in `notify.conf` and run the test again.
   - Read `${TMPDIR:-/tmp}/claude-notify/notify.log`. On Windows the log is `%TEMP%\claude-notify\notify.log`.
   - Fix the cause using the table in `references/platforms.md`.
   - Set `debug` back to `false` when done.
5. Tell the user that hook changes made mid-session may need one visit to `/hooks`, or a restart of Claude Code, before they take effect.

## 7. Uninstall

1. Remove the claude-notify matcher groups from the scope's settings file, using the same merge rule as step 4 (remove only).
2. Delete empty event arrays and an empty `hooks` object.
3. Delete the install folder.
4. Remove the ignore lines you added.
5. Confirm with the user before deleting anything.

## Report

End with a short summary covering:
- the scope and file paths;
- the enabled channels and events, and the active filters;
- any manual steps the user still has to do;
- the toggles: `/notify-toggle off|on|status|mute <channel>`, the per-shell kill switch `CLAUDE_NOTIFY=0`, and that `notify.conf` can be edited by hand.
