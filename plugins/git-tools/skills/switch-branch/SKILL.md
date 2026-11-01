---
name: switch-branch
description: Switch the current repo to a target git branch, creating it if it does not exist, stashing any local changes first and restoring them after. Branch name is provided as input; if not given, ask for it. Use when the user asks to switch branch, checkout a branch, or says "/switch-branch".
argument-hint: <branch>
---

# Switch Branch

Switches the current repository to the given branch, pulling the latest from `origin/<branch>`, without losing any uncommitted work.

## Branch argument
The target branch is `$ARGUMENTS`. If `$ARGUMENTS` is empty, ask the user which branch to switch to before doing anything else.

## Workflow
1. Check for uncommitted changes with `git status --porcelain`. If the working tree is dirty, stash everything — staged, unstaged, and untracked — with `git stash push -u -m "auto-stash before switching to <branch>"`.
2. Fetch and switch to the target branch:
   - `git fetch origin`
   - If the branch exists locally (`git show-ref --verify --quiet refs/heads/<branch>`), run `git checkout <branch>`.
   - If it exists only on origin (`git show-ref --verify --quiet refs/remotes/origin/<branch>`), run `git checkout -b <branch> origin/<branch>`.
   - If it exists in neither place, create it from the current branch with `git checkout -b <branch>`, tell the user it is a new branch, and skip the pull below.
   - `git pull origin <branch>` so the branch matches `origin/<branch>` exactly — origin is the source of truth.
3. If changes were stashed in step 1, restore them with `git stash pop`.
   - If the pop succeeds, tell the user their changes were restored.
   - If it conflicts, warn the user and leave the stash in place so they can resolve it manually with `git stash pop`.

## Safety
- Never discard the stash on your own if `stash pop` conflicts — leave it for the user to resolve.
- If the checkout or pull fails, stop and report the error instead of continuing.
