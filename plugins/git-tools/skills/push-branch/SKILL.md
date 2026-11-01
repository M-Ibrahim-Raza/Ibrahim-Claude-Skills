---
name: push-branch
description: Push the current git branch to origin safely — refuses protected branches, sets upstream on first push, shows the commits going out, and stops if the remote has diverged. Force-pushes only when explicitly asked, and then only with --force-with-lease. Use when the user asks to push, push the branch, publish the branch, or says "/push-branch".
---

# Push Branch

Pushes the current branch to `origin` without overwriting anyone else's work.

## Workflow
1. Check where you are:
   - `git branch --show-current` — if empty (detached HEAD), stop and tell the user to check out a branch first.
   - If the branch is protected (`main`, `master`, `develop`, `staging`, `production`, or `release/*`), refuse. Tell the user to move the work to a feature branch and open a PR instead.
   - `git status --porcelain` — if the working tree is dirty, warn that uncommitted changes will not be included, then continue with the committed work.
2. Fetch and compare with the remote:
   - `git fetch origin`
   - If `origin/<branch>` does not exist, this is a first push — go to step 4.
   - Otherwise count with `git rev-list --left-right --count HEAD...origin/<branch>` (ahead, behind).
   - If ahead is 0 and behind is 0, tell the user the branch is already up to date and stop.
3. If behind is greater than 0 (remote has commits you do not), stop. Show them with `git log HEAD..origin/<branch> --oneline` and ask whether to rebase (`git pull --rebase origin <branch>`) or merge (`git pull origin <branch>`). Continue only after it is integrated. Skip this step only if the user explicitly asked to force-push.
4. Show the commits that will be pushed with `git log HEAD --not --remotes --oneline`.
5. Push:
   - First push: `git push -u origin <branch>`
   - Normal push: `git push origin <branch>`
   - Force push (only when the user explicitly asked): `git push --force-with-lease --force-if-includes origin <branch>`. On Git older than 2.30, drop `--force-if-includes`.
6. Report the branch, the number of commits pushed, and whether upstream was set.

## Safety
- Never use plain `--force`, `-f`, or a `+<branch>` refspec — they disable every safety check.
- Never force-push unless the user explicitly asks for it in this request, and never to a protected branch.
- Never use `--no-verify`; if a pre-push hook fails, stop and report its output.
- Never rebase or merge on your own — always ask first.
- If the push is rejected, stop and report the error. Do not retry with force.
