# Journey defaults

Use these only for what the project's own journey rules and existing journeys don't settle.

A journey is one main task a user comes to the app to do, step by step. Each journey gets its own file, and an index lists them all. Features and specs are built from journeys, so every step must be real, not guessed.

## Format

- **File name:** `<ID>-<short-name>.md`, e.g. `J1-set-up-account.md`. IDs are `J1`, `J2`, … Never reused, even after a journey is deleted.
- **Length:** each journey file is under 20 lines, as `wc -l` counts them.
- **Heading:** `# J1 – <name>`, with an en dash.
- **Persona:** who does it. Link to the product doc when there is one.
- **Goal:** what they get done, in one line.
- **Steps table** with columns `#`, `Step`, `Screen`, `Features`. One row per user action, in order. Each step names the screen it happens on, and the same screen keeps the same name across journeys. `Features` lists the feature IDs that make the step work. Leave it blank in a new journey. It's filled in later.

## Template

````markdown
# J1 – <name>

**Persona:** <persona> ([product.md](../product.md))

**Goal:** <what they get done>.

| # | Step | Screen | Features |
|---|------|--------|----------|
| 1 | <user action> | <screen> | |
| 2 | <user action> | <screen> | |
````

Drop the link from the Persona line when the project has no product doc.

## Index

The journeys folder has a `README.md` with one line per journey, in ID order:

````markdown
# Journeys

The main tasks a user comes to the app to do, one file each.

- [J1 – <name>](J1-<short-name>.md)
````

If the product doc lists journeys, add the same line there, with the path relative to the product doc.
