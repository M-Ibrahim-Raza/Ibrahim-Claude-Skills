---
name: merge-pr
description: Merge a GitHub pull request with gh and optionally delete its branch. Finds the PR from a link or number, a PR opened or linked earlier in the chat, or the current branch; checks it is open, approved, conflict-free and green; then asks the user for the merge method (normal merge by default) and whether to delete the branch before doing anything. Use whenever the user wants to merge, land, or ship a pull request — even a bare "merge it" right after /open-pr — or says "/merge-pr".
argument-hint: [pr-url | pr-number] [merge | squash | rebase]
---

# Merge PR

Merging and deleting a branch are hard to undo, so the user approves both before anything runs.

## Workflow
1. Pick the PR: `$ARGUMENTS` (URL or number), else a PR opened or linked earlier in this chat, else the current branch's PR (`gh pr view`). If none or several fit, ask. Stop if `gh auth status` fails.
2. Read it: `gh pr view <pr> --json number,url,title,state,isDraft,baseRefName,headRefName,headRefOid,isCrossRepository,mergeable,mergeStateStatus,reviewDecision` and `gh pr checks <pr>`.
3. Stop and report if it is not `OPEN`, is a draft, or is `CONFLICTING`. Report failing checks, `CHANGES_REQUESTED` or missing approval, and `BEHIND` without fixing them. If checks are only pending, offer `--auto`.
4. Method: use the user's choice (`merge`, `squash`, `rebase`) from `$ARGUMENTS` or the chat, otherwise a normal merge commit. Check what the repo allows with `gh repo view --json mergeCommitAllowed,squashMergeAllowed,rebaseMergeAllowed`.
5. Ask once, showing `<head>` → `<base>`, the title, and anything from step 3:
   - Method: if already chosen, **Merge with <method>** / **Cancel**; otherwise only allowed ones: **Merge commit (default)** / **Squash** / **Rebase** / **Cancel**.
   - Branch: **Delete** / **Keep**. Offer delete only for a same-repo head that is not protected (`main`, `master`, `develop`, `staging`, `production`, `release/*`).
6. Run `gh pr merge <pr> --<method> --match-head-commit <headRefOid>`, plus `--delete-branch` / `--auto` if chosen. Pinning the head commit makes a push after the user's yes fail the merge instead of landing code they never saw; if that happens, ask again.
7. Report the PR URL, `gh pr view <pr> --json state,mergeCommit`, and whether the branch was deleted. With `--auto`, say it merges once requirements pass.

## Safety
- Never approve PRs or use `--admin`: it bypasses the reviews and checks the team relies on.
- If `gh pr merge` fails, stop and report the error rather than retrying with other flags.
