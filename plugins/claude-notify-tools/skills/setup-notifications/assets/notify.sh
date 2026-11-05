#!/usr/bin/env bash
# claude-notify — Claude Code notification hook (macOS / Linux / WSL / Git Bash)
#
# Hook mode : Claude Code pipes the hook JSON on stdin.
# Test mode : notify.sh --test [done|needs|error]   (bypasses filters, runs synchronously)
#
# Settings live in notify.conf next to this script. They are re-read on every call.
# Kill switch: CLAUDE_NOTIFY=0. Bypass filters (for testing piped JSON): CLAUDE_NOTIFY_FORCE=1.
# This script never blocks Claude: every path ends in exit 0 and it prints nothing in hook mode.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
CONF="$SCRIPT_DIR/notify.conf"
STATE_DIR="${TMPDIR:-/tmp}"
STATE_DIR="${STATE_DIR%/}/claude-notify"
LOG="$STATE_DIR/notify.log"
TEST_MODE=0
[ "${1:-}" = "--test" ] && TEST_MODE=1

# ---------------------------------------------------------------- helpers
conf() { # conf <key> <default>
  local v=""
  [ -f "$CONF" ] && v=$(tr -d '\r' <"$CONF" | grep -E "^[[:space:]]*$1[[:space:]]*=" | tail -n 1 |
    sed -E 's/^[^=]*=//; s/[[:space:]]+#.*$//; s/^[[:space:]]+//; s/[[:space:]]+$//')
  printf '%s' "${v:-$2}"
}
is_true() { case "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')" in true|1|yes|on) return 0 ;; esac; return 1; }
DEBUG=0
log() {
  if [ "$DEBUG" = 1 ] || [ "$TEST_MODE" = 1 ]; then
    mkdir -p "$STATE_DIR" 2>/dev/null
    printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$LOG" 2>/dev/null
  fi
  [ "$TEST_MODE" = 1 ] && printf '%s\n' "$*"
  return 0
}
now() { date +%s; }
truncate_text() { # truncate_text <n> <text>
  local n=$1 s=$2
  [ "$n" -le 0 ] 2>/dev/null && { printf ''; return; }
  if [ "${#s}" -gt "$n" ]; then printf '%s…' "${s:0:$n}"; else printf '%s' "$s"; fi
}

PLATFORM=linux
case "$(uname -s 2>/dev/null)" in
  Darwin) PLATFORM=mac ;;
  MINGW* | MSYS* | CYGWIN*) PLATFORM=gitbash ;;
  Linux) grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null && PLATFORM=wsl ;;
esac

