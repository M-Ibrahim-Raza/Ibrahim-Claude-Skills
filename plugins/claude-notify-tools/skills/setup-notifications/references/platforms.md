# Platform notes for claude-notify

## How each channel is delivered

| | Desktop | Sound | ntfy | Focus detection |
|---|---|---|---|---|
| **macOS** | `osascript` `display notification` | `afplay -v <vol>` | `curl` | `lsappinfo` front app PID is an ancestor of the hook; falls back to front app name vs `$TERM_PROGRAM` |
| **Linux (X11)** | `notify-send` | `pw-play` → `paplay` → `aplay` → `canberra-gtk-play` | `curl` → `wget` | `xdotool` / `xprop` active window PID is an ancestor |
| **Linux (Wayland)** | `notify-send` | same as X11 | same as X11 | not detectable; always alerts |
| **WSL** | `notify.sh` → `powershell.exe notify.ps1` (Windows toast) | same delegation (Windows audio) | `curl` from WSL | foreground app is a known terminal/IDE |
| **Windows** | WinRT toast (PowerShell 5.1) → BurntToast → balloon tip | `MediaPlayer` (volume) → `SoundPlayer` | `Invoke-RestMethod` | foreground window PID is an ancestor of the hook |

On Windows the handler hands the sending to a hidden background `powershell.exe`, so Claude is never kept waiting. On macOS and Linux, sending runs in a detached subshell.

## Dependencies and manual steps

### macOS
- Nothing to install.
- The first notification is attributed to **Script Editor**. Allow it in System Settings → Notifications → Script Editor. Focus / Do Not Disturb modes hide banners.

### Linux
- Desktop needs `notify-send`:
  - Debian/Ubuntu: `sudo apt install libnotify-bin`
  - Fedora: `sudo dnf install libnotify`
  - Arch: `sudo pacman -S libnotify`
- Sound needs one of `pw-play` (`pipewire-bin` / `pipewire-utils`), `paplay` (`pulseaudio-utils`), or `aplay` (`alsa-utils`).
- Focus detection on X11 is more reliable with `xdotool`, though `xprop` also works. Wayland can't detect focus.
- On headless or SSH machines desktop and sound do nothing. Use ntfy.

### WSL
- `powershell.exe` must be on PATH. That's the default; it's missing only if `appendWindowsPath=false` in `/etc/wsl.conf`.
- Both `notify.sh` and `notify.ps1` must be in the install folder.
- Windows notification settings apply (see Windows below).

### Windows
- The hook runs `powershell.exe` (Windows PowerShell 5.1, built into Windows 10 and 11). It works whether Claude Code runs hooks through Git Bash or PowerShell.
- Toasts appear as **Windows PowerShell**. Check Settings → System → Notifications → Windows PowerShell, and make sure Focus Assist / Do Not Disturb is off.
- Optional: `Install-Module BurntToast -Scope CurrentUser`. It's used only if the native toast fails, for example under PowerShell 7.
- `ExecutionPolicy Bypass` applies only to this one script invocation.

### ntfy (all platforms)
1. Install the ntfy app (Android: Play Store/F-Droid; iOS: App Store), or open `https://ntfy.sh/<topic>` in a browser.
2. Subscribe to the topic. The topic works like a password: anyone who knows it can read your alerts.
3. Prefer the env var `CLAUDE_NOTIFY_NTFY_TOPIC`. For a self-hosted or protected server, set `ntfy_server` in `notify.conf` and the env var `CLAUDE_NOTIFY_NTFY_TOKEN`.
4. Priorities: needs-you and errors are `high`, done is `default`, and session end is `low`.

## Troubleshooting

First turn on `debug=true` in `notify.conf`, run the test again, and read the log:
- macOS / Linux / WSL: `${TMPDIR:-/tmp}/claude-notify/notify.log`
- Windows: `%TEMP%\claude-notify\notify.log`

| Symptom / log line | Fix |
|---|---|
| No log line at all | The hook isn't firing. Check `/hooks` in Claude Code, confirm the command path, and restart the session. |
| `disabled (enabled=false …)` | Run `/notify-toggle on`. |
| `deduped` | Expected: two alerts came within `dedupe_seconds`. |
| `terminal focused: skipped` | Expected. Set `skip_local_when_focused=false` if you want alerts anyway. |
| `short turn … dropped: ntfy` | Expected. Lower `min_turn_seconds`, or set it to 0. |
| `desktop: notify-send not installed` | Install libnotify (see above). |
| `sound: no player found` | Install pipewire, pulseaudio-utils, or alsa-utils. |
| `ntfy: no topic` | Set `CLAUDE_NOTIFY_NTFY_TOPIC` in the shell that starts `claude`, or set `ntfy_topic`. |
| `failed: ntfy` | Check network/proxy, run `curl -d hi https://ntfy.sh/<topic>`, and check the token. |
| Windows: `sent: desktop (balloon)` | The native toast failed. Install BurntToast, or check Windows notification settings. |
| Windows: no sound with volume < 1 | Set `sound_volume=1` to use the simpler SoundPlayer. |
| Alerts arrive twice | claude-notify is installed in both project and user scope. Uninstall one. |
