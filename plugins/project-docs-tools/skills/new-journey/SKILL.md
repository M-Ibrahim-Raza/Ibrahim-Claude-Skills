---
name: new-journey
description: Creates a new user journey file from a rough idea, following the project's own journey rules or compact defaults, and links it from the journeys index and the product doc. Use when the user wants to add, draft or define a new journey, user flow or main task in the app, even if they don't say "journey". Not for editing an existing journey.
argument-hint: [journey idea]
---

# New journey

Turn the user's idea (`$ARGUMENTS`, if given) into a new journey. If there's no idea yet, ask what task the user comes to the app to do.

Ask with AskUserQuestion. Mark an option recommended only when it's a real choice, such as a folder, or a persona or screen the docs already name. For goals and steps, ask in plain text or offer only what the user or the docs already gave. Never make one up.

## Find the folder and its rules

1. **Folder.** Look for `docs/journeys/`, `docs/user-journeys/`, `docs/flows/` and `journeys/`. If you find several, ask which. If you find none, propose `docs/journeys/` in the draft.
2. **Product doc** (optional). Look for `docs/product.md`, `PRODUCT.md` or `docs/prd.md`, and read its personas, non-goals and journey list. If there's none, say the product checks are skipped. Never create one.
3. **Rules.** Each source fills only what the ones above it leave open:
   1. Project rules: a journeys section in `docs/README.md`, `CONTRIBUTING.md`, `CLAUDE.md`, `AGENTS.md` or the folder's `README.md`, or a `template.md` in the folder. A plain list of journeys is an index, not rules.
   2. Existing journeys: the newest one's ID scheme, file name pattern, heading, fields, table columns and link style.
   3. The defaults in [references/journey-defaults.md](references/journey-defaults.md). Drop a default length limit the existing journeys already exceed.

   Say in one line which sources you're following.
4. **Read** every journey file: IDs, steps and screen names in use.

## Steps

1. **Check scope.** Stop and say why if the idea repeats an existing journey, is a non-goal, or needs a persona the product doc doesn't have. Those are product decisions for the user. Check again once the gaps are filled.
2. **Fill gaps.** Ask for a missing persona, goal or step, and for a screen name when no existing one fits. Don't guess: features and specs are built from the journey.
3. **Draft the file.**
   - ID: one above the highest in the folder or its git history (`git log --all --name-only --format= -- <folder>`), or `J1` if there are none. IDs are never reused.
   - Short name: 2–4 kebab-case words.
   - One row per user action, in order. Reuse an existing screen name when it's the same screen, so screens map cleanly to designs and prototypes. Point out any screen no other journey uses yet.
   - Over the length limit (pipe the draft to `wc -l`): tighten wording, and ask before dropping a step.
4. **Show the draft** with every file change. Write nothing until the user says yes.
5. **Write:**
   - the journey file
   - its line in the journeys index (create the index only for a new folder, or when the rules ask for one)
   - its line in the product doc's journey list, if it has one
6. **Check** the journey file's length again, then list the files changed.
