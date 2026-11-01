---
name: format-clickup-message
description: Format a given message for ClickUp by bolding important words with double asterisks and wrapping code-like terms (variables, functions, file paths, commands, values, named message types) in backticks — without changing the wording. Use when the user says "format this for ClickUp", "clickup-format", "bold the important words", "add code formatting", or "/format-clickup-message".
---

# ClickUp Message Formatter

Take the message the user gives you and format it for ClickUp. You change only the markup — the bold and the inline code. You never change the words.

## The one hard rule: do not change the message

Do not reword, reorder, add, or remove a single word. Do not fix grammar, spelling, punctuation, or casing. Do not "improve" or rewrite anything. The only edits you make are inserting `**…**` around words to bold them and `` `…` `` around code-like terms. When you wrap a term in backticks, keep its inner text exactly as written.

If nothing in the message warrants bold or code formatting, return the message unchanged.

## What you output

Output ONLY the formatted message as plain text (no surrounding fenced code block), and nothing else.

- No preamble like "Here is your message" or "Sure!"
- No explanation of what you bolded or backticked
- No summary at the end

Do not attempt to post to ClickUp; it is not connected.

## Bold the important terms

Use **double asterisks**: `**term**`. This renders as bold in ClickUp.

Density is moderate — bold every notable term, roughly one per clause. Bold things like:

- the subject or feature being talked about
- key outcomes: done, shipped, deployed, ready for testing, failed, broken, blocked
- warnings and anything the reader must not miss
- numbers or quantities that matter
- the names of things being acted on

Do not bold whole sentences, links, or terms you have already wrapped in backticks. Do not stack bold on code — a term is either code (backticks) or prose emphasis (bold), not both.

## Wrap code-like terms in backticks

Wrap these in `` ` ` ``:

- **Identifiers** — camelCase, snake_case, PascalCase, or any obvious code symbol: function, variable, class, and method names (e.g. `getUserById`, `tenant_id`, `UserService`).
- **File paths & extensions** — `src/utils/foo.ts`, bare filenames, and extensions like `.env`, `package.json`.
- **Commands & flags** — `yarn build`, `git push`, `--force`.
- **Values & literals** — booleans, config numbers, enum values, env var names like `DATABASE_URL`, and quoted string values referenced as literals.
- **Named system/message types** — domain-specific named concepts that act as proper nouns for system components or message types.

### Terms to wrap
- autobooking
- autobooks
- charlie-engine
- aisetters-web
- queue-manager
- engine
- ml
- confirmation request message
- confirmation response message
- post booking confirmation message

Wrap the whole token as one unit (the full path, or the `command + flag` together). Keep the inner text exactly as written. Do not double-wrap, and do not backtick ordinary English words that merely look technical.

## Examples

### Input
> One thing to flag — the post booking confirmation message currently has a question asking the lead to confirm the appointment. That is not the right place for it.
>
> The post booking confirmation message is meant to inform the lead about the booking — nothing more. The confirmation request is handled separately by the confirmation request message, which is already designed for that purpose.
>
> So we do not need a confirmation question in the post booking confirmation message. Let us keep each message focused on its own role.

### Output
> One thing to **flag** — the `post booking confirmation message` currently has a **question asking the lead to confirm the appointment**. That is **not** the right place for it.
>
> The `post booking confirmation message` is meant to **inform the lead about the booking** — nothing more. The **confirmation request** is handled separately by the `confirmation request message`, which is already designed for that purpose.
>
> So we do **not** need a confirmation question in the `post booking confirmation message`. Let us keep each message **focused on its own role**.

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
