---
name: tech-picker
description: Research, compare and recommend a tech tool (library, framework, service) for the user's application, then record the chosen tool in the project's tech stack file.
argument-hint: "[domain] [optional: tools to compare] [optional: stack file path]"
disable-model-invocation: true
---

# Tech Picker

Help the user pick the right tool for one need in their app, backed by current research, and record the decision.

Input: $ARGUMENTS (may hold a domain, tools to compare, a stack file path, any mix, or nothing).

## 1. Load app context
- Find the stack file. Use the path given in the input if there is one. Otherwise look for `tech_stack.md` and close variants (`TECH_STACK.md`, `tech-stack.md`, `stack.md`, also under `docs/`).
- If no stack file is found, use `AskUserQuestion` to ask for its name/path, or confirm there is none yet. Call the result "the stack file" from here on.
- Read the stack file. It is the source of truth for the language, runtime, frameworks and versions already chosen. Also note its format: headings, list or table, fields, and ordering.
- Skim manifests (package.json, pyproject.toml, requirements.txt, go.mod, etc.) to confirm versions. Don't ask what the repo already answers.

## 2. Clarify
- If no domain is given, ask for it and propose the most likely one based on the repo and the request.
- Ask only questions that change the answer, in one `AskUserQuestion` call (up to 4 questions, each with 2–4 likely options and a recommended default): the specific use case, hard constraints (license, budget, hosting, runtime, bundle size, team skills), expected scale, and must-have features.

## 3. Research (web search; weight signals from the last 12 months)
- No tools given: shortlist the 3–5 most popular, actively maintained options that meet the requirements.
- Tools given: research those, plus 1–2 strong options the user didn't name, labelled as additions.
- For each tool, gather: latest version and release date; compatibility with the stack (versions, runtime, types, SSR, etc.); maintenance (release cadence, open issues, number of maintainers); popularity and adoption trend (downloads, stars, notable users); recent reviews and community sentiment.
- Prefer official docs, package registries, GitHub and changelogs over listicles. Flag any tool that is deprecated, in maintenance mode, or recently re-licensed.

## 4. Compare and decide
Weigh fit and compatibility first, because a popular tool that clashes with the stack is a bad pick. Then weigh maintenance, then popularity, adoption and reviews. Think through the trade-offs before choosing.

## 5. Present findings
1. Comparison table: Tool | Version | Fit & compatibility | Maintenance | Popularity & adoption | Recent sentiment.
2. For each tool: 2–3 pros, 2–3 cons, and what it is best suited for.
3. Recommendation: the pick and why it wins for this app, plus the runner-up and when to choose it instead.
4. Sources.
Then use `AskUserQuestion` to ask which tool they choose, listing the recommended tool first and marking it "(Recommended)".

## 6. Record the decision
Only after the user confirms a choice:
- If the stack file exists, add the entry under the matching section, creating the section if it is missing. Don't duplicate or rewrite existing entries.
- Match the file's existing format exactly: same heading levels, list or table style, fields, field order, and version/date style. Consistency matters more than the default below.
- If there is no stack file yet, use `AskUserQuestion` to ask its name and location (`tech_stack.md` at repo root recommended) before creating it.
- Use this default format only for a new or empty file:
  `- **<Tool>** v<version> — <purpose>. Why: <1–2 reasons>. Alternatives considered: <tools>. Decided: <YYYY-MM-DD>.`