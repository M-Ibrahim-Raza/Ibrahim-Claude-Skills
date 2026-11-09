---
name: new-adr
description: Records an architecture decision as an ADR in the project's ADR folder, following the project's own ADR rules or compact defaults, and supersedes the old ADR when a decision changes. Use when the user wants to record, write or log a decision, mentions an ADR, or changes or reverses a past decision, even if they don't say "ADR".
argument-hint: [decision]
---

# New ADR

Record the decision in `$ARGUMENTS`. If it's empty, ask what was decided.

Ask with AskUserQuestion. Mark an option recommended only when it's a real choice, such as a folder or an option the user or the repo already named. For reasons and costs, ask in plain text or offer only ones the user or the repo already gave. Never make one up. Ask a follow-up only once the answer it depends on is in.

## Find the folder and its rules

1. **Folder.** Use the path in `.adr-dir` if that file exists. Otherwise look for `docs/adr/`, `docs/adrs/`, `docs/decisions/`, `doc/adr/`, `adr/` and `docs/architecture/decisions/`. If you find several, ask which. If you find none, propose `docs/adr/` in the draft.
2. **Rules.** Each source fills only what the ones above it leave open:
   1. Project rules: an ADR section in `docs/README.md`, `CONTRIBUTING.md`, `CLAUDE.md`, `AGENTS.md` or the folder's `README.md`, or a template in the folder (`template.md`, `0000-template.md`, `adr-template.md`). A plain list of ADRs is an index, not rules.
   2. Existing ADRs: the newest one's file name pattern, number width, header, status words, section layout and link style.
   3. The defaults in [references/adr-defaults.md](references/adr-defaults.md). They say what an ADR must cover. The sources above say where each part goes. Drop a default length limit the existing ADRs already exceed.

   Say in one line which sources you're following.
3. **Read** every ADR in the folder, to spot overlaps and any ADR this one replaces.

## Steps

1. **Check it's ADR-worthy.** It must match one of the cases in the rules. If not, say why and where it belongs instead, and stop. A tool pick goes in the tech stack file, if there is one. Say so if it's already recorded there.
2. **Fill gaps.** Ask for what's missing: why decide now, the options compared, why the winner won, why each other lost, and what it costs. Don't invent reasons: an ADR is only worth keeping if its reasons are real.
3. **Draft.**
   - Number: one above the highest in the folder, ignoring templates, or `0001` if there are none. Numbers are never reused.
   - File name: the number plus 2–5 kebab-case words. Heading title: plain words, in the existing ADRs' style. Date: today.
   - Link related ADRs in the folder's link style.
   - Over the length limit, if there is one (pipe the draft to `wc -w`): cut words, not sections.
4. **If it replaces an ADR:** confirm which one, and whether any of it still holds. Say both in the new ADR. Set the old one's status to superseded, in the rules' wording (default `Superseded by [NNNN](NNNN-short-title.md)`). Don't change its decision. If the longer status pushes it over the limit, trim wording only. Grep the ADR folder, `docs/`, `README.md`, `CLAUDE.md` and `AGENTS.md` for the old number and file name, and add fixes for references that now point to the wrong decision.
5. **Index.** If the folder has an index listing its ADRs (`README.md`, `index.md`), add the new ADR's line in the same style. Don't create an index the rules don't ask for.
6. **Show the draft** with every change and wait for a yes.
7. **Write**, check the length again, and list the files changed.
