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

Every doc follows this shape. Leave out slots that don't apply. Section names are **generated per
doc** from the rules below, not picked off a fixed list of literal strings.

````markdown
# Feature Name
---

`Feature Name` is <one-paragraph definition>.

- <orienting fact>
- <orienting fact>

For <related topic> see [other-doc.md](./other-doc.md).

## Why We Need It

<what the feature is for>

## <Mechanism Name>

<how it actually works — one or more of these, freely named>

## DB Schema

<schema file path>

```
<raw schema model>
```

## UI / Frontend

- app/<route>/page.tsx

## <Backend transport> / Backend

File: app/<route>/<file>

- <actionName>

## Implementation

- app/<route>/...
````

- `# Title Case Name` then a bare `---` on the **next line, no blank line between**. This is the
  signature of the set.
- Then a one-paragraph definition, then a short bullet list of orienting facts.

### Slots and how to name them

Slots appear in this order when present. Rationale is always first; Data model, Interface, Backend
and Implementation are always last, in that order.

| Slot | When it appears | Heading rule |
|---|---|---|
| Rationale | Always | `## Why We Need It` if the feature name is singular, `## Why We Need Them` if plural. Judge this from the feature's own name, not from a fixed choice. |
| Branch | Once per field or flag whose value changes behaviour | Group heading names the field: `## \`fieldName\` Behavior`. Under it, one `### \`fieldName\` is <value>` per value the field actually takes — not limited to two, not limited to booleans. Two independent flags in one doc get two separate group headings. |
| Mechanism | One or more, whenever the doc needs to explain how something actually works beyond the rationale | Name each after the thing it describes, Title Case, 1-4 words (`## Ingestion`, `## Reply Classification`, `## Skip Rules`) — never a generic placeholder like `## Details` or `## Notes`. Order them the way a reader needs them, not alphabetically. A doc can have as many of these as it needs, or none. |
| Data model | The feature touches the DB | `## DB Schema` if this doc is the only one describing that model's lifecycle; `## Shared DB Schema` if other docs also depend on the same model. |
| Interface | The feature has UI | `## UI / Frontend` — fixed, doesn't vary. |
| Backend | The feature is called from the frontend or another service | `## <Transport> / Backend`, where `<Transport>` names whatever call style this project actually uses — e.g. `Server Actions`, `tRPC Routes`, `API`, `REST Endpoints`. Check the code; a project that mixes transports can use a different name per doc. |
| Implementation | Always, last | `## Implementation` — fixed. Group its file list under plain bold labels while there are only a couple; once a doc has more than one such group, promote each label to a real `###` sub-heading (named after the group) instead of bold text, so it's independently addressable. |

A doc that's an index (mirrors `docs/README.md`'s own table — a hub doc for a feature area) or a
status report for a non-engineering audience is a different genre. Don't force this skeleton onto it
— keep its headings freeform or numbered as fits its audience, and don't treat the slot table above
as a checklist for it.

- `## DB Schema` is either a fenced block with **no language tag** holding the raw schema model, or
  the schema path plus line range — `<schema file>:120-158`.
- `## Implementation` is bare repo-relative paths, optionally grouped under plain labels or `###`
  sub-headings (see the Implementation slot above), optionally closing with a `Utils:` list of bare
  identifier names.
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
