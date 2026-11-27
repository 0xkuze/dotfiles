---
name: ub-mode
description: >
  How to write or change code: make it work with the smallest change, then make
  it right with minimal tests, killed mutants and the quality gates. Use for every
  feature, fix or refactor, and when the user runs /ub-mode or $ub-mode. Skip it
  for review-only, read-only and config/docs-only work.
---

# ub-mode

Lazy and correct: the smallest change that fully works, proven by the fewest tests that pin it.

## 1. Make it work

- Get the data shape right before the logic. One decision lives in one place.
- Reproduce a bug before fixing it. Fix the root cause in the shared code; a guard that only hides the crash is not a fix.
- Behavior change: write the failing test first, see it fail for the expected reason, then make the smallest change that passes.
- Two fixes on the same premise failed the same check: write the premise in one sentence, question it, and change the premise instead of trying a third fix.
- A new requirement that does not fit the current design: deliver it in the current design and propose the redesign.
- Check data where it enters; trust it inside. Parse outside data once. Make illegal states impossible to write; never silence the compiler.
- Operations that can run twice or crash halfway must end in the same state. If two writers would share mutable state, give each its own.

## 2. Make it right

- Dead code, duplication and needless complexity in the code you touch: remove them as part of the change and list them in the handover. Outside it: propose.
- Refactor: pin the behavior with a test, change the structure, prove the test still passes.

### Tests

- Minimum: one behavior test per case the change defines, called the way its user calls it. If it would still pass with every function returning nothing, throw it out.
- No tests for config, CI, docs or moved code. No UI tests unless the behavior lives only in the UI. No far-fetched cases outside the contract.
- Real dependencies over mocks.

### Gates (required before handover)

Run all three on every change with logic, only on the functions you added or changed. Run from the repo root, naming the tests that cover the change. Tools live in `/Users/cristian/Documents/tools` (each creates its `.venv` on first run; output in `.metrics/` and `target/`).

1. Duplication: `/Users/cristian/Documents/tools/dryer/dryer` over the repo. Act only on pairs that include a changed file, rank ≥ 0.8, and share one responsibility.
2. CRAP: `/Users/cristian/Documents/tools/crapper/crapper --tests <test files> <changed files>`. Keep each changed function under 10 by splitting or testing it.
3. Mutation: `/Users/cristian/Documents/tools/mutator/mutator --use-existing-coverage --tests <test files> <changed files>`. Kill every survivor with the smallest test, or delete the code it proves useless. Survivors in UI-only or far-fetched paths: report, don't chase.

Long gates run in the background; wait for them before ending your turn. A gate that cannot run (missing coverage provider, failing baseline, "Tests fail in the mutation workspace") goes in the handover; don't work around it. Violations in untouched code of the same files: report as proposals.

## 3. Practice

- Small, ordered commits that say why, what and how you proved it.
- Keep the main thread small: send bulk reading to subagents, keep the conclusion.
- Before adding tests or code to a function, check something calls it; if nothing does, delete it.
- Keep a domain glossary only in projects that already have one.
