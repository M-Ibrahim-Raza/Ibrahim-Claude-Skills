---
name: search-and-add-concept
description: Manual-only. Use ONLY when the user explicitly invokes /search-and-add-concept. Never auto-trigger from topic questions, "explain X", or note edits.
---

# Search and Add Concept

Two turns. Turn 1 = search and explain. Turn 2 = add to notes. Never merge them.

Never use em dashes (—). Use a comma, period, or rephrase instead. This applies to all output: chat explanations and note content.

**Skip straight to Turn 2** if the invocation already includes the content to add. Do not search, do not explain — just add what was given.

## Turn 1 — Search & explain

1. Run `WebSearch` on the concept first. Always search, even if you already know it.
2. Prefer the most recent sources
3. Output the explanation in chat only. **Do not touch any note.**

Rules for the explanation:
- Use single line paragraph.
- Use Bullet points. 
- Avoid long paragraphs.
- Correct beats simple — never trade accuracy for readability.
- Keep it tight. Cut anything that does not help understanding.
- Use very simple, direct, and literal English.
- Prefer common everyday words over idioms, metaphors, slang, or clever expressions.

End with one line: `Send the refined content and the note to add it to.`

## Turn 2 — Add to notes

Trigger: the user sends content, or says "add this" / "add to notes" — in this turn or in the original invocation.

1. Use the user's refined content as the source of truth. Do not re-explain or expand it.
2. Find the best place for this content. You are allowed to create new files and folders.
3. Insert under a heading for the concept, matching the style of notes already in that part of the vault.
4. Pick whichever format makes the content easiest to scan — bullets for short standalone points, a markdown table for repeated rows of figures or comparisons, `###` sub-headings to split a long example into parts. Bullets are the default, not the rule.
5. Wrap every formula in backticks so it renders as inline code — `Density = Mass ÷ Volume`. This holds wherever the formula sits: on its own line, in a bullet, or inside a table cell.
6. Add nothing the user did not provide — no new facts, no filler, no commentary. Restructuring what they sent is allowed; headings and table column labels count as structure, not as new content.
7. Reply with a one-line confirmation and the wikilink.

## Red flags

- Writing to a note in turn 1 → stop, explain only.
- Searching or explaining when the content was already handed to you → skip to Turn 2.
- Adding facts the user did not send in turn 2 → remove them.
- Prose blocks where a list or table would read better → restructure.
- Answering from memory without searching → search first.
