---
name: tech-stack-mapper
description: Analyze an application codebase and produce a tech stack markdown file listing the languages, frameworks, libraries, tooling and services it actually uses, grouped by domain.
argument-hint: "[optional: repo path] [optional: stack file path]"
disable-model-invocation: true
---

# Tech Stack Mapper

Build an accurate stack file from what the codebase really installs and uses, so later decisions start from facts.

Input: $ARGUMENTS (may hold a repo path, a stack file path, both, or nothing).

Ask every question with `AskUserQuestion`, giving 2–4 options with your recommended one listed first and marked "(Recommended)". Don't ask what the repo already answers.

## 1. Confirm the codebase
- Use the given path, or the current working directory if none was given.
- Check that the path holds code (manifests, source folders) and confirm it with the user. If no code is found, ask for the correct path.

## 2. Define scope
- Detect apps and packages: workspaces, multiple manifests, service folders.
- Ask which to include and which to skip (examples, vendored code, generated code). Recommend the app code and its shared packages.

## 3. Scan
- Sources: manifests (package.json, pyproject.toml, requirements*.txt, go.mod, Cargo.toml, etc.), lockfiles, config files (tsconfig, linters, test runners, bundlers, Dockerfile, compose, CI workflows, IaC, .env.example), and imports in source.
- Include a tool only if it is in a manifest AND it is imported in code or wired into config or scripts. Unused dependencies go in the review notes, not the file.
- Cover four kinds of tools: runtime libraries; dev tooling (test, lint, format, build); infra and services (databases, containers, CI, cloud/SaaS); and languages, runtimes and the package manager.
- Versions: use the exact resolved version from the lockfile. If there is none, use the manifest range and mark it as a range.
- Why, Alternatives considered and Decided: infer these only when the code or docs make them clear (README, ADRs, comments). Otherwise write `-`. Never guess.

## 4. Confirm the file
- Path: if a stack file exists (the path given, or `tech_stack.md` and close variants), propose updating it. Otherwise recommend `tech_stack.md` at the repo root. Confirm the name and path.
- Format: recommend the existing file's format if there is one, otherwise the default below. Confirm before drafting.
- Existing file: add missing tools only and never rewrite existing entries. List outdated versions in the review notes.

Default format, with one heading per domain and its tools beneath it:
`## <Domain>` (e.g. `## Data Visualization`)
`- **<Tool>** v<version> — <purpose>. Why: <reason or ->. Alternatives considered: <tools or ->. Decided: <YYYY-MM-DD or ->.`
Name domains by the need, not the tool, so future entries land under the same heading. If the scoped apps have different stacks, give each app a `# <App>` section, plus `# Shared` for common tools, with domain headings beneath each.

## 5. Review, then write
- Show the full draft (or, for an existing file, exactly the lines to be added) plus brief notes: unused dependencies skipped, version mismatches, and anything uncertain.
- Ask whether to accept, request changes, or cancel. Revise until the user accepts.
- Write the file only after acceptance, then report its path.