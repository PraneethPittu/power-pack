# Work Action

> **Part of the power-pack skill.** Processes pending requests with auto-research, implementation, and automated Playwright testing with fix loops.

## CRITICAL: Orchestrator Responsibilities

The work action is an **orchestrator**. You (the orchestrator) are responsible for ALL file management and folder operations. Spawned agents do implementation work but do NOT touch request files, folder structure, or test generation.

**You MUST do these yourself (NEVER delegate to agents):**
- Create folder structure (`mkdir -p pp/working`, `pp/archive`, etc.)
- Move request files between folders
- Update frontmatter status fields
- Generate Playwright test files
- Run the test loop
- Create VERIFICATION.md reports
- Archive completed work
- Create git commits

**Agents do:**
- Research (web search, Context7)
- Explore codebase patterns
- Create implementation plans
- Write the actual code implementation
- Fix code when tests fail

---

## Pre-Flight Checks

**[Orchestrator action - do this yourself BEFORE anything else]**

### Check 1: Folder Structure

**IMPORTANT: You MUST create these folders if they don't exist. Do NOT skip this step.**

```bash
mkdir -p pp/config
mkdir -p pp/research
mkdir -p pp/working
mkdir -p pp/archive
mkdir -p tests/pp
```

Run this command NOW before proceeding.

### Check 2: Session Preferences

Check if session preferences have been set. If not, you should have asked during `/pp status` or first command:
- Session mode (Normal/Overnight)
- Auto-commit (Yes/No)
- Playwright testing (Yes/No)

### Check 3: Test Environment (if Playwright enabled)

**If user selected "Yes" for Playwright testing:**

```bash
cat pp/config/test-env.json 2>/dev/null
```

If this file doesn't exist AND Playwright testing is enabled:
- STOP and ask user for test credentials
- Create `pp/config/test-env.json` with credentials
- Add to `.gitignore`

**If user selected "No" for Playwright testing:**
- Skip test-env.json check entirely
- Skip Steps 8-10 (test generation, test loop, verification) during workflow

### Check 4: Pending Requests

```bash
ls pp/REQ-*.md 2>/dev/null
```

If no REQ files found, report: "Queue empty. Use `/pp add <task>` to capture tasks."

---

## Workflow Steps

### Step 1: Find Next Request

**[Orchestrator action - do this yourself]**

```bash
ls pp/REQ-*.md 2>/dev/null | head -1
```

Pick the first REQ file (sorted by number). If empty, exit with "Queue empty."

### Step 2: Claim the Request

**[Orchestrator action - do this yourself, BEFORE spawning any agents]**

**IMPORTANT: You MUST perform these file operations yourself. Do NOT skip them.**

1. **Create working folder:**
```bash
mkdir -p pp/working
```

2. **Move request file:**
```bash
mv pp/REQ-XXX-slug.md pp/working/
```

3. **Update frontmatter** in the moved file:
```yaml
---
status: claimed
claimed_at: 2026-02-03T10:30:00Z
---
```

4. **Update STATE.md:**
```markdown
## Current Position

**Status:** working
**Working on:** REQ-XXX-slug
**Step:** claim
**Last activity:** [timestamp]
```

**DO NOT proceed to the next step until the file is moved to working/.**

### Step 3: Analyze — Needs Research?

**[Orchestrator action - do this yourself]**

Read the task content and determine if research is needed.

**Research triggers (if ANY match → needs research):**
- External APIs: `stripe`, `twilio`, `firebase`, `aws`, `sendgrid`
- Protocols: `oauth`, `jwt`, `websocket`, `graphql`, `grpc`
- Real-time: `real-time`, `realtime`, `live update`, `push notification`
- Payments: `payment`, `checkout`, `billing`, `subscription`
- New tech: unfamiliar libraries, SDKs, frameworks

**Skip research for:**
- Bug fixes, UI changes, config changes, simple CRUD, refactoring

**Update frontmatter:**
```yaml
---
status: claimed
needs_research: true  # or false
---
```

**Append to request file:**
```markdown
---

## Analysis

**Needs Research:** Yes/No
**Reason:** [Brief explanation]
**Detected triggers:** [list any matching patterns]
```

