# Prompt-engineering techniques (for wording in-scope edits)

This is a working cheat-sheet for crafting the *specific instruction you are adding
or modifying*. It is NOT a license to rewrite the surrounding prompt. Apply only to
the in-scope text; preserve everything else verbatim (see SKILL.md).

Source basis: Anthropic's prompt-engineering documentation and current
model-behavior guidance for Claude's latest models.

## Table of contents
1. Be clear and direct
2. State scope explicitly (literal instruction following)
3. Positive framing over prohibitions
4. Add context / motivation
5. Use examples (multishot)
6. Structure with XML tags
7. Sequential steps and ordering
8. Control verbosity and format
9. Match existing conventions
10. Quick decision guide: add vs. optimize vs. modify

---

## 1. Be clear and direct
Treat the model like a capable new hire with zero context on your norms. Spell out
exactly what to do, in what format, with what constraints.

- Golden test: show the instruction to a colleague with minimal context. If they'd
  be confused about what to do, the model will be too.
- Specify the desired output format and any hard constraints inline.
- "Summarize the document in exactly three bullet points" beats "summarize this."

## 2. State scope explicitly (literal instruction following)
Current Claude models interpret instructions **literally** and do **not** silently
generalize one instruction to other items or infer requests you didn't make. This is
the single most important point for surgical edits.

- If a rule should apply broadly, say so: "Apply this to **every** section, not just
  the first."
- If it should apply narrowly, bound it: "Only when the input is a PDF," "only in the
  final summary."
- Ambiguous scope = the model applies the rule exactly as written, which may be
  narrower or broader than intended. Pin it down.

## 3. Positive framing over prohibitions
Telling the model what TO do steers more reliably than telling it what NOT to do.

- Prefer: "Respond in flowing prose."
- Over: "Don't use bullet points."
- When a prohibition is necessary, pair it with the desired alternative: "Don't list
  methods; instead, describe the overall approach in a sentence."
- Positive examples of the desired behavior generally outperform negative examples.

## 4. Add context / motivation
A short reason helps the model generalize correctly to cases the instruction didn't
enumerate.

- "Use ISO dates (YYYY-MM-DD) so downstream parsing is unambiguous."
- Keep it brief — one clause, not a paragraph. Motivation supplements the
  instruction; it doesn't replace a clear directive.

## 5. Use examples (multishot)
Examples are among the most reliable ways to lock in format, tone, and structure —
useful when an instruction is hard to specify in the abstract.

- Make examples **relevant** (mirror the real case), **diverse** (cover edge cases so
  the model doesn't latch onto an accidental pattern), and **structured**.
- 3–5 examples is a good target when examples are warranted.
- Wrap each in `<example>` tags, multiple in `<examples>`, so they're clearly
  distinguished from instructions. If the prompt already has an example convention,
  match it instead.

## 6. Structure with XML tags
Tags like `<instructions>`, `<context>`, `<example>`, `<formatting>` help the model
separate distinct components and reduce bleed between them.

- When adding to a prompt that already uses tags, reuse the existing tag names and
  nesting — don't introduce a parallel scheme.
- A new self-contained rule can be wrapped in a tag matching its siblings.

## 7. Sequential steps and ordering
When the order or completeness of steps matters, present them as a numbered list or
explicit bullets.

- If you edit one step in an existing numbered procedure, renumber only within that
  list, and only if necessary.
- Respect any stated precedence convention ("earlier rules take priority") when
  placing a new rule.

## 8. Control verbosity and format
If behavior depends on a specific length or style, state it explicitly; the model
calibrates length to perceived task complexity otherwise.

- To trim: "Provide concise, focused responses. Skip non-essential context; keep
  examples minimal."
- Show a positive example of the right level of concision rather than only saying
  "don't over-explain."

## 9. Match existing conventions
A consistent prompt is a reliable prompt. The in-scope edit should be
indistinguishable in style from the lines around it:

- Same voice (imperative "Do X" vs. descriptive "The assistant does X").
- Same terminology for the same concept (don't introduce a new synonym).
- Same markdown/tag/bullet/numbering style as neighbors.
- Same level of formality and the same person/tense.

A stylistically mismatched insertion is itself a defect, even if its content is
correct.

## 10. Quick decision guide: add vs. optimize vs. modify
- The prompt has **no** rule on this topic — **Add** (place near related rules).
- The prompt **already** addresses it but unclearly/unreliably, and the intended
  behavior is the same — **Optimize** the existing line (don't add a second).
- The prompt addresses it and you must **change the behavior** — **Modify** the
  smallest span of the existing line that achieves the new behavior.
- The new requirement **contradicts** an existing rule — stop and surface the
  conflict; don't silently override.