# ---------------------------------------------------------------- input parsing
# Fields are joined with \x1f (unit separator); newlines/tabs collapsed to spaces.
FIELDS='hook_event_name notification_type message cwd session_id stop_hook_active last_assistant_message error tool_name question reason'
parse_jq() {
  jq -r '[.hook_event_name, .notification_type, .message, .cwd, .session_id,
          (if .stop_hook_active == true then "true" else "" end),
          .last_assistant_message, .error, .tool_name,
          (.tool_input.questions[0].question? // ""), .reason]
         | map((. // "") | tostring | gsub("[\r\n\t]+"; " ")) | join("\u001f")' 2>/dev/null
}
parse_py() {
  python3 -I -c '
import json, sys, re
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(1)
q = ""
try:
    q = d["tool_input"]["questions"][0]["question"]
except Exception:
    pass
vals = [d.get("hook_event_name"), d.get("notification_type"), d.get("message"), d.get("cwd"),
        d.get("session_id"), "true" if d.get("stop_hook_active") is True else "",
        d.get("last_assistant_message"), d.get("error"), d.get("tool_name"), q, d.get("reason")]
out = [re.sub(r"[\r\n\t]+", " ", "" if v is None else str(v)) for v in vals]
sys.stdout.write("\x1f".join(out))
' 2>/dev/null
}
parse_sed() { # last-resort, dependency-free: handles flat string/bool fields
  local flat k v out="" sep=""
  flat=$(printf '%s' "$INPUT" | tr '\r\n\t' '   ')
  for k in $FIELDS; do
    case "$k" in
      stop_hook_active)
        if printf '%s' "$flat" | grep -qE '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then v=true; else v=""; fi ;;
      *)
        v=$(printf '%s' "$flat" | sed -nE "s/.*\"$k\"[[:space:]]*:[[:space:]]*\"(([^\"\\\\]|\\\\.)*)\".*/\\1/p" | head -n 1)
        v=$(printf '%s' "$v" | sed -E 's/\\n/ /g; s/\\"/"/g; s/\\\\/\\/g') ;;
    esac
    out="$out$sep$v"; sep=$'\x1f'
  done
  printf '%s' "$out"
}
parse_input() {
  local line=""
  if command -v jq >/dev/null 2>&1; then line=$(printf '%s' "$INPUT" | parse_jq); fi
  if [ -z "$line" ] && command -v python3 >/dev/null 2>&1; then line=$(printf '%s' "$INPUT" | parse_py); fi
  [ -z "$line" ] && line=$(parse_sed)
  IFS=$'\x1f' read -r EVENT NTYPE MESSAGE CWD SESSION STOP_ACTIVE LAST_MSG ERROR TOOL QUESTION REASON <<<"$line"
}

# ---------------------------------------------------------------- focus detection
is_ancestor() { # is_ancestor <pid>: is <pid> an ancestor of this script?
  local target=$1 p=$$ i=0
  while [ -n "$p" ] && [ "$p" -gt 1 ] 2>/dev/null && [ $i -lt 50 ]; do
    [ "$p" = "$target" ] && return 0
    p=$(ps -o ppid= -p "$p" 2>/dev/null | tr -d ' ')
    i=$((i + 1))
  done
  return 1
}
terminal_is_focused() {
  local pid="" name="" want=""
  case "$PLATFORM" in
    mac)
      command -v lsappinfo >/dev/null 2>&1 || return 1
      local asn
      asn=$(lsappinfo front 2>/dev/null)
      [ -n "$asn" ] || return 1
      pid=$(lsappinfo info -only pid "$asn" 2>/dev/null | sed -nE 's/.*=[[:space:]]*([0-9]+).*/\1/p')
      [ -n "$pid" ] && is_ancestor "$pid" && return 0
      # Fallback: frontmost app name vs the terminal this session runs in (iTerm2/tmux break ancestry).
      name=$(lsappinfo info -only name "$asn" 2>/dev/null | sed -nE 's/.*="?([^"]*)"?.*/\1/p' | tr '[:upper:]' '[:lower:]')
      case "${TERM_PROGRAM:-}" in
        Apple_Terminal) want="terminal" ;;
        iTerm.app) want="iterm" ;;
        vscode) want="code|cursor|windsurf|vscodium" ;;
        WezTerm) want="wezterm" ;;
        ghostty) want="ghostty" ;;
        WarpTerminal) want="warp" ;;
        *) want=$(printf '%s' "${TERM_PROGRAM:-}" | tr '[:upper:]' '[:lower:]') ;;
      esac
      [ -n "$want" ] && [ -n "$name" ] && printf '%s' "$name" | grep -qE "$want" && return 0
      return 1 ;;
    linux)
      # Wayland gives no portable way to read the focused window: treat as not focused (alert).
      [ "${XDG_SESSION_TYPE:-}" = "wayland" ] && return 1
      [ -n "${WAYLAND_DISPLAY:-}" ] && [ "${XDG_SESSION_TYPE:-}" != "x11" ] && return 1
      [ -n "${DISPLAY:-}" ] || return 1
      if command -v xdotool >/dev/null 2>&1; then
        pid=$(xdotool getactivewindow getwindowpid 2>/dev/null)
      elif command -v xprop >/dev/null 2>&1; then
        local wid
        wid=$(xprop -root _NET_ACTIVE_WINDOW 2>/dev/null | sed -nE 's/.*# (0x[0-9a-fA-F]+).*/\1/p')
        [ -n "$wid" ] && pid=$(xprop -id "$wid" _NET_WM_PID 2>/dev/null | sed -nE 's/.*= ([0-9]+).*/\1/p')
      fi
      [ -n "$pid" ] && is_ancestor "$pid" && return 0
      return 1 ;;
  esac
  return 1 # wsl/gitbash: handled by notify.ps1 (-SkipIfFocused)
}

