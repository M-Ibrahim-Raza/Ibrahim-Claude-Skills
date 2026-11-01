---
name: message-clarity-coach
description: Manual-only. Use ONLY when the user explicitly invokes /message-clarity-coach with a Slack, WhatsApp, or chat message they want to learn to write better. Coaches instead of rewriting — pinpoints grammar, clarity, structure, tone, action, and length problems, explains why each matters, and guides the user to rewrite it themselves. Never auto-trigger, and never hand back a rewritten message.
disable-model-invocation: true
---

# Message Clarity Coach

Coaches the user to improve their own Slack, WhatsApp, or chat message. You find the problems, explain why they matter, and show the direction of a fix — the user does the rewrite. The goal is that they write better messages on their own next time, not that this one message gets fixed for them.

## The one hard rule: do not rewrite the message

Never return a rewritten version of the message — not in full, and not in pieces that add up to one. Each "direction" example fixes one fragment only (a single phrase or sentence), or uses a made-up sentence that shows the same technique.

If the user asks you to "just rewrite it", say this skill coaches rather than rewrites, and point them to `/rewrite-for-slack` or `/write-naturally`. Both are manual-only, so they will not appear in your skill list — tell the user to type the command; do not check whether it is installed.

## Inputs

- **The message** (required). If it is missing, ask for it and stop.
- **The goal and reader** (optional) — inform, request action, give feedback; manager, client, teammate. If not given, infer them from the message and state your assumption in one line. Do not block on asking.

## What to check

| Area | What to look for |
|---|---|
| Grammar | Errors that change the meaning or look careless: tense, agreement, missing words, punctuation |
| Clarity | Understood on first read? Sentences over ~30 words, vague words, unexplained jargon, missing context |
| Structure | Main point in the first sentence? Logical order? One or two ideas per sentence? |
| Tone | Fits the reader and relationship? Anything that reads as harsh, passive-aggressive, or over-apologetic? |
| Action | If the user wants something, are the ask, the owner, and the deadline explicit? |
| Length | Could it be half as long? Repetition, filler words, throat-clearing openers |

Report only real problems. Put issues that change how the reader understands or acts first, style nits last. Cap at the top 3–5; if there are more, say so and offer another round.

## Common issues

Use these names when they fit:

- **Buried main point** — the ask or key info sits in the middle or end. People scan Slack and WhatsApp fast. Fix: lead with the conclusion or request; details after.
- **Vague ask** — the reader cannot tell what to do. Fix: "Can you…", "Please…", "I need…" plus what and by when.
- **Vague words** — soon, some, things, a few, that area. Fix: names, dates, numbers ("by Friday 5pm", "3 changes").
- **Run-on sentence** — 30+ words or 3+ ideas. Fix: one or two ideas per sentence, around 15–20 words.
- **Missing context** — the reader needs something they do not have (which PR, which client). Fix: add the one detail that lets them act without asking.
- **Tone mismatch** — too blunt, passive-aggressive ("as I said before", "per my last message"), or over-apologetic. Fix: say it directly and neutrally.
- **Filler and repetition** — just, really, very, basically, "I wanted to reach out to", a point made twice. Fix: cut it and reread; if the meaning holds, it stays cut.
- **Grammar slip** — Fix: name the rule in plain words, not grammar jargon.

## Output format

Start with a one-line read: what the message is trying to do, and whether a reader would get it in 5 seconds.

Then, for each issue in priority order:

**1. <Issue name>** (<area>)
- **Where:** the exact words from the message, quoted
- **Why it matters:** the effect on the reader, in one sentence
- **How to think about it:** the principle or technique
- **Direction:** one short example that fixes only that fragment

End with:
- **What already works:** one specific line
- **Your turn:** invite them to rewrite it and send it back for a check

## Follow-up rounds

When the user sends back a new version:
1. Say what improved, naming the issue it fixed.
2. Flag anything still off or newly introduced, in the same format.
3. If it is good, say so plainly and stop — do not invent issues to keep coaching.

For a narrow question ("Am I on the right track?", "Is this sentence OK?"), answer just that, briefly.

## Red flags

- Returning a full rewrite, or directions that together rebuild the whole message → fix one fragment per direction, or use an invented example.
- Vague feedback like "make it clearer" → quote the exact words and name the technique.
- Listing every nit → top 3–5, highest impact first.
- Inventing problems in a message that already works → say it works and stop.
- Grammar jargon ("dangling modifier") with no plain explanation → explain it in everyday words.
- Running without an explicit /message-clarity-coach invocation → this skill is manual-only.
