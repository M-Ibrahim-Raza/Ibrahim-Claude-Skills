---
name: open-pr
description: Open a GitHub pull request for the current branch with gh, following PR best practices — checks for an existing PR, self-reviews the diff, drafts a clear title and description (using the repo's PR template if there is one), confirms with the user, pushes via /push-branch, then runs gh pr create. Base branch is optional and defaults to the repo's default branch. Use when the user asks to open a PR, create a PR, make a pull request, or says "/open-pr".
argument-hint: [base-branch]
---

# Open PR

Opens a pull request from the current branch with `gh`, written so reviewers can understand it quickly.

## Workflow
1. Pre-checks:
   - `gh auth status` — if not logged in, stop and tell the user to run `gh auth login`.
   - `git branch --show-current` — if empty (detached HEAD), stop and tell the user to check out a branch first.
   - `git status --porcelain` — if the working tree is dirty, warn that uncommitted changes will not be in the PR, then continue.
2. Pick the base branch: use `$ARGUMENTS` if given, otherwise the repo's default branch from `gh repo view --json defaultBranchRef --jq .defaultBranchRef.name`. If the current branch is the base branch, stop and tell the user to switch to a feature branch.
3. Check for an existing PR with `gh pr view --json url,state`. If its state is `OPEN`, show its URL and stop — new commits only need `/push-branch`. If there is none, or it is merged or closed, continue.
4. Collect what goes in:
   - `git fetch origin`
   - `git log origin/<base>..HEAD --oneline` — if empty, tell the user there is nothing to open a PR for and stop.
   - `git diff origin/<base>...HEAD --stat` — if it is large (around 400+ changed lines), suggest splitting it into smaller PRs, but do not block.
5. Self-review the diff with `git diff origin/<base>...HEAD`. Flag debug code, commented-out blocks, secrets or `.env` files, and files unrelated to the change. Report them only — do not fix anything.
6. Draft the title in the same format as `/commit`: `<type>(<optional scope>): <summary>`, imperative mood, under 72 characters, and specific about what changed. Squash merges often reuse the PR title as the commit message.
7. Draft the body:
   - If the repo has a PR template (`pull_request_template.md` in `.github/`, `docs/`, or the root, any case, or a file in `.github/PULL_REQUEST_TEMPLATE/`), fill it in.
   - Otherwise use these sections: **Summary** (why the change is needed and what it does), **Changes**, **How to test**, and **Notes for reviewers** (where to start and what kind of feedback you want).
   - Add `Closes #<issue>` when the issue number is known.
8. Confirm: show `<branch>` → `<base>`, the title, the body, the commit list, and anything flagged in step 5. Wait for the user to approve before continuing.
9. Push the branch via `/push-branch`. If it stops (protected branch, diverged remote, rejected push), stop here too.
10. Create the PR:
    ```bash
    gh pr create --base <base> --head <branch> --title "<title>" --body-file - <<'EOF'
    <body>
    EOF
    ```
    - Add `--draft` only when the user asks for a draft.
    - Add `--reviewer`, `--label`, or `--assignee` only when the user names them.
11. Report the PR URL that `gh pr create` prints.

## Safety
- Never hand back the compare link that `git push` prints, and never use `--web` — create the PR yourself.
- Never add an AI attribution line ("Generated with Claude" or similar) to the PR body.
- Never merge, approve, or close PRs.
- Never make up reviewers, labels, or issue numbers.
- If `gh pr create` fails, stop and report the error.