### Step 4: Research (If Needed)

**[Spawn agents for research, then orchestrator writes results]**

**If `needs_research: false`:** Skip to Step 5.

**If `needs_research: true`:**

1. **Create research folder:**
```bash
mkdir -p pp/research
```

2. **Spawn research** using WebSearch and/or Context7:
   - Best practices for the technology
   - Recommended libraries/versions
   - Common pitfalls to avoid

3. **Create research file** at `pp/research/REQ-XXX-RESEARCH.md`:
```markdown
# Research: REQ-XXX [Title]

**Generated:** [timestamp]
**Topic:** [technology]

## Recommended Stack
| Component | Choice | Version | Reason |
|-----------|--------|---------|--------|

## Implementation Patterns
[Code examples]

## Common Pitfalls
| Pitfall | Prevention |
|---------|------------|

## References
- [sources]
```

4. **Update frontmatter:**
```yaml
---
status: researched
research_file: pp/research/REQ-XXX-RESEARCH.md
---
```

5. **Update STATE.md:** `Step: researched`

### Step 5: Explore Codebase

**[Spawn Explore agent, then orchestrator stores results]**

Spawn an **Explore agent**:

```
Task(prompt="
For this request:

## Request
[Full content of request file]

## Research (if exists)
[Summary from RESEARCH.md]

Find the relevant files and patterns:
1. Where should this change be made?
2. What existing patterns should we follow?
3. Related types/interfaces
4. Testing patterns

Return specific file paths and code patterns.
", subagent_type="Explore")
```

**After Explore agent returns:**
- Store exploration output for implementation
- Update STATE.md: `Step: explored`

**Append to request file:**
```markdown
## Exploration

[Output from Explore agent]

*Generated by Explore agent*
```

### Step 6: Plan (Complex Tasks Only)

**[Spawn Plan agent for complex tasks, orchestrator writes plan to file]**

**Triggers for planning:**
- Exploration found 5+ files to modify
- New architectural pattern needed
- Research recommended specific implementation order

If simple task, skip planning and append:
```markdown
## Plan

**Planning not required** - Simple task, direct implementation.

*Skipped by work action*
```

For complex tasks, spawn **Plan agent** and append full plan to request file.

### Step 7: Implement the Feature

**[Spawn general-purpose agent - agent writes code, orchestrator monitors]**

Spawn a **general-purpose agent** with all context:

```
Task(prompt="
Implement this feature:

## Request
[Full content of request file]

## Research Context (if exists)
[From RESEARCH.md]

## Codebase Context
[From Explore agent]

## Implementation Plan (if exists)
[From Plan agent]

## Instructions
- Follow the plan and patterns
- Focus on 'Done When' criteria
- Make minimal, focused changes

When complete, provide a summary of files changed.
", subagent_type="general-purpose")
```

**After implementation:**
- Capture summary of changes
- Update STATE.md: `Step: implemented`

**Append to request file:**
```markdown
## Implementation Summary

[Summary from agent]

*Completed by general-purpose agent*
```

### Step 8: Generate Playwright Tests

**[Orchestrator action - do this yourself]**

**SKIP this step if user selected "No" for Playwright testing.**

**IMPORTANT: You MUST create the test file yourself. Do NOT delegate to agents.**

1. **Create tests folder:**
```bash
mkdir -p tests/pp
```

2. **Read test config:**
```bash
cat pp/config/test-env.json
```

3. **Read "Done When" criteria** from the request file

4. **Create test file** at `tests/pp/REQ-XXX-slug.spec.js`:

```javascript
const { test, expect } = require('@playwright/test');

const config = {
  loginUrl: '[from test-env.json]',
  username: '[from test-env.json]',
  password: '[from test-env.json]',
  baseUrl: '[from test-env.json]',
  testUrl: '[from REQ frontmatter or determine from feature]'
};

test.describe('REQ-XXX: [Title]', () => {

  test.beforeEach(async ({ page }) => {
    // Login
    await page.goto(config.loginUrl);
    await page.locator('[name="username"], [name="email"], #username, #email').first().fill(config.username);
    await page.locator('[name="password"], #password').first().fill(config.password);
    await page.locator('button[type="submit"], input[type="submit"]').first().click();
    await page.waitForURL(url => !url.pathname.includes('login'), { timeout: 10000 });

    // Navigate to test page
    await page.goto(config.testUrl);
    await page.waitForLoadState('networkidle');
  });

  // One test per "Done When" criterion
  test('[criterion 1]', async ({ page }) => {
    // assertion
  });

  test('[criterion 2]', async ({ page }) => {
    // assertion
  });

});
```

