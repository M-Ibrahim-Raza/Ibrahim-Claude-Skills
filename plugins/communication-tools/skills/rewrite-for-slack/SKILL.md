---
name: rewrite-for-slack
description: Manual-only. Use ONLY when the user explicitly invokes /rewrite-for-slack to rewrite a message into a short, simple, human, casual Slack-appropriate tone, then apply /format-slack-message to it. Never auto-trigger from ordinary writing or tone requests.
disable-model-invocation: true
---

# Rewrite For Slack

Rewrites a given message into a short, clear, casual tone fit for a real person typing in Slack — then runs the result through `/format-slack-message` to add Slack markup.

- Keep the meaning of the original message intact. Do not add or drop information.
- Make it short, clear, and easy to understand. Use simple, everyday words — no jargon, no overly formal language, no filler.
- Use a casual, friendly, approachable tone, like a real person typing in Slack.
- Do not use contractions or any words with apostrophes (write "I am" not "I'm," "do not" not "don't").
- Do not change words inside quotation marks — but remove the quotation marks themselves from the output.
- Output ONLY the rewritten message. No explanations, no commentary.

## The run
1. Rewrite the message per the rules above.
2. Run the rewritten message through `/format-slack-message` to add bold, backticks, and linkified URLs.
3. Output only the final, formatted message.

## Red flags
- Adding or dropping facts while rewriting → keep the meaning intact, trim only the wording.
- Leaving a contraction or apostrophe-word in the output → spell it out in full.
- Changing the wording inside quotation marks → keep that text exactly, just drop the quote marks.
- Skipping the `/format-slack-message` pass → always run it before returning the final message.
- Adding a preamble, explanation, or summary → output only the rewritten, formatted message.
