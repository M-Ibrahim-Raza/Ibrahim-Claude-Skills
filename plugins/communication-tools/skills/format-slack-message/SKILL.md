---
name: format-slack-message
description: Format a given message for Slack by bolding important words with double asterisks and wrapping code-like terms (variables, functions, file paths, commands, values) in backticks — without changing the wording. Use when the user says "format this for Slack", "slack-format", "bold the important words", "add code formatting", or "/format-slack-message".
---

# Slack Message Formatter

Take the message the user gives you and format it for Slack. You change only the markup — the bold, the inline code and the links. You never change the words.

## The one hard rule: do not change the message

Do not reword, reorder, add, or remove a single word. Do not fix grammar, spelling, punctuation, or casing. Do not "improve" or rewrite anything. The only edits you make are inserting `**…**` around words to bold them, `` `…` `` around code-like terms, and turning bare URLs into `[url](url)` links. When you wrap a term in backticks, keep its inner text exactly as written.

If nothing in the message warrants formatting, return the message unchanged.

## What you output

Output ONLY the formatted message, inside a fenced code block, and nothing else.

- No preamble like "Here is your message" or "Sure!"
- No explanation of what you bolded or backticked
- No summary at the end

The code block is required so the literal `*` and backticks survive copy-paste — the user pastes the raw text into Slack. Do not attempt to post to Slack; it is not connected.

## Bold the important terms

Bold uses **double asterisks**: `**term**`. Slack converts pasted Markdown, so a single `*term*` renders as italic.

Density is moderate — bold every notable term, roughly one per clause. Bold things like:

- the subject or feature being talked about
- key outcomes: done, shipped, deployed, ready for testing, failed, broken, blocked
- warnings and anything the reader must not miss
- numbers or quantities that matter
- the names of things being acted on

Do not bold whole sentences, links, or terms you have already wrapped in backticks. Do not stack bold on code — a term is either code (backticks) or prose emphasis (bold), not both.

## Make URLs clickable

A bare URL is not clickable after pasting. Write each one as a Markdown link with the URL as its text: `[https://example.com/x](https://example.com/x)`. Leave links that are already in `[text](url)` form as they are.

## Wrap code-like terms in backticks

Wrap these in `` ` ` ``:

- **Identifiers** — camelCase, snake_case, PascalCase, or any obvious code symbol: function, variable, class, and method names (e.g. `getUserById`, `tenant_id`, `UserService`).
- **File paths & extensions** — `src/utils/foo.ts`, bare filenames, and extensions like `.env`, `package.json`.
- **Commands & flags** — `yarn build`, `git push`, `--force`.
- **Values & literals** — booleans, config numbers, enum values, env var names like `DATABASE_URL`, and quoted string values referenced as literals.

Wrap the whole token as one unit (the full path, or the `command + flag` together). Keep the inner text exactly as written. Do not double-wrap, and do not backtick ordinary English words that merely look technical.

## Examples

### Bad (single asterisks — render as italic after pasting)
> The *deploy failed* because *DATABASE_URL* was missing.

### Good (double asterisks + backticks)
> The **deploy failed** because `DATABASE_URL` was **missing**.

---

### Bad (reworded — grammar was "fixed", words changed)
Input: `we was gonna update getConfig but the .env file broke`
> We were going to update the `getConfig` function, but the `.env` file **broke**.

### Good (only markup added — awkward wording kept exactly)
> we was gonna update `getConfig` but the `.env` file **broke**

---

### Bad (whole sentence bolded, code left unformatted)
> **Run yarn build after fixing the config and the tests should pass.**

### Good (moderate bold, code in backticks, words unchanged)
> Run `yarn build` after fixing the **config** and the **tests** should pass.

---

### Bad (bare URL — not clickable after pasting)
> PR is up: https://github.com/aisetters/ml/pull/1152

### Good (URL as a Markdown link)
> PR is **up**: [https://github.com/aisetters/ml/pull/1152](https://github.com/aisetters/ml/pull/1152)
