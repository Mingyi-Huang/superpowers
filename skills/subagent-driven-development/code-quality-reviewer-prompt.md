# Code Quality Reviewer Prompt Template

Use this template when dispatching a code quality reviewer subagent.

**Purpose:** Verify implementation is well-built (clean, tested, maintainable)

**Only dispatch after spec compliance review and test contract review pass.**

```
Task tool (general-purpose):
  Use template at requesting-code-review/code-reviewer.md

  DESCRIPTION: [task summary, from implementer's report]
  PLAN_OR_REQUIREMENTS: Task N from [plan-file]
  BASE_SHA: [commit before task]
  TEST_LOCK_SHA: [commit where tests were locked]
  LOCKED_TEST_FILES: [locked test files]
  APPROVED_TEST_AMENDMENTS: [approved amendment references, or none]
  HEAD_SHA: [current commit]
```

**In addition to standard code quality concerns, the reviewer should check:**
- Does each file have one clear responsibility with a well-defined interface?
- Are units decomposed so they can be understood and tested independently?
- Is the implementation following the file structure from the plan?
- Did this implementation create new files that are already large, or significantly grow existing files? (Don't flag pre-existing file sizes — focus on what this change contributed.)
- Did any locked test file change after TEST_LOCK_SHA?
- Were assertions weakened, deleted, skipped, or broadened?
- Did mocks/fakes become more permissive?
- Did test names or test selection change in a way that avoids failures?
- Are production changes sufficient to satisfy the original behavior contract?

**Code reviewer returns:** Strengths, Issues (Critical/Important/Minor), Assessment
