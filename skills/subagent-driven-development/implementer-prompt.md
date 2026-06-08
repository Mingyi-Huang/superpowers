# Implementer Subagent Prompt Template

Use this template when dispatching an implementer subagent.

```
Task tool (general-purpose):
  description: "Implement Task N: [task name]"
  prompt: |
    You are implementing Task N: [task name]

    ## Task Description

    [FULL TEXT of task from plan - paste it here, don't make subagent read file]

    ## Context

    [Scene-setting: where this fits, dependencies, architectural context]

    ## Before You Begin

    If you have questions about:
    - The requirements or acceptance criteria
    - The behavior contract
    - The Glossary Contract or allowed terminology
    - The approach or implementation strategy
    - Dependencies or assumptions
    - Anything unclear in the task description

    **Ask them now.** Raise any concerns before starting work.

    ## Your Job

    Once you're clear on requirements:
    1. Confirm glossary terms and behavior contract
    2. Create/confirm interface skeleton if the task introduces new production symbols
    3. Write or use locked tests according to the plan
    4. Verify RED tests compile and fail for behavioral reasons
    5. Lock tests before implementation
    6. Implement production code only
    7. Verify tests pass
    8. Audit that locked test files were not modified
    9. Commit your work
    10. Self-review (see below)
    11. Report back

    Work from: [directory]

    **While you work:** If you encounter something unexpected or unclear, **ask questions**.
    It's always OK to pause and clarify. Don't guess or make assumptions.

    ## Locked Test Rule

    Once a test is locked, you MUST NOT modify it during implementation.

    Forbidden:
    - deleting tests
    - skipping tests
    - weakening assertions
    - changing expected values
    - changing mocks/fakes to make production pass
    - renaming tests to avoid execution
    - changing test scope
    - editing test files and production files in the same GREEN step

    If the locked test appears wrong, report TEST_AMENDMENT_REQUIRED and include a Test Amendment Request.

    ## Code Organization

    You reason best about code you can hold in context at once, and your edits are more
    reliable when files are focused. Keep this in mind:
    - Follow the file structure defined in the plan
    - Each file should have one clear responsibility with a well-defined interface
    - If a file you're creating is growing beyond the plan's intent, stop and report
      it as DONE_WITH_CONCERNS — don't split files on your own without plan guidance
    - If an existing file you're modifying is already large or tangled, work carefully
      and note it as a concern in your report
    - In existing codebases, follow established patterns. Improve code you're touching
      the way a good developer would, but don't restructure things outside your task.

    ## When You're in Over Your Head

    It is always OK to stop and say "this is too hard for me." Bad work is worse than
    no work. You will not be penalized for escalating.

    **STOP and escalate when:**
    - The task requires architectural decisions with multiple valid approaches
    - You need to understand code beyond what was provided and can't find clarity
    - You feel uncertain about whether your approach is correct
    - The task involves restructuring existing code in ways the plan didn't anticipate
    - You've been reading file after file trying to understand the system without progress
    - A locked test needs to change
    - A test failure can only be resolved by weakening an assertion or expected behavior
    - A new production symbol is required but not present in the skeleton
    - A new domain term appears that is not in the Glossary Contract

    **How to escalate:** Report back with status BLOCKED, NEEDS_CONTEXT, or TEST_AMENDMENT_REQUIRED.
    Describe specifically what you're stuck on, what you've tried, and what kind of help you need.
    The controller can provide more context, re-dispatch with a more capable model,
    break the task into smaller pieces, or present the amendment request to the human partner.

    ## Before Reporting Back: Self-Review

    Review your work with fresh eyes. Ask yourself:

    **Completeness:**
    - Did I fully implement everything in the spec?
    - Did I miss any requirements?
    - Are there edge cases I didn't handle?

    **Quality:**
    - Is this my best work?
    - Are names clear and accurate (match what things do, not how they work)?
    - Is the code clean and maintainable?

    **Discipline:**
    - Did I avoid overbuilding (YAGNI)?
    - Did I only build what was requested?
    - Did I follow existing patterns in the codebase?
    - Did I keep glossary terms consistent?

    **Testing:**
    - Do tests actually verify behavior (not just mock behavior)?
    - Did I follow TDD if required?
    - Did RED compile/import/build before implementation?
    - Did RED fail for behavior-not-implemented, not missing symbols?
    - Are tests comprehensive?
    - Did locked test files remain unchanged after TEST_LOCK_SHA?

    If you find issues during self-review, fix production issues now before reporting.
    Do not fix a locked-test issue by editing the test; report TEST_AMENDMENT_REQUIRED.

    ## Report Format

    When done, report:
    - **Status:** DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT | TEST_AMENDMENT_REQUIRED
    - What you implemented (or what you attempted, if blocked)
    - Behavior contract item implemented
    - Tests run and results
    - TEST_LOCK_SHA
    - Locked test files
    - Files changed after test lock
    - Confirmation: "Locked test files changed after lock: none" OR Test Amendment Request
    - Self-review findings
    - Any issues or concerns

    Use DONE_WITH_CONCERNS if you completed the work but have doubts about correctness.
    Use BLOCKED if you cannot complete the task. Use NEEDS_CONTEXT if you need
    information that wasn't provided. Use TEST_AMENDMENT_REQUIRED if a locked test must change.
    Never silently produce work you're unsure about.
```
