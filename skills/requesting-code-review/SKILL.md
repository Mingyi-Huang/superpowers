---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
---

# Requesting Code Review

Dispatch a code reviewer subagent to catch issues before they cascade. The reviewer gets precisely crafted context for evaluation — never your session's history. This keeps the reviewer focused on the work product, not your thought process, and preserves your own context for continued work.

**Core principle:** Review early, review often, and audit test contracts when TDD locks tests.

## When to Request Review

**Mandatory:**
- After each task in subagent-driven development
- After completing major feature
- Before merge to main
- After any approved Test Amendment Request is applied

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request

**1. Get git SHAs and test lock metadata:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main / task start
TEST_LOCK_SHA=$(git rev-parse HEAD)  # replace with actual lock commit/sha from task report
HEAD_SHA=$(git rev-parse HEAD)
LOCKED_TEST_FILES="tests/path/test_file.ext"
APPROVED_TEST_AMENDMENTS="none"
```

**2. Dispatch code reviewer subagent:**

Use Task tool with `general-purpose` type, fill template at `code-reviewer.md`.

If the task used Contract-Driven TDD, the reviewer prompt MUST include TEST_LOCK_SHA and locked test files.

**Placeholders:**
- `{DESCRIPTION}` - Brief summary of what you built
- `{PLAN_OR_REQUIREMENTS}` - What it should do
- `{BASE_SHA}` - Starting commit
- `{TEST_LOCK_SHA}` - Test lock commit/sha
- `{LOCKED_TEST_FILES}` - Locked test files
- `{APPROVED_TEST_AMENDMENTS}` - Approved amendments, or `none`
- `{HEAD_SHA}` - Ending commit

**3. Act on feedback:**
- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back if reviewer is wrong (with reasoning)
- Stop if the reviewer identifies unauthorized locked-test changes or test weakening

## Example

```
[Just completed Task 2: Add verification function]

You: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
TEST_LOCK_SHA=a7981ec
HEAD_SHA=$(git rev-parse HEAD)
LOCKED_TEST_FILES="tests/verify-index.test.ts"
APPROVED_TEST_AMENDMENTS="none"

[Dispatch code reviewer subagent]
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types
  PLAN_OR_REQUIREMENTS: Task 2 from docs/superpowers/plans/deployment-plan.md
  BASE_SHA: a7981ec
  TEST_LOCK_SHA: a99c120
  LOCKED_TEST_FILES: tests/verify-index.test.ts
  APPROVED_TEST_AMENDMENTS: none
  HEAD_SHA: 3df7661

[Subagent returns]:
  Strengths: Clean architecture, real tests, locked tests unchanged
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

You: [Fix progress indicators]
[Continue to Task 3]
```

## Integration with Workflows

**Subagent-Driven Development:**
- Review after EACH task
- Catch issues before they compound
- Include test lock metadata for Contract-Driven TDD tasks
- Fix before moving to next task

**Executing Plans:**
- Review after each task or at natural checkpoints
- Get feedback, apply, continue
- Stop for locked-test changes without approved amendment

**Ad-Hoc Development:**
- Review before merge
- Review when stuck

## Red Flags

**Never:**
- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues
- Argue with valid technical feedback
- Send a Contract-Driven TDD task for review without TEST_LOCK_SHA and locked test files
- Treat all tests passing as sufficient when tests were changed

**If reviewer wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

See template at: requesting-code-review/code-reviewer.md