5. **Update STATE.md:** `Step: tests_generated`

### Step 9: Run Test Loop

**[Orchestrator action - do this yourself]**

**SKIP this step if Playwright testing is disabled.**

**IMPORTANT: You MUST run this loop yourself. Do NOT skip it.**

Initialize tracking:
```
test_attempts = {}  # { "test name": attempt_count }
skipped_tests = []
max_attempts = 10
```

**Test Loop:**

```
WHILE there are non-skipped tests:

    1. Run tests:
       npx playwright test tests/pp/REQ-XXX-*.spec.js --reporter=list

    2. IF all tests pass:
       → EXIT LOOP (success)

    3. FOR each failed test:

       a. Classify failure:
          - Infrastructure (403, 401, CORS, connection refused, SSL)
            → Mark as SKIPPED (infra), continue

          - Playwright crash (browser closed, target closed)
            → Mark as SKIPPED (playwright), continue

          - Code issue (500, assertion failed, element not found)
            → Proceed to fix attempt

       b. Check attempt count:
          IF test_attempts[test_name] >= 10:
            → Mark as SKIPPED (max_attempts), continue

       c. Increment attempt counter:
          test_attempts[test_name] += 1

       d. Analyze and fix:
          - Read error message
          - Fix the CODE (not the test)
          - Use Edit tool to make changes

    4. RERUN all non-skipped tests
```

**Update STATE.md after each iteration:**
```markdown
## In Progress

| Field | Value |
|-------|-------|
| Step | testing |
| Tests total | 5 |
| Tests passed | 3 |
| Tests skipped | 1 |
| Current test | [name] |
| Attempt | 4/10 |
| Last error | [error] |
```

### Step 10: Generate Verification Report

**[Orchestrator action - do this yourself]**

**SKIP this step if Playwright testing is disabled.**

**Create** `pp/working/REQ-XXX-VERIFICATION.md`:

```markdown
# Verification Report: REQ-XXX [Title]

**Status:** [PASS | PARTIAL | FAIL]
**Date:** [timestamp]
**Test File:** tests/pp/REQ-XXX-slug.spec.js

## Results

| Test | Status | Attempts | Notes |
|------|--------|----------|-------|
| [test 1] | ✓ PASS | 1 | |
| [test 2] | ✓ PASS | 3 | Fixed: [what] |
| [test 3] | ⚠ SKIPPED | 10 | Max attempts |
| [test 4] | ⚠ SKIPPED | 1 | 403 Forbidden (infra) |

## Skipped Tests

### [test name]
- **Reason:** [max_attempts | infra_permission | infra_connection]
- **Last error:** [error message]
- **Recommendation:** [what to check]

## Auto-Fixed During Testing

| Test | Error | Fix Applied | Attempt |
|------|-------|-------------|---------|
| [test] | [error] | [fix] | [#] |

## Summary

- **Passed:** X/Y tests
- **Skipped:** Z tests
- **Auto-fixed:** N issues

---
*Generated by power-pack automated testing*
```

### Step 11: Archive

**[Orchestrator action - do this yourself]**

**IMPORTANT: You MUST perform these operations. Do NOT skip.**

1. **Update request frontmatter:**
```yaml
---
status: completed
completed_at: 2026-02-03T11:00:00Z
tests_passed: X
tests_skipped: Y
tests_total: Z
---
```

2. **Create archive folder:**
```bash
mkdir -p pp/archive
```

3. **Move files to archive:**
```bash
mv pp/working/REQ-XXX-*.md pp/archive/
```

4. **Handle UR folder** (if applicable):
   - Check if all REQs for this UR are complete
   - If yes, move UR folder to archive

