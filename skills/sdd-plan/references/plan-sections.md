# plan.md Sections

### Common plan.md Sections

- **Overview / Approach**: a short summary of how the feature will be built and the key idea behind it
- **Reference Files**: link to spec.md and the requirements and acceptance criteria this plan covers; plus mockups or source files to consult
- **Spec Changes**: changes to what spec.md asks for that planning found and I approved; each lists the spec.md section, old text, new text and reason. Applied to spec.md after approval
- **Decisions Not In The Spec**: how-only choices the spec didn't state (no change to behavior, scope, ACs, edge cases or user-facing copy), each with a one-line reason and confirmed by me
- **Architecture Overview**: how components and layers interact, and where the new code fits in the existing system
- **Tech Choices**: frameworks, libraries and tools used, with a one-line reason each
- **Component / Module Breakdown**: each module with its responsibility, inputs and outputs
- **Diagrams**: sequence or flow diagrams in Mermaid.js showing how a request moves through the system
- **File Structure**: exact paths of files that will be created, modified, or left untouched, grouped by area (routes, components, server code, schema, tests); sets hard scope boundaries
- **Out-of-Scope Boundaries**: what will not be touched (code, behavior, tests)
- **Global Constraints**: rules every step must follow (schema workflow, exact user-facing copy, no skipped tests, no ACs, requirement IDs or spec details in code comments or docs, the MUST/DO rules in `best_practices/`, branch and commit rules from CLAUDE.md)
- **Data Models / Database Setup**: final schema, field types, constraints, relations, indexes, migrations
- **API Contracts**: endpoints or procedures, methods, request/response shapes, status codes, error formats
- **Configuration**: env vars, constants, feature flags agreed upfront
- **Error Handling Strategy**: how each edge case in the spec is handled in code
- **Trade-offs / Alternatives**: options considered and why they were rejected
- **Risks / Review Focus**: what might break, and the test that guards each risk
- **Implementation Order**: ordered steps with explicit dependencies and the AC each covers
- **Testing Strategy**: AC → test mapping (test name, file, command, expected result)
- **Rollout / Migration**: deploy order, feature flags, backward compatibility, rollback
- **Open Items**: decisions Claude asks me with AskUserQuestion; each answer is recorded under its item and marked Closed

### Essential Sections

Following sections should be in every plan.md:

- **Reference Files**
- **Decisions Not In The Spec**
- **File Structure**
- **Out-of-Scope Boundaries**
- **Implementation Order**
- **Testing Strategy**
- **Open Items**

**Spec Changes** is required whenever a spec change was approved during planning.

Put **Spec Changes** and **Decisions Not In The Spec** right after Reference Files (and Overview, if present), so the reviewer sees them before the details.

### Recommended Sections for Feature Task

- **Overview / Approach**
- **Reference Files**
- **Spec Changes** (If Needed)
- **Decisions Not In The Spec**
- **Architecture Overview**
- **Tech Choices** (If new libraries are added)
- **Component / Module Breakdown**
- **Diagrams** (Optional)
- **File Structure**
- **Out-of-Scope Boundaries**
- **Global Constraints**
- **Data Models / Database Setup** (If Needed)
- **API Contracts** (If Needed)
- **Configuration** (If Needed)
- **Error Handling Strategy**
- **Risks / Review Focus**
- **Implementation Order**: starts with data models and schema
- **Testing Strategy**
- **Rollout / Migration**
- **Open Items**

### Recommended Sections for Bug Task

- **Reference Files**
- **Spec Changes** (If Needed)
- **Decisions Not In The Spec**
- **Root Cause Analysis**: the confirmed cause, with evidence (logs, stack trace, failing input)
- **Fix Approach**: the smallest change that fixes the root cause, not just the symptom
- **Alternatives Rejected**: other fixes considered (e.g. a workaround) and why they were dropped
- **File Structure**: exact files to change; usually very few
- **Out-of-Scope Boundaries**: no refactoring or unrelated cleanup
- **Side Effects / Risks**: other callers of the changed code that may behave differently
- **Implementation Order**: write the failing regression test → apply the fix → run the full test suite
- **Testing Strategy**: the regression test plus existing tests around the changed code
- **Rollout**: hotfix or normal release; data repair if bad data was already written
- **Open Items**

### Recommended Sections for Refactor Task

- **Reference Files**
- **Spec Changes** (If Needed)
- **Decisions Not In The Spec**
- **Current vs Target Structure**: before and after module or file layout, ideally with a diagram
- **Invariants Check**: how unchanged behavior is proven (existing tests, snapshot tests, golden outputs)
- **Safety Net**: tests to add *before* refactoring if coverage is weak
- **File Structure**: files moved, renamed, split, or deleted
- **Out-of-Scope Boundaries**: public APIs, DB schema, and visible behavior stay untouched
- **Migration of Callers**: how imports and usages are updated
- **Risks**: hidden dependencies, dynamic imports, reflection
- **Implementation Order**: starts with safety-net tests; each step leaves the code working and tests passing
- **Testing Strategy**
- **Rollback**: each step can be reverted on its own
- **Open Items**

### Recommended Sections for Performance Task

- **Reference Files**
- **Spec Changes** (If Needed)
- **Decisions Not In The Spec**
- **Profiling Findings**: where time or memory actually goes, with evidence
- **Bottleneck**: the chosen target and why
- **Optimization Approach**: caching, indexing, batching, query or algorithm changes
- **Trade-offs**: what is given up (memory, complexity, data freshness)
- **Benchmark Setup**: exact command, dataset, environment, number of runs
- **File Structure**
- **Out-of-Scope Boundaries**
- **Implementation Order**: baseline benchmark → change one thing → measure again
- **Testing Strategy**: correctness tests plus baseline vs target benchmark
- **Rollout**: feature flag, gradual rollout, monitoring
- **Open Items**

### Recommended Sections for Chore / Dependency Upgrade Task

- **Reference Files**
- **Spec Changes** (If Needed)
- **Decisions Not In The Spec**
- **Upgrade Path**: direct, or step by step through intermediate versions
- **Breaking Change Mapping**: each breaking change mapped to the code that needs updating
- **File Structure**: files and modules that use the dependency
- **Configuration**: lock files, build config, env vars
- **Out-of-Scope Boundaries**
- **Implementation Order**: map breaking changes → upgrade → fix build and type errors → fix deprecations → run tests
- **Testing Strategy**: full test suite, build, smoke test of key flows
- **Rollback Plan**: revert the lock file or pin the previous version
- **Open Items**

### Recommended Sections for Spike / Research Task

- **Reference Files**
- **Spec Changes** (If Needed)
- **Decisions Not In The Spec**
- **Approach**: how each option is explored (docs, prototype, benchmark)
- **Prototype Scope**: what the throwaway code will and won't cover
- **Evaluation Method**: how options are scored against the spec's decision criteria
- **Time Box Breakdown**: how the time is split across options
- **Output Format**: ADR, comparison table, or recommendation
- **Out-of-Scope Boundaries**: no production code; prototype code is thrown away
- **Implementation Order**: starts with defining the evaluation criteria
- **Open Items**
