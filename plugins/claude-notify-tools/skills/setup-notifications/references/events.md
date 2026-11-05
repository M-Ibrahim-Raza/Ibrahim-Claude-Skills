# Hook events used by claude-notify

Source: Claude Code hooks reference, https://code.claude.com/docs/en/hooks.md. Check it again if Claude Code changes event names.

## Events and their alerts

| Situation | Event | Matcher | Kind / chime | `notify.conf` key |
|---|---|---|---|---|
| Needs permission | `Notification` | `permission_prompt` | needs-you | `event_permission` |
| Waiting 60s+ for input | `Notification` | `idle_prompt` | needs-you | `event_idle` |
| MCP server needs input | `Notification` | `elicitation_dialog` | needs-you | `event_elicitation` |
| Claude asked a question | `PreToolUse` | `AskUserQuestion` | needs-you | `event_question` |
| Turn finished | `Stop` | none (no matcher support) | done | `event_stop` |
| Turn ended on API error | `StopFailure` | none (all errors) | error | `event_failure` |
| Session closed | `SessionEnd` | none (all reasons) | done | `event_session_end` (off by default) |
| Turn timer for the min-duration filter | `UserPromptSubmit` | none | no alert | registered only when `min_turn_seconds > 0` |

These are deliberately not used:
- `auth_success`: noise.
- `PermissionRequest` and `Elicitation`: they fire for the same moments as the Notification matchers above, so every alert would arrive twice.

## stdin fields the handlers read

Every event includes `hook_event_name`, `session_id`, `cwd`, and `transcript_path`. The handlers also read:

| Event | Fields |
|---|---|
| Notification | `notification_type`, `message`, `title` |
| PreToolUse | `tool_name`, `tool_input.questions[0].question` |
| Stop | `stop_hook_active`, `last_assistant_message` |
| StopFailure | `error` (`rate_limit`, `overloaded`, `authentication_failed`, `billing_error`, `server_error`, `unknown`, …), `last_assistant_message` |
| SessionEnd | `reason` (`clear`, `resume`, `logout`, `prompt_input_exit`, `other`) |
| UserPromptSubmit | `prompt` (not used, only timed) |

## Rules the handlers follow

- **Always exit 0 and print nothing.** Exit 2 from Stop would make Claude keep working. For PreToolUse, stdout could be read as a decision.
- **Skip `Stop` when `stop_hook_active` is true.** This avoids loops with other Stop hooks.
- **Give the SessionEnd hook its own timeout.** SessionEnd has a default budget of about 1.5 s, so the hook sets `timeout: 5`. The handler also detaches its sending work.
- **Notification hooks cannot block or change the notification.** They are purely side effects.
- **Hooks from user, project, local, and plugin settings all run.** An identical command in two settings files runs once. Different paths in two scopes run twice, so setup warns about double installs.
