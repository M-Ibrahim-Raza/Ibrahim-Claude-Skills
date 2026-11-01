---
name: prompt-instruction-editor
description: Surgically add, optimize, or modify ONLY the instructions in an existing prompt that are relevant to a specific change request (a "ticket"), while leaving every unrelated instruction byte-for-byte untouched. Use this whenever someone wants to edit a prompt, add an instruction to a prompt, tweak or clarify one rule in a long system prompt, or "update the prompt for X" without disturbing the other rules — especially when the prompt is large, contains many special-case instructions, and changing or deleting the wrong line would break behavior. Trigger this even when the user just says "add this to the prompt," "make the prompt also do Y," "fix the instruction about Z," or pastes a big prompt and asks for a small targeted change. Do NOT rewrite or "improve" the whole prompt when this skill applies — the entire point is a minimal, scoped diff.
---

# Prompt Instruction Editor

## Why this skill exists

Production prompts accumulate many instructions, each written deliberately for a
specific edge case. A request usually touches only one or two of them. The danger
is not writing the new instruction well — it's the *collateral damage*: silently
rewording an unrelated rule, "tidying" formatting, reordering sections, or dropping
a special case because it looked redundant. Any of those can change behavior the
prompt author depended on.

**Core principle: change the minimum necessary, and prove that everything else is
untouched.** Treat the prompt like production code under review, not like a draft to
polish. The deliverable is a surgical diff plus an explanation — never a wholesale
rewrite.

## The one rule that overrides everything

> Every instruction NOT identified as in-scope for the change request must survive
> verbatim — same wording, same order, same formatting, same XML tags, same
> whitespace and casing. If you are unsure whether a line is in scope, it is OUT of
> scope; ask rather than touch it.

## Workflow

Follow these steps in order. Do not skip the locate and verify steps.

### 1. Capture the two inputs

You need (a) the **existing prompt** and (b) the **change request** ("ticket").
- If the prompt is in an uploaded file, read it from disk and edit the file in
  place later (copy to a writable location first if the upload is read-only). If it
  was pasted inline, work with the pasted text.
- If the change request is vague ("make it better"), stop and ask what specific
  behavior should change. A surgical edit is impossible without a target.

### 2. Locate the relevant region(s)

Read the whole prompt once to build a map, then identify the specific
instruction(s) the ticket actually concerns. Quote them back to the user (short
excerpts) and state: "These are the only lines I plan to touch. Everything else
stays as-is." Get implicit or explicit confirmation before large edits.

When locating, look for:
- An existing instruction that already covers the topic (— likely an *optimize* or
  *modify*, not an *add*).
- The section/cluster where a new instruction belongs (related rules tend to be
  grouped; respect that grouping).
- Any instruction that the change would **conflict with or duplicate** — flag these
  now (see step 6).

### 3. Classify the change

Decide which of three operations the ticket requires, because each has different
risks:

| Operation | What it means | Main risk to avoid |
|-----------|---------------|--------------------|
| **Add** | Introduce a net-new instruction the prompt doesn't yet have | Placing it where it contradicts or duplicates an existing rule |
| **Optimize** | Keep the same intent of an existing relevant instruction but make it clearer/more reliable | Changing the *meaning* while "clarifying," or expanding scope |
| **Modify** | Deliberately change the behavior of an existing relevant instruction | Editing more of the line/section than the behavior change requires |

If the ticket needs more than one of these, do them as separate, clearly-labeled
edits.

### 4. Decide placement (for adds) or boundaries (for edits)

- **Adds:** Insert next to semantically related instructions, inside the matching
  existing section and using the prompt's existing structure (if rules live under
  `## Formatting`, a new formatting rule goes there — don't invent a new section
  unless none fits). Match the surrounding format exactly: if neighbors are bullet
  points, use a bullet; if they're numbered and order matters, renumber only within
  that list and nowhere else.
- **Edits:** Change the smallest span that achieves the goal — ideally a clause or a
  line, not the whole paragraph. Leave the instruction's neighbors alone even if
  they share a sentence.

### 5. Draft the new/edited text using prompt-engineering best practices

Apply these **only to the text you are adding or changing**, never as an excuse to
rewrite neighbors. Read `references/prompt-engineering-techniques.md` for the full
toolkit; the high-value moves for instruction edits are:

- **Be clear, direct, and explicit.** State exactly what to do and the desired
  output/format. Vague instructions are the #1 cause of bad behavior.
- **State the scope explicitly.** Current Claude models follow instructions
  literally and do NOT silently generalize from one case to another. If a new rule
  should apply to "every section" or "only PDF inputs," say so in those words —
  otherwise it will be applied exactly as narrowly or broadly as written.
- **Prefer positive instructions over negative ones.** "Respond in plain prose"
  steers better than "don't use bullet points." When you must forbid something, also
  say what to do instead.
- **Add brief motivation when it helps.** A short "so that…" clause helps the model
  generalize correctly to cases you didn't enumerate.
- **Match the prompt's existing conventions.** Reuse its terminology, tag names,
  voice (imperative vs. descriptive), and example format. A consistent prompt is a
  reliable prompt; a stylistic mismatch is itself a defect.
- **Reuse existing XML/structure** rather than introducing a competing scheme.

### 6. Check for conflicts and redundancy

Before applying, cross-check the draft against the rest of the prompt:
- **Conflict:** Does the new/edited instruction contradict an existing rule (e.g.,
  new rule says "always cite sources," an existing rule says "never include links")?
  Do **not** silently resolve it by editing the other rule. Surface it: describe both
  instructions and ask the user how to reconcile, or propose the minimal reconciling
  edit and let them approve.
- **Redundancy:** If the prompt already says this, prefer optimizing the existing
  line over adding a second one. Two rules saying nearly the same thing is a future
  bug.
- **Ordering/precedence:** If the prompt has a precedence convention (e.g., "earlier
  rules win"), place the instruction so its priority is correct.

### 7. Apply the minimal edit

Make the change as a targeted replacement of the located span. Do not reflow,
re-indent, normalize quotes, "fix" unrelated typos, or reorder anything outside the
in-scope region. Preserve trailing/leading whitespace and the file's line endings.

### 8. Verify and report

Before returning, verify the preservation guarantee — ideally mechanically:
- Produce a diff of old vs. new (e.g., `diff` or a unified-diff view). Confirm the
  ONLY changed lines are the in-scope ones from step 2.
- Re-read each unrelated section to confirm it is identical.

Then deliver in this format:

```
## Change summary
- Operation: <add | optimize | modify>
- In-scope target: <which instruction/section>
- What changed and why: <1–3 sentences>

## Conflicts / notes
<any conflicts surfaced, redundancies, or "none">

## Diff
<unified diff showing only the in-scope change>

## Updated prompt
<the full updated prompt, or the path to the edited file>
```

Always show the diff — it is the proof that unrelated instructions were preserved,
and it's what lets the prompt's owner review the change quickly.

## Anti-patterns (do not do these)

- Rewriting or "modernizing" the whole prompt because parts look dated.
- Deleting an instruction that "seems redundant" without confirming it isn't a
  deliberate edge-case rule.
- Merging the new instruction into an unrelated paragraph for "flow."
- Renumbering, re-sectioning, or reformatting beyond the in-scope region.
- Broadening an edit's scope beyond what the ticket asked ("while I'm here…").
- Resolving a conflict by quietly editing the other instruction.

## Reference

`references/prompt-engineering-techniques.md` — distilled, current prompt-engineering
techniques (clarity, examples, scope/literalness, structure, positive framing) to
draw on when wording the in-scope edit.