5. **Update STATE.md:**
```markdown
## Current Position

**Status:** idle
**Working on:** None

## Recent Completions

| REQ | Title | Tests | Result | Commit | Date |
|-----|-------|-------|--------|--------|------|
| REQ-XXX | [title] | X/Y | ✓ | [hash] | [date] |
```

### Step 12: Commit (If Enabled)

**[Orchestrator action - do this yourself]**

**Check session preference:** Only commit if auto-commit = Yes.

**If auto-commit disabled:**
```
Skipping commit (auto-commit disabled).
Changes ready. Run `git add . && git commit` when ready.
```

**If auto-commit enabled:**

```bash
git add -A
git commit -m "$(cat <<'EOF'
[REQ-XXX] Title

Implements: pp/archive/REQ-XXX-slug.md
Tests: tests/pp/REQ-XXX-slug.spec.js

- [implementation summary bullets]
- Tests: X/Y passed, Z skipped

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

**Update request frontmatter with commit hash.**

### Step 13: Loop or Exit

**[Orchestrator action - do this yourself]**

```bash
ls pp/REQ-*.md 2>/dev/null
```

- If more REQ files found: Report completion, then start Step 1 again
- If empty: Report final summary and exit

---

## Orchestrator Checklist (per request)

**Use this checklist to ensure you don't skip critical steps:**

```
□ Pre-flight: mkdir -p pp/{config,research,working,archive} tests/pp
□ Pre-flight: Check test-env.json exists (if Playwright enabled)
□ Step 1: ls pp/REQ-*.md, pick first one
□ Step 2: mv pp/REQ-XXX.md pp/working/
□ Step 2: Update frontmatter: status: claimed
□ Step 3: Analyze for research needs, append ## Analysis section
□ Step 4: (if needed) Create pp/research/REQ-XXX-RESEARCH.md
□ Step 5: Spawn Explore agent, append ## Exploration section
□ Step 6: (if complex) Spawn Plan agent, append ## Plan section
□ Step 7: Spawn implementation agent, append ## Implementation Summary
□ Step 8: (if Playwright enabled) Create tests/pp/REQ-XXX.spec.js
□ Step 9: (if Playwright enabled) Run test loop until pass/skip
□ Step 10: (if Playwright enabled) Create pp/working/REQ-XXX-VERIFICATION.md
□ Step 11: Update frontmatter: status: completed
□ Step 11: mv pp/working/REQ-XXX*.md pp/archive/
□ Step 12: (if auto-commit) git add -A && git commit
□ Step 13: Check for more REQs, loop or exit
```

---

## Common Mistakes to Avoid

- **NOT creating folders first** - Always run mkdir -p before moving files
- **Skipping the claim step** - File MUST be in working/ before implementation
- **Delegating file operations to agents** - You must move files yourself
- **Forgetting test generation** - Create the spec.js file yourself
- **Skipping the test loop** - Run tests even if implementation "looks good"
- **Not archiving** - Files MUST move to archive/ when complete
- **Implementing directly** - Never implement without first claiming the REQ file

---

## Progress Reporting

Keep user informed:

```
Processing REQ-013-logout-button.md...
  Claiming...          [done] → moved to working/
  Analyzing...         [done] → no research needed
  Exploring...         [done] → found patterns
  Implementing...      [done] → 2 files changed
  Generating tests...  [done] → 4 test cases
  Running tests...
    ✓ logout button exists (1/1)
    ✓ logout redirects (3/3) — fixed: redirect path
    ⚠ session cleared (10/10) — SKIPPED: max attempts
  Verification...      [done] → VERIFICATION.md created
  Archiving...         [done] → moved to archive/
  Committing...        [done] → abc1234

⚠ 1 test skipped. See VERIFICATION.md for details.

Checking for more requests...
Queue empty. Done!
```

---

## Checkpoints (Session Mode Dependent)

**Normal mode:** Pause at decision points, ask user
**Overnight mode:** Auto-select recommended option, log decision

Checkpoint triggers:
- Multiple valid approaches (use research recommendation)
- Destructive actions (SKIP in overnight mode)
- External side effects (SKIP in overnight mode)

Log all decisions to STATE.md.
