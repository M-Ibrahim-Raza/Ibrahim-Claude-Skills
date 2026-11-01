---
name: commit
description: Write and create git commits following best practices. Use this skill whenever the user asks to commit, write a commit message, stage and commit changes, or says things like "commit this", "make a commit", or "/commit".
---

# Commit

## Workflow
1. Run `git status` and `git diff --staged` to understand exactly what is being committed; if nothing is staged, stage only the files relevant to the change.
2. Keep each commit atomic: one logical change per commit. Split unrelated changes into separate commits.
3. Commit with `git commit -m "<message>"` so the message stays on one line.

## Message format
- Write the message as a single line only — no body, no footer, no bullet points.
- Use the Conventional Commits format: `<type>(<optional scope>): <summary>`, where type is one of `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, or `revert`.
- Write the summary in the imperative mood ("add", "fix", "remove"), not past tense ("added", "fixed").
- Keep the entire line under 72 characters (aim for 50), start the summary lowercase, and omit the trailing period.
- Describe what changed and why it matters, not how; avoid vague messages like "update", "fix stuff", or "wip".

## Safety
- Never add Claude, Anthropic, or any AI as an author or co-author — no `Co-Authored-By` trailers, no "Generated with Claude" lines, and no `--author` overrides.
- Never commit secrets, credentials, `.env` files, or build artifacts; warn the user if any are staged.
