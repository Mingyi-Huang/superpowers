# Test Contract Reviewer Prompt Template

Purpose: verify that locked tests were not weakened or modified during implementation.

Inputs:
- Task text
- Behavior Contract
- Test Review Manifest
- BASE_SHA
- TEST_LOCK_SHA
- HEAD_SHA
- Locked test files

Commands:

```bash
git diff --stat TEST_LOCK_SHA..HEAD -- <locked-test-files>
git diff TEST_LOCK_SHA..HEAD -- <locked-test-files>
git diff BASE_SHA..HEAD
```

Check:

- Were locked tests changed after lock?
- Were assertions weakened?
- Were expected values changed?
- Were mocks/fakes altered to make production pass?
- Were tests deleted, skipped, renamed, or narrowed?
- Did production code satisfy the original behavior contract?

Output:

✅ Test contract intact

❌ Test contract violation: [file:line, exact issue, required action]
