# spec.md Sections

### Common spec.md Sections

- **Problem / Motivation / Context**: why this feature is being built; the pain point or business need it solves
- **Goals**: what the feature must achieve; the intended outcomes
- **Non-Goals**: what is explicitly out of scope; prevents scope drift
- **User Stories**: who needs what and why, written from the user's perspective (e.g. "As a user, I want to...")
- **Acceptance Criteria**: checkable conditions that define when the feature is complete (must have a failing state a command can detect)
- **API Design**: endpoints, request/response shapes, contracts between services
- **Data Models**: database schema, field types, constraints, relationships
- **Diagrams**: sequence diagrams, flow diagrams (often in Mermaid.js) for visual clarity
- **Edge Cases**: unusual or failure scenarios that must be handled explicitly
- **Test Cases**: sample inputs and expected outputs; maps directly to acceptance criteria
- **Open Questions**: ambiguities Claude asks me with AskUserQuestion; each answer is recorded under its question and marked Closed
- **Verification Rules**: anti-gaming constraints (e.g. no `it.skip` or `test.skip`, no deleted assertions, diff stays within specified files)

### Essential Sections

Following sections should be in every spec.md:

- **Problem / Motivation / Context**
- **Goals** 
- **Non-Goals**
- **Acceptance Criteria**
- **Open Questions**
- **Verification Rules**

### Recommended Sections for Feature Task

- **Problem / Motivation / Context**
- **Goals** 
- **Non-Goals**
- **User Stories**
- **Acceptance Criteria**
- **API Design** (If Needed)
- **Data Models** (If Needed)
- **Diagrams** (Optional)
- **Edge Cases** 
- **Test Cases**
- **Open Questions**
- **Verification Rules**

### Recommended Sections for Bug Task

- **Problem / Issue / Summary**
- **Steps to Reproduce**: an exact, repeatable sequence
- **Expected vs Actual Behavior**
- **Root Cause**: confirmed, or marked as a guess
- **Goals** 
- **Non-Goals**
- **Fix Scope**: which files or areas may change
- **Acceptance Criteria**
- **Regression Test**: a test that fails before the fix and passes after; this is the most important part
- **Open Questions**
- **Verification Rules**