in_quiet_hours() { # in_quiet_hours "22:00-08:00"
  local range=$1 s e cur
  [ -n "$range" ] || return 1
  s=$(printf '%s' "${range%-*}" | tr -d ': ') e=$(printf '%s' "${range#*-}" | tr -d ': ')
  cur=$(date +%H%M)
  s=$((10#$s)) e=$((10#$e)) cur=$((10#$cur))
  if [ "$s" -le "$e" ]; then [ "$cur" -ge "$s" ] && [ "$cur" -lt "$e" ]; else [ "$cur" -ge "$s" ] || [ "$cur" -lt "$e" ]; fi
}

# ---------------------------------------------------------------- channels
win_path() { # path conversion for WSL / Git Bash
  if [ "$PLATFORM" = wsl ]; then wslpath -w "$1" 2>/dev/null; else cygpath -w "$1" 2>/dev/null; fi
}
send_windows() { # delegate desktop/sound to notify.ps1 (WSL, Git Bash)
  local channels=$1 ps1="$SCRIPT_DIR/notify.ps1" args=()
  [ -f "$ps1" ] || { log "windows delegate: notify.ps1 missing next to notify.sh"; return 1; }
  command -v powershell.exe >/dev/null 2>&1 || { log "windows delegate: powershell.exe not on PATH"; return 1; }
  args=(-NoProfile -ExecutionPolicy Bypass -File "$(win_path "$ps1")" -Title "$TITLE" -Body "$BODY"
    -Kind "$KIND" -Channels "$channels" -Volume "$VOLUME")
  [ -n "$SOUND_FILE" ] && args+=(-SoundFile "$(win_path "$SOUND_FILE")")
  [ "$CHECK_FOCUS" = 1 ] && args+=(-SkipIfFocused)
  powershell.exe "${args[@]}" </dev/null
}
send_desktop() {
  case "$PLATFORM" in
    mac)
      osascript -e 'on run argv' -e 'display notification (item 2 of argv) with title (item 1 of argv)' \
        -e 'end run' "$TITLE" "${BODY:- }" ;;
    linux)
      command -v notify-send >/dev/null 2>&1 || { log "desktop: notify-send not installed"; return 1; }
      local urgency=normal
      [ "$KIND" = needs ] || [ "$KIND" = error ] && urgency=critical
      notify-send -a "Claude Code" -i dialog-information -u "$urgency" -t 10000 "$TITLE" "$BODY" ;;
  esac
}
send_sound() {
  local f=$SOUND_FILE
  [ -f "$f" ] || { log "sound: file not found: $f"; return 1; }
  case "$PLATFORM" in
    mac) afplay -v "$VOLUME" "$f" ;;
    linux)
      if command -v pw-play >/dev/null 2>&1; then pw-play --volume "$VOLUME" "$f"
      elif command -v paplay >/dev/null 2>&1; then paplay --volume="$(awk -v v="$VOLUME" 'BEGIN{printf "%d", v*65536}')" "$f"
      elif command -v aplay >/dev/null 2>&1; then aplay -q "$f"
      elif command -v canberra-gtk-play >/dev/null 2>&1; then canberra-gtk-play -f "$f"
      else log "sound: no player found (install pipewire, pulseaudio-utils or alsa-utils)"; return 1; fi ;;
  esac
}
send_ntfy() {
  local topic="${CLAUDE_NOTIFY_NTFY_TOPIC:-$(conf ntfy_topic "")}" server token
  server=$(conf ntfy_server "https://ntfy.sh")
  token="${CLAUDE_NOTIFY_NTFY_TOKEN:-}"
  [ -n "$topic" ] || { log "ntfy: no topic (set CLAUDE_NOTIFY_NTFY_TOPIC or ntfy_topic)"; return 1; }
  local url="${server%/}/$topic" msg="${BODY:-$NTFY_TITLE}"
  if command -v curl >/dev/null 2>&1; then
    local auth=()
    [ -n "$token" ] && auth=(-H "Authorization: Bearer $token")
    curl -fsS -m 8 -o /dev/null -H "Title: $NTFY_TITLE" -H "Priority: $PRIORITY" -H "Tags: $TAGS" \
      "${auth[@]}" --data-binary "$msg" "$url"
  elif command -v wget >/dev/null 2>&1; then
    local auth=()
    [ -n "$token" ] && auth=(--header="Authorization: Bearer $token")
    wget -q -T 8 -O /dev/null --header="Title: $NTFY_TITLE" --header="Priority: $PRIORITY" \
      --header="Tags: $TAGS" "${auth[@]}" --post-data="$msg" "$url"
  else
    log "ntfy: neither curl nor wget available"; return 1
  fi
}
dispatch() { # dispatch "<space separated channels>"
  local chans=" $1 " win=""
  if [ "$PLATFORM" = wsl ] || [ "$PLATFORM" = gitbash ]; then
    case "$chans" in *" desktop "*) win="desktop" ;; esac
    case "$chans" in *" sound "*) win="${win:+$win,}sound" ;; esac
    [ -n "$win" ] && { send_windows "$win" && log "sent: $win (via notify.ps1)" || log "failed: $win"; } &
  else
    case "$chans" in *" desktop "*) { send_desktop && log "sent: desktop" || log "failed: desktop"; } & ;; esac
    case "$chans" in *" sound "*) { send_sound && log "sent: sound" || log "failed: sound"; } & ;; esac
  fi
  case "$chans" in *" ntfy "*) { send_ntfy && log "sent: ntfy" || log "failed: ntfy"; } & ;; esac
  wait
}

