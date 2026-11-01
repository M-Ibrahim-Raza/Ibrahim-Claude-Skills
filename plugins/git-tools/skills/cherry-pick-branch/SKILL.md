---
name: cherry-pick-branch
description: Prepare a clean PR-ready branch by cherry-picking a feature branch's commits from the branch it was QA'd on (e.g. staging) onto a fresh branch off the production branch (e.g. main). Branch name is required as input, asked for if missing; source and target branches default to staging and main but can be overridden. Use when the user says "make a PR of main of this branch <branch>", "promote <branch> to main", or "/cherry-pick-branch <branch>".
argument-hint: <branch> [source-branch] [target-branch]
---

# Cherry Pick Branch

You are helping prepare a production PR branch. A feature branch has been merged to the **source branch** (QA branch, default `staging`) and now needs a clean branch off the **target branch** (production branch, default `main`) with the same commits.

## Step 1 — Parse arguments

Extract from `$ARGUMENTS`:
- `<branch>` — the feature branch. If missing, ask the user for it before continuing.
- `<source-branch>` — the branch the feature was merged into for QA. Defaults to `staging` if not given.
- `<target-branch>` — the production branch to base the new branch on. Defaults to `main` if not given.

## Step 2 — Fetch latest remote state

```bash
git fetch origin
```

## Step 3 — Verify `<branch>` is merged into `origin/<source-branch>`

```bash
git branch -r --merged origin/<source-branch> | grep "<branch>"
```

If the output is empty, **abort** with this message:

> "`<branch>` does not appear to be merged into `<source-branch>`. Verify the branch name and that it has been merged to `<source-branch>`, then try again."

Do not continue past this point if the check fails.

## Step 4 — Collect commits to cherry-pick

⚠️ **Critical:** `git log origin/<target-branch>..<branch>` is **wrong** here. Feature branches are typically cut from `<source-branch>`, so that range pulls in every `<source-branch>`-vs-`<target-branch>` commit, not just the feature's commits. Use the source-branch merge commit instead.

### 4a — Find the merge commit on `<source-branch>` that brought in `<branch>`

Walk `origin/<source-branch>`'s first-parent merges and find the one whose 2nd parent matches the branch tip:

```bash
BRANCH_TIP=$(git rev-parse origin/<branch>)
MERGE_SHA=$(git log origin/<source-branch> --first-parent --merges --pretty="%H %P" \
  | awk -v tip="$BRANCH_TIP" '{ for (i=2; i<=NF; i++) if ($i==tip) { print $1; exit } }')
echo "$MERGE_SHA"
```

### 4b — Derive the commit list from the merge commit

If `MERGE_SHA` is non-empty, the branch's commits are exactly:

```bash
git log "${MERGE_SHA}^1..${MERGE_SHA}^2" --no-merges --reverse --oneline
```

This gives only the commits introduced by `<branch>` itself, regardless of how many `<source-branch>` commits accumulated before/after.

### 4c — Fallback when no merge commit is found

If `MERGE_SHA` is empty, the branch was likely **squash-merged** or rebased — there is no preserved branch history on `<source-branch>`. **Abort** with:

> "Could not find the merge commit on `origin/<source-branch>` that brought in `<branch>`. The branch may have been squash-merged. Please tell me the specific commit SHA(s) to cherry-pick, or share the squash-merge commit on `<source-branch>`."

Do not fall back to `origin/<target-branch>..<branch>` — that range is unreliable when the branch was based on `<source-branch>`.

### 4d — Sanity-check the count

If the list contains **more than 30 commits**, treat it as suspicious. Show the count and the first/last few entries, and ask the user to confirm this is really one feature's worth of commits before proceeding. A typical feature branch yields 1–20 commits; a much larger number usually indicates the wrong merge commit was matched (e.g., a branch-into-branch merge) or that `<source-branch>` was merged into the feature.

### 4e — Confirm with the user

If zero commits are returned, **abort** with:

> "No commits found between `${MERGE_SHA}^1..${MERGE_SHA}^2`. Nothing to cherry-pick."

Otherwise, show the full commit list to the user in a code block and **ask for explicit confirmation** before proceeding:

> "Found the `<source-branch>` merge commit `<MERGE_SHA>` (`<short message>`).
> N commit(s) to cherry-pick onto a new branch `<branch>_<target-branch>` based off `origin/<target-branch>`:
> ```
> <commit list>
> ```
> Proceed?"

Wait for the user to confirm before continuing.

## Step 5 — Create new branch from `origin/<target-branch>`

```bash
git checkout -b <branch>_<target-branch> origin/<target-branch>
```

## Step 6 — Cherry-pick each commit

Cherry-pick every commit from the list collected in Step 4, **in order** (oldest first), using the `-x` flag to record the origin commit hash:

```bash
git cherry-pick -x <sha>
```

Run one cherry-pick per commit. Do not batch them with a range unless the range exactly matches the list (ranges can silently include unintended commits if `<branch>` has a non-linear history).

**On conflict:** Stop immediately. Show the conflicting files:

```bash
git status
```

Tell the user:

> "Cherry-pick of `<sha>` (`<short message>`) hit a conflict. Conflicting files:
> `<list>`
> Please resolve the conflicts, then run `git cherry-pick --continue`. Let me know when done and I'll push the branch."

Do not continue automatically after a conflict — wait for the user.

## Step 7 — Push branch

```bash
git push origin <branch>_<target-branch>
```

Never use `--force`. The branch is new so a normal push is always sufficient.

## Step 8 — Report

Confirm success:

> "Done. Branch `<branch>_<target-branch>` has been pushed to origin with N cherry-picked commit(s). You can now open a PR from `<branch>_<target-branch>` → `<target-branch>`."
