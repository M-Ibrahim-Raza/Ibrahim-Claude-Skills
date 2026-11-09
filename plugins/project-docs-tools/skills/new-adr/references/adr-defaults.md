# ADR defaults

Use these only for what the project's own ADR rules and existing ADRs don't settle.

## When to write an ADR

Write one only for a decision that:

- sets how the app is built: its architecture, or a pattern every feature follows (e.g. "tRPC for client data"),
- sets how the team works: CI, reviews, repo settings,
- or overrides a rule in another doc.

Not an ADR:

- Picking a tool or service. It goes in the tech stack file. When a tool comes with a big decision, the ADR records the decision and the stack file records the tool.
- Git rules (branches, commits, PRs). They go in the project's git rules doc, if it has one.

## Format

- **Name:** `NNNN-short-title.md`, e.g. `0001-single-deployable.md`. Four digits. Numbers are never reused.
- **Length:** 200 words at most for the whole file, as `wc -w` counts them. Cut words, not sections.
- **Header:** `# NNNN. Title`, then one line with Status (`Accepted` or `Superseded by [NNNN](NNNN-short-title.md)`) and Date.
- **Sections:** bold labels, not headings.
  - **Context:** one short paragraph. Why a decision is needed now, and the name of every option compared.
  - **Decision:** one short paragraph. What was chosen and why it won.
  - **Consequences:** at most 5 bullets. Good and bad results, why each other option lost, and any rule it overrides.
- **Links:** related ADRs as `[0001](0001-short-title.md)`.
- **Changing a decision:** write a new ADR and mark the old one superseded. Never delete an accepted ADR or change its decision. Fixing its format or wording is fine.

## Template

````markdown
# NNNN. Title

**Status:** Accepted · **Date:** YYYY-MM-DD

**Context:** ...

**Decision:** ...

**Consequences:**
- ...
````

## Example

````markdown
# 0003. One database per environment

**Status:** Accepted · **Date:** 2026-03-14

**Context:** Preview deploys share the staging database, so test data from one branch breaks another branch's review. We compared one database per environment, one schema per preview, and a shared database reset from seed data.

**Decision:** Give each environment its own database, and each preview deploy a fresh copy of it. It won because every review starts from clean data and needs no cleanup jobs.

**Consequences:**
- Previews start about 30 seconds slower while their database is created.
- One schema per preview was rejected: every migration would need to be schema-aware.
- Seed resets were rejected: two reviews at once still collide.
- Overrides the "one shared staging database" note in `docs/infra.md`.
````
