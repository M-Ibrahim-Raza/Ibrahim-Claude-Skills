# Reviewer Briefs

The reviewer reads the diff cold. Fill the template from the files and send it as the reviewer subagent's prompt. Don't add this session's history or the implementer's reasoning.

### Task Reviewer

````markdown
You are reviewing one finished task of an approved plan. Don't edit any file. Report findings only.

## Read First
- Spec: `<path>/spec.md`
- Plan: `<path>/plan.md` › <sections this task points to>
- The task: <paste the full task from tasks.md>
- Best practices: `best_practices/react.md` (§18 PR review checklist) and `best_practices/typescript.md` (§17 Definition of done), plus the sections this task's code falls under

## What Changed
- Repo: `<absolute path of the repo root>`
- Diff: run `git diff -- <task files>` (and `git status` for new files)
- Done check output: <paste>

## Check
1. **Task fit:** does the diff do every step of the task, and nothing beyond it?
2. **Spec fit:** does the behavior match the ACs this task covers? Any conflict with spec.md or plan.md?
3. **Scope:** any file changed that the task doesn't list?
4. **Tests:** do the tests really prove the ACs? Any test skipped, deleted, weakened, or asserting nothing?
5. **Comments:** any comment or doc that mentions ACs, requirement IDs or spec details?
6. **Quality:** bugs, missed edge cases from spec.md, broken existing patterns, dead code
7. **Best practices:** any break of a MUST/DO rule in `best_practices/`

## Report Back
- **Verdict:** PASS | FINDINGS
- **Findings:** for each: file and line, what is wrong, why it matters, the fix. Mark each `must fix` or `minor`
````

- `must fix` findings go to a fix round
- `minor` findings go to a fix round only if they're cheap; otherwise log them in the Progress Log and list them in the Implementation Summary

### Final Reviewer

Use the same template with these changes:

- **What Changed:** the full diff of the repo (`git diff` and `git status` for new files)
- **Check:** every AC in spec.md is met and proven by a test; every file in plan.md's File Structure is handled; nothing in Out-of-Scope Boundaries changed; tasks fit together (interfaces match across tasks and modules); plus checks 4–7 above
- **Report Back:** add an AC table: `AC | met? | proving test | notes`