# ---------------------------------------------------------------- main
main() {
  is_true "$(conf debug false)" && DEBUG=1
  [ "${CLAUDE_NOTIFY:-1}" = "0" ] && [ "$TEST_MODE" = 0 ] && return 0
  if ! is_true "$(conf enabled true)"; then
    log "disabled (enabled=false in $CONF)"
    return 0
  fi

  local key="" short="" detail="" emoji="" force=0
  is_true "${CLAUDE_NOTIFY_FORCE:-0}" && force=1

  if [ "$TEST_MODE" = 1 ]; then
    force=1
    EVENT=Test CWD=$PWD SESSION=test
    case "${2:-done}" in
      needs) KIND=needs emoji="🔐" short="test: needs you" TAGS=closed_lock_with_key PRIORITY=high ;;
      error) KIND=error emoji="❌" short="test: error" TAGS=x PRIORITY=high ;;
      *) KIND=done emoji="✅" short="test: done" TAGS=white_check_mark PRIORITY=default ;;
    esac
    detail="This is a claude-notify test alert."
  else
    INPUT=$(cat)
    parse_input
    case "$EVENT" in
      UserPromptSubmit)
        [ -n "$SESSION" ] && mkdir -p "$STATE_DIR" 2>/dev/null && now >"$STATE_DIR/$SESSION.start" 2>/dev/null
        return 0 ;;
      Notification)
        case "$NTYPE" in
          permission_prompt) key=permission KIND=needs emoji="🔐" short="needs permission" detail=$MESSAGE TAGS=closed_lock_with_key PRIORITY=high ;;
          idle_prompt) key=idle KIND=needs emoji="⏳" short="waiting for your input" detail=$MESSAGE TAGS=hourglass_flowing_sand PRIORITY=high ;;
          elicitation_dialog) key=elicitation KIND=needs emoji="📝" short="MCP server needs input" detail=$MESSAGE TAGS=memo PRIORITY=high ;;
          *) return 0 ;;
        esac ;;
      PreToolUse)
        [ "$TOOL" = "AskUserQuestion" ] || return 0
        key=question KIND=needs emoji="❓" short="Claude asked a question" detail=$QUESTION TAGS=question PRIORITY=high ;;
      Stop)
        [ "$STOP_ACTIVE" = "true" ] && return 0
        key=stop KIND=done emoji="✅" short="done" TAGS=white_check_mark PRIORITY=default
        detail=$(truncate_text "$(conf summary_chars 150)" "$LAST_MSG") ;;
      StopFailure)
        key=failure KIND=error emoji="❌" short="stopped (${ERROR:-API error})" TAGS=x PRIORITY=high
        detail=$(truncate_text 150 "$LAST_MSG") ;;
      SessionEnd)
        [ -n "$SESSION" ] && rm -f "$STATE_DIR/$SESSION.start" "$STATE_DIR/$SESSION.last" 2>/dev/null
        key=session_end KIND=done emoji="👋" short="session ended" detail=${REASON:+reason: $REASON} TAGS=wave PRIORITY=low ;;
      *) return 0 ;;
    esac
    local def=true
    [ "$key" = session_end ] && def=false
    is_true "$(conf "event_$key" "$def")" || { log "$EVENT/$key: event disabled"; return 0; }
  fi

  local project
  project=$(basename "${CWD:-$PWD}")
  TITLE="$emoji $project: $short"
  NTFY_TITLE="$project: $short"
  BODY=$detail
  VOLUME=$(conf sound_volume 0.6)
  case "$KIND" in
    needs) SOUND_FILE=$(conf sound_needs_you "$SCRIPT_DIR/sounds/needs-you.wav") ;;
    error) SOUND_FILE=$(conf sound_error "$SCRIPT_DIR/sounds/error.wav") ;;
    *) SOUND_FILE=$(conf sound_done "$SCRIPT_DIR/sounds/done.wav") ;;
  esac

  local channels=""
  is_true "$(conf channel_desktop true)" && channels="$channels desktop"
  is_true "$(conf channel_sound true)" && channels="$channels sound"
  is_true "$(conf channel_ntfy false)" && channels="$channels ntfy"
  drop() { channels=$(printf ' %s ' "$channels" | sed -E "s/ $1 / /g; s/^ +//; s/ +$//"); }

  CHECK_FOCUS=0
  if [ "$force" = 0 ]; then
    local t dd min
    t=$(now)
    # dedupe (never drop errors)
    dd=$(conf dedupe_seconds 5)
    if [ "${dd:-0}" -gt 0 ] 2>/dev/null && [ "$KIND" != error ] && [ -n "$SESSION" ]; then
      local last
      last=$(cat "$STATE_DIR/$SESSION.last" 2>/dev/null)
      if [ -n "$last" ] && [ $((t - last)) -lt "$dd" ]; then log "$EVENT: deduped ($((t - last))s since last alert)"; return 0; fi
    fi
    # minimum turn length for Stop
    min=$(conf min_turn_seconds 120)
    if [ "$EVENT" = Stop ] && [ "${min:-0}" -gt 0 ] 2>/dev/null && [ -f "$STATE_DIR/$SESSION.start" ]; then
      local start dur c
      start=$(cat "$STATE_DIR/$SESSION.start" 2>/dev/null)
      dur=$((t - ${start:-$t}))
      if [ "$dur" -lt "$min" ]; then
        for c in $(conf min_turn_channels ntfy | tr ',' ' '); do drop "$c"; done
        log "Stop: short turn (${dur}s < ${min}s), dropped: $(conf min_turn_channels ntfy)"
      fi
    fi
    # ntfy only for idle/errors
    if is_true "$(conf ntfy_only_idle_and_errors false)" && [ "$key" != idle ] && [ "$KIND" != error ]; then drop ntfy; fi
    # quiet hours mute sound
    if in_quiet_hours "$(conf quiet_hours "")"; then drop sound; log "quiet hours: sound muted"; fi
    # focus: skip local channels
    if is_true "$(conf skip_local_when_focused true)"; then
      if [ "$PLATFORM" = wsl ] || [ "$PLATFORM" = gitbash ]; then
        CHECK_FOCUS=1
      elif terminal_is_focused; then
        drop desktop; drop sound; log "terminal focused: skipped desktop+sound"
      fi
    fi
  fi

  channels=$(printf '%s' "$channels" | sed -E 's/^ +//; s/ +$//')
  log "$EVENT${NTYPE:+/$NTYPE} [$PLATFORM] → '${channels:-none}' | $TITLE | $BODY"
  [ -n "$channels" ] || return 0
  [ -n "$SESSION" ] && mkdir -p "$STATE_DIR" 2>/dev/null && now >"$STATE_DIR/$SESSION.last" 2>/dev/null

  if [ "$TEST_MODE" = 1 ]; then
    dispatch "$channels"
  else
    # Detach so Claude is never kept waiting on sound playback or the network.
    (dispatch "$channels") </dev/null >/dev/null 2>&1 &
    disown 2>/dev/null
  fi
  return 0
}

main "$@" 2>/dev/null
exit 0
