---
name: update-app-docs
description: Update the project's app docs in docs/ when a feature ships or changes — finds the docs that should cover it, proposes the exact edit, and waits for approval before writing. Use when the user says "/update-app-docs", "update the app docs", "update the docs for <feature>", or after shipping a feature these docs describe.
argument-hint: "[feature] [details…]"
allowed-tools: Read, Grep, Glob, Bash, Edit, Write
---

# Update App Docs

Keep the project's app docs in `docs/` in sync with what actually ships. The skill finds the docs
that should cover a change, proposes the exact edit, and waits for approval before writing.

It edits docs only. It does not change code, open tickets, or commit.

## The docs root

The docs root is `docs/` at the repo root. `docs/README.md` is the index: a one-line intro and a
`## Contents` table with one row per doc.

Docs sit flat in `docs/`. If an area grows enough to need its own folder, propose it and ask before
creating it.

## Step 1 — Work out what changed

**Called with a feature name** — `/update-app-docs <feature>` — that feature is the subject. Any prose
after the name is the feature detail, and it is authoritative. Use it.

**Called bare** — `/update-app-docs` — work out the subject yourself:

1. Use what was built or discussed earlier in this session first.
2. Then the feature folders in `specs/`: the most recent one whose tasks.md has every task checked. Its
   spec.md says what the feature does; its plan.md File Structure lists the files.
3. Then git: `git diff` plus the recent commits in this repo. Skip this if the folder isn't a git repo.

If none of these gives you a subject, ask which feature or area changed. Do not guess.

## Step 2 — Find the docs that should cover it

- Grep `docs/` for the feature's terminology, model names and field names.
- **Map changed code files back to the doc that owns them using each doc's `## Implementation`
  section.** Every doc ends with a list of bare repo-relative paths (`app/...`, `components/...`,
  `lib/...`), which makes the tree its own reverse index. This is the most reliable way in.
- Read the candidate docs in full before deciding anything.
- Read `docs/README.md` too. A new feature usually needs a row in its `## Contents` table as well.
- If `docs/` is missing or empty, there is nothing to read. Go to Step 5.

## Step 3 — Judge whether there is anything to update

**Finding nothing to change is a valid outcome.** Say so and stop. Do not manufacture an edit.

For each doc you read, pick one:

| Verdict | When |
|---|---|
| Update a section | The doc covers this and is now wrong or incomplete |
| Add a section | New behaviour inside a feature the doc already owns |
| New doc | Nothing owns it — go to Step 5 |
| No change | The doc is still accurate |

Then check `docs/README.md` and sibling docs for a cross-link or table row that now needs the new entry.

## Step 4 — Propose before writing

**Never edit a doc before showing the proposal and getting approval.** This is the hard rule of this
skill.

For each target, print:

- the file path,
- the section and the action — update, add, or new file,
- the **actual proposed markdown, verbatim, exactly as it will land**,
- one line on why.

Then stop and wait. If edits are asked for, revise and show the proposal again. Write only once it is
approved.

## Step 5 — A new doc needs a confirmed home

If nothing owns the feature, propose a kebab-case filename in `docs/` and ask before creating it. If
`docs/README.md` does not exist yet, propose it in the same proposal, with the new doc as its first
`## Contents` row. Only `docs/README.md` is an index — do not add a `README.md` to subfolders.

## House style

Every doc follows this shape. Leave out the sections that don't apply.

````markdown
# Feature Name
---

`Feature Name` is <one-paragraph definition>.

- <orienting fact>
- <orienting fact>

For <related topic> see [other-doc.md](./other-doc.md).

## Why We Need It

<what the feature is for>

## DB Schema

<schema file path>

```
<raw schema model>
```

## UI / Frontend

- app/<route>/page.tsx

## Server Actions / API

File: app/<route>/actions.ts

- <actionName>

## Implementation

- app/<route>/...
````

- `# Title Case Name` then a bare `---` on the **next line, no blank line between**. This is the
  signature of the set.
- Then a one-paragraph definition, then a short bullet list of orienting facts.
- Then an **unheaded cross-link paragraph** — "For the related rules see
  [other-feature.md](./other-feature.md)." It sits after the bullets and before the first
  `##`. There is no `## Related docs` section.
- Only `##` and `###`. Never `####`.
- `## Why We Need It` / `## Why We Need Them` on feature docs.
- Toggles spell out both branches: `### \`fieldName\` is False` then `### \`fieldName\` is True`.
- Tail sections where they apply, in this order: `## DB Schema`, `## UI / Frontend`,
  `## Server Actions / API`, `## Implementation`.
- `## DB Schema` is either a fenced block with **no language tag** holding the raw schema model, or
  the schema path plus line range — `<schema file>:120-158`.
- `## Implementation` is bare repo-relative paths, optionally grouped under plain labels, optionally
  closing with a `Utils:` list of bare identifier names.
- Tables use the compact `|---|---|` separator. No alignment colons, no padding.
- Callouts are `> **Label.** text`, used sparingly.
- Links to siblings are `./file.md` with the filename as the visible text; `../folder/file.md` across
  folders. Deep anchors are fine.
- No frontmatter. No emoji. Em dash as the joining punctuation.
- Bold is for emphasis in prose, **never** for terminology.
- File paths are **not** backticked in bullets — only inside tables.

## Backticks for terminology

| Kind | Style | Examples |
|---|---|---|
| Domain concepts | Title Case in backticks | `Order`, `Account`, `Invoice` |
| DB columns / identifiers | Real casing | `createdAt`, `Order.status` |
| Platforms and infra | As branded | `Next.js`, `Vercel`, `Stripe` |
| State values and literals | As stored | `pending`, `completed` |
| UI labels | As shown | `New Order`, `Save changes` |

## Wording

- Plain day-to-day language. Short declarative sentences, present tense, no second person.
- Explain the point before the example, not after.
- State failure modes bluntly and label them — "Fail-closed: a missing setting counts as off."

## Length

Keep a doc under 150 lines. If an update would push it past that, propose splitting the new material
into a sibling doc and cross-linking instead of letting the doc sprawl.

## Do not

- Do not invent behaviour. Confirm it against the code first — reading the code to verify **is** the
  job here — but anything you cannot verify and were not told, ask about.
- Do not reformat, reflow or re-word sections unrelated to the change.
- Do not add `**Last updated:**` lines to docs.

## Step 6 — Report

Once the approved edits are written, print a short summary:

- **Files** — each path, marked `updated` or `created`
- **Sections** — what changed in each file
- **Cross-links** — any added, and where
- **Left alone** — anything you decided not to change, with the reason
