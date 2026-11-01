---
name: prompt-optimizer-for-code
description: Rewrite a user-supplied prompt into a clean, structured markdown prompt optimized for coding agents, without adding new information. Use this skill whenever the user wants to optimize, restructure, clean up, format, or "make better" a prompt they intend to feed to a coding agent, or whenever they paste a rough prompt and ask for an agent-ready version. Trigger on phrases like "rewrite this prompt", "optimize this prompt", "format this prompt", "make this prompt better", "turn this into a coding-agent prompt", or any time a user shares a messy task description meant to be executed by a coding agent.
---

# Prompt Optimizer for Code

Rewrite the user's prompt into a clean, well-structured markdown prompt that a coding agent can act on efficiently. Reorganize and reformat freely — but never invent requirements, constraints, file names, libraries, tech choices, acceptance criteria, or context that the user did not provide.

## Core principles

**Preserve, don't extend.** Every requirement, constraint, fact, name, and intent in the output must trace back to something the user actually wrote. If the user said "build a todo app," the rewritten prompt must not silently add "with authentication" or "using PostgreSQL." Rearranging, regrouping, deduplicating, and reformatting are allowed; adding is not.

**Lossless rewriting.** Don't drop user-supplied details either, even ones that feel redundant or off-topic. If the user mentioned a preference, a constraint, an example, or a file, it appears in the output. Cleaning up grammar, fixing typos, and collapsing repetition are fine; deleting substantive content is not.

**Optimize the form, not the substance.** What changes is structure, ordering, and phrasing — making implicit structure explicit, separating goals from constraints from deliverables, and using markdown that a coding agent parses well. The underlying task stays identical.

**No filler.** Skip generic boilerplate ("please be careful," "write clean code," "follow best practices") unless the user wrote it. Skip irrelevant headings. If a section would be empty, omit it.

## When to ask before rewriting

Ask freely if the prompt is genuinely ambiguous in a way that would force you to guess at substance. Examples worth asking about: a referenced file or codebase isn't attached, two parts of the prompt contradict each other, the target language/framework is unstated and matters, or the deliverable is unclear ("fix this" — fix what specifically?).

Don't ask about things you can leave generic. If the user didn't specify a styling approach, don't ask — just leave styling unspecified in the rewrite. Asking should resolve a real ambiguity, not pad out the spec.

Ask in plain prose, one or two focused questions, then wait. Don't proceed with assumptions in place of answers.

## Output format

Return only the rewritten prompt as markdown — nothing else. No preamble ("Here's the optimized version:"), no postamble ("Let me know if you want changes"), no meta-commentary about what was reorganized. The user will copy the output directly into the coding agent.

Wrap the output in a fenced markdown block so it's easy to copy:

````
```markdown
# [Task title derived from the prompt]

...
```
````

## When to suggest agent teams or subagents

Only suggest a subagent / parallel-agent approach when the user's prompt clearly involves multiple parallel or separable workstreams — e.g., "build the backend and frontend and write tests" or "research three competing libraries and pick one." In that case, add a brief `## Suggested execution` section that proposes a split, framed as a suggestion, not a mandate. For example:

```markdown
## Suggested execution
Consider splitting into parallel subagents:
- One to scaffold the API endpoints
- One to build the React components
- One to write integration tests
```

Do not add this section for single-track tasks ("fix this bug", "write a function that does X"). The goal is to surface real parallelism the user implied, not to bolt on agent jargon.

## Style rules for the rewritten prompt

- Use imperative verbs in requirements ("Implement…", "Return…", "Validate…").
- Use fenced code blocks for any code, file paths, commands, or schemas the user provided.
- Keep bullets tight — one idea per bullet.
- Quote literal strings, file names, and identifiers in backticks.
- Use second-person ("you") sparingly or not at all; address the task, not the agent.
- Don't editorialize ("this is a great approach", "obviously…").

## What not to do

- Don't add "use TypeScript" when the user didn't say TypeScript.
- Don't add "include error handling" unless the user said so. (The coding agent will do reasonable error handling on its own.)
- Don't add "write clean, documented code" or similar generic instructions.
- Don't add testing requirements the user didn't ask for.
- Don't restructure the prompt in a way that changes priority — if the user emphasized something, the rewrite should emphasize it too.
- Don't translate the prompt's language; preserve the user's language unless asked.
- Don't wrap the output in extra explanation. Just the markdown prompt.
