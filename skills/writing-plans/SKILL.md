---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Plans use Contract-Driven TDD:
1. Lock terminology from the Glossary Contract
2. Define behavior contract per slice
3. Create or confirm interface skeleton before tests
4. Write tests only against existing production symbols
5. Verify tests compile and fail for behavioral reasons
6. Lock tests before implementation
7. Implementation may not modify locked tests

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** If working in an isolated worktree, it should have been created via the `superpowers:using-git-worktrees` skill at execution time.

**Save plans to:** `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
- (User preferences for plan location override this default)

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

## Interface Skeleton First

Before writing failing tests for a new public API, add a skeleton step.

Skeleton steps MAY create:
- class/struct/enum declarations
- function/method signatures
- empty implementations
- explicit `not implemented` behavior
- build-system entries needed for compilation

Skeleton steps MUST NOT add:
- real business logic
- hidden behavior
- broad refactors
- production shortcuts that make tests pass accidentally

The skeleton must compile before tests are written.

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Define or confirm interface skeleton" - step
- "Verify the skeleton compiles/imports/builds" - step
- "Write one failing behavioral test" - step
- "Run it to make sure it fails for the expected behavioral reason" - step
- "Lock the test" - step
- "Implement the minimal production code to make the test pass" - step
- "Audit locked tests after implementation" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Task Structure

````markdown
### Task N: [Behavior Slice Name]

**Behavior Contract:**
- Glossary terms used: [...]
- Behavior under test: [...]
- Non-goals: [...]

**Files:**
- Create/Modify production skeleton: `exact/path/to/file.py`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 0: Define or confirm interface skeleton**

```python
def function(input):
    raise NotImplementedError("behavior not implemented")
```

- [ ] **Step 1: Verify skeleton compiles**

Run: `python -m py_compile exact/path/to/file.py`
Expected: PASS compilation / import / build

- [ ] **Step 2: Write one failing behavioral test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

Test Review Manifest:

Behavior under test:
Given:
When:
Then:
Expected initial failure:
Production symbols used:
Test-only symbols used:
This test must not verify:

- [ ] **Step 3: Run test to verify behavioral failure**

Run: `pytest tests/path/test.py::test_specific_behavior -v`
Expected: FAIL because behavior is not implemented, not because symbols/types are missing.
Forbidden: failure due to missing symbol, import error, fixture error, typo, or compilation error.

- [ ] **Step 4: Lock test**

Record:

```bash
Locked test files: tests/path/test.py
TEST_LOCK_SHA=$(git rev-parse HEAD)
Expected failing tests: tests/path/test.py::test_specific_behavior
```

- [ ] **Step 5: Write minimal production implementation**

Do not modify locked test files. If a test appears wrong, stop and file a Test Amendment Request.

```python
def function(input):
    return expected
```

- [ ] **Step 6: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_specific_behavior -v`
Expected: PASS

- [ ] **Step 7: Audit locked tests**

Run:

```bash
git diff --name-only TEST_LOCK_SHA..HEAD -- '*test*' 'tests/**'
```

Expected: no locked test files changed after TEST_LOCK_SHA.

- [ ] **Step 8: Commit**

```bash
git add tests/path/test.py exact/path/to/file.py
git commit -m "feat: add specific behavior"
```
````

## No Placeholders

Every step must contain the actual content an engineer needs. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — the engineer may be reading tasks out of order)
- Steps that describe what to do without showing how (code blocks required for code steps)
- References to types, functions, or methods not defined in any task

These are also plan failures:
- A RED test whose expected failure is "function not defined"
- A test that uses production symbols not present in the interface skeleton
- A test that cannot compile/import before implementation
- A test task that requires reviewing future classes/functions not yet declared
- A task that modifies tests and production code in the same step after test lock

## Remember
- Exact file paths always
- Complete code in every step — if a step changes code, show the code
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent commits
- Skeleton before behavioral RED test for new production APIs
- Locked tests are contracts; implementation steps must not modify them

## Self-Review

After writing the complete plan, look at the spec with fresh eyes and check the plan against it. This is a checklist you run yourself — not a subagent dispatch.

**1. Spec coverage:** Skim each section/requirement in the spec. Can you point to a task that implements it? List any gaps.

**2. Placeholder scan:** Search your plan for red flags — any of the patterns from the "No Placeholders" section above. Fix them.

**3. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

**4. Glossary consistency:** Do task names, API names, test names, and descriptions use canonical glossary terms?

**5. Skeleton-before-test:** Does every test that uses new production symbols have an earlier skeleton step?

**6. Behavioral RED:** Does every failing test fail for behavior-not-implemented, not missing symbol/import/build failure?

**7. Test lock:** Does every implementation step specify that locked tests must not be modified?

If you find issues, fix them inline. No need to re-review — just fix and move on. If you find a spec requirement with no task, add the task.

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `docs/superpowers/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- Fresh subagent per task + two-stage review

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:executing-plans
- Batch execution with checkpoints for review
