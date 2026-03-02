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
mkdir -p pp/rephrased
mkdir -p pp/plans
mkdir -p tests/pp
mkdir -p tests/pp/screenshots
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

### Step 6: Load Plan from Capture Phase

**[Orchestrator action — plans are created during /pp:add, not here]**

Plans are now created during the capture phase (Step 6 of `/pp:add`). Load the existing plan:

1. **Read the plan file** referenced in the REQ frontmatter:
```bash
cat pp/plans/REQ-XXX-plan.md
```

2. **Append plan summary to request file:**
```markdown
## Plan

See [pp/plans/REQ-XXX-plan.md] for full implementation plan.

**Key steps:**
- [summary of implementation steps from plan]

*Plan created during capture phase*
```

3. **If plan file is missing** (edge case — old REQ without plan):
   - Enter plan mode now using EnterPlanMode
   - Create the plan file at `pp/plans/REQ-XXX-plan.md`
   - Then continue

**The implementation agent (Step 7) receives this plan as context.**

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

### Step 8: Generate Playwright Tests (Functionality + UI Screenshot Tests)

**[Orchestrator action - do this yourself]**

**SKIP this step if user selected "No" for Playwright testing.**

**IMPORTANT: You MUST create the test file yourself. Do NOT delegate to agents.**

**ZERO TOLERANCE POLICY:** Tests must cover EVERY corner case — both functionality AND UI. Nothing is too small to test. Alignment issues, spacing, hover states, responsive behavior, error states — everything matters.

1. **Create test and screenshot folders:**
```bash
mkdir -p tests/pp
mkdir -p tests/pp/screenshots
```

2. **Read test config:**
```bash
cat pp/config/test-env.json
```

3. **Read "Done When" criteria AND implementation plan** from the request file

4. **Create test file** at `tests/pp/REQ-XXX-slug.spec.js`:

```javascript
const { test, expect } = require('@playwright/test');
const path = require('path');

const config = {
  loginUrl: '[from test-env.json]',
  username: '[from test-env.json]',
  password: '[from test-env.json]',
  baseUrl: '[from test-env.json]',
  testUrl: '[from REQ frontmatter or determine from feature]'
};

const screenshotDir = path.join(__dirname, 'screenshots', 'REQ-XXX');

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
    await page.waitForLoadState('domcontentloaded');
  });

  // ==========================================
  // FUNCTIONALITY TESTS
  // One test per "Done When" criterion + edge cases
  // ==========================================

  test('functionality: [criterion 1]', async ({ page }) => {
    // assertion
    // Take screenshot after test action
    await page.screenshot({ path: path.join(screenshotDir, 'func-criterion1.png'), fullPage: true });
  });

  test('functionality: [criterion 2]', async ({ page }) => {
    // assertion
    await page.screenshot({ path: path.join(screenshotDir, 'func-criterion2.png'), fullPage: true });
  });

  // Edge case tests
  test('functionality: [edge case - empty input]', async ({ page }) => {
    // Test empty/null/edge case scenarios
    await page.screenshot({ path: path.join(screenshotDir, 'func-edge-empty.png'), fullPage: true });
  });

  test('functionality: [edge case - error handling]', async ({ page }) => {
    // Test error states
    await page.screenshot({ path: path.join(screenshotDir, 'func-edge-error.png'), fullPage: true });
  });

  // ==========================================
  // UI SCREENSHOT TESTS
  // Check visual appearance, alignment, spacing
  // ==========================================

  test('ui: initial render - full page screenshot', async ({ page }) => {
    // Take full page screenshot for overall layout check
    await page.screenshot({ path: path.join(screenshotDir, 'ui-initial-fullpage.png'), fullPage: true });
  });

  test('ui: feature element screenshot', async ({ page }) => {
    // Screenshot of the specific feature element
    const element = page.locator('[selector-for-feature]');
    await element.screenshot({ path: path.join(screenshotDir, 'ui-feature-element.png') });
  });

  test('ui: hover/active states', async ({ page }) => {
    // Test hover states
    const element = page.locator('[selector-for-interactive-element]');
    await element.hover();
    await page.screenshot({ path: path.join(screenshotDir, 'ui-hover-state.png'), fullPage: false });
  });

  test('ui: responsive - mobile viewport', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 812 });
    await page.screenshot({ path: path.join(screenshotDir, 'ui-mobile.png'), fullPage: true });
  });

  test('ui: responsive - tablet viewport', async ({ page }) => {
    await page.setViewportSize({ width: 768, height: 1024 });
    await page.screenshot({ path: path.join(screenshotDir, 'ui-tablet.png'), fullPage: true });
  });

});
```

**Test generation rules:**
- One test per "Done When" criterion (functionality)
- Edge case tests for: empty input, invalid input, boundary values, error states, concurrent actions
- UI tests: full page screenshot, feature element screenshot, hover/active states, responsive viewports
- EVERY test takes at least one screenshot
- Screenshots go to `tests/pp/screenshots/REQ-XXX/`

5. **Update STATE.md:** `Step: tests_generated`

### Step 9: Run Test Loop with Screenshot Verification (ZERO TOLERANCE)

**[Orchestrator action - do this yourself]**

**SKIP this step if Playwright testing is disabled.**

**ZERO TOLERANCE: Every test must pass. No skipping code-fixable failures. Only infrastructure failures can be skipped.**

Initialize tracking:
```
test_attempts = {}  # { "test name": attempt_count }
skipped_tests = []
max_attempts = 10
```

**Test Loop:**

```
WHILE there are non-skipped tests that haven't passed:

    1. Run tests:
       npx playwright test tests/pp/REQ-XXX-*.spec.js --reporter=list

    2. IF all tests pass:
       → Proceed to SCREENSHOT REVIEW (Step 9b)

    3. FOR each failed test:

       a. Classify failure:
          - Infrastructure ONLY (403, 401, CORS, connection refused, SSL)
            → Mark as SKIPPED (infra) — ONLY infrastructure issues can be skipped

          - Playwright crash (browser closed, target closed)
            → Fix the test setup, retry — do NOT skip

          - Code issue (500, assertion failed, element not found)
            → MUST FIX — proceed to fix attempt

       b. Check attempt count:
          IF test_attempts[test_name] >= max_attempts:
            → DO NOT SKIP — analyze deeper, try different fix approach
            → Only skip if truly unfixable (infrastructure issue)

       c. Increment attempt counter:
          test_attempts[test_name] += 1

       d. Analyze and fix:
          - Read error message
          - Fix the CODE (not the test) — unless the test has a bug
          - Use Edit tool to make changes
          - If stuck after 5 attempts, try a completely different approach

    4. RERUN all non-skipped tests
```

### Step 9b: Screenshot Review (ZERO TOLERANCE UI CHECK)

**After all functionality tests pass, review EVERY screenshot for UI issues.**

1. **Read each screenshot** using the Read tool (which can read images):

```bash
# List all screenshots for this REQ
ls tests/pp/screenshots/REQ-XXX/
```

2. **For EACH screenshot, check for:**

   **Layout & Alignment:**
   - Elements properly aligned (horizontally and vertically)
   - Consistent spacing between elements
   - No overlapping elements
   - Proper margins and padding
   - Content centered where expected

   **Visual Quality:**
   - Text readable and properly sized
   - Colors consistent with the design
   - No cut-off text or elements
   - Icons properly sized and aligned
   - Borders and shadows consistent

   **Responsiveness (from mobile/tablet screenshots):**
   - Content not overflowing viewport
   - Touch targets large enough (min 44px)
   - Text not too small on mobile
   - Layout adapts properly
   - No horizontal scroll

   **Interactive States:**
   - Hover states visible and correct
   - Active/pressed states appropriate
   - Focus indicators present
   - Disabled states visually distinct

3. **If ANY UI issue is found, no matter how small:**
   - Document the issue
   - Fix the code (CSS, HTML, JS as needed)
   - Re-run the affected test to get a new screenshot
   - Re-review the new screenshot
   - Repeat until PERFECT

4. **UI Review Loop:**
```
ui_issues_found = true

WHILE ui_issues_found:
    1. Read all screenshots
    2. Check for issues (alignment, spacing, visual, responsive)
    3. IF issues found:
       - Log each issue
       - Fix the code
       - Re-run affected tests to regenerate screenshots
       - ui_issues_found = true
    4. IF no issues found:
       - ui_issues_found = false
       - All screenshots are CLEAN
```

**CRITICAL: Do not proceed to Step 10 until:**
- ALL functionality tests pass (100%)
- ALL screenshots reviewed and approved (zero UI issues)
- Responsive tests pass on mobile and tablet viewports

**Update STATE.md after each iteration:**
```markdown
## In Progress

| Field | Value |
|-------|-------|
| Step | testing |
| Tests total | 12 |
| Func tests passed | 6/6 |
| UI tests passed | 4/6 |
| Screenshots reviewed | 8/10 |
| UI issues found | 2 |
| UI issues fixed | 1 |
| Current fix | Alignment on mobile |
| Attempt | 4 |
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
**Screenshots:** tests/pp/screenshots/REQ-XXX/

## Functionality Test Results

| Test | Status | Attempts | Notes |
|------|--------|----------|-------|
| [func test 1] | ✓ PASS | 1 | |
| [func test 2] | ✓ PASS | 3 | Fixed: [what] |
| [edge case 1] | ✓ PASS | 1 | |

## UI Screenshot Review Results

| Screenshot | Status | Issues Found | Issues Fixed | Notes |
|------------|--------|-------------|-------------|-------|
| ui-initial-fullpage.png | ✓ CLEAN | 0 | 0 | |
| ui-feature-element.png | ✓ CLEAN | 1 | 1 | Fixed: button alignment |
| ui-mobile.png | ✓ CLEAN | 2 | 2 | Fixed: overflow, font size |
| ui-tablet.png | ✓ CLEAN | 0 | 0 | |
| ui-hover-state.png | ✓ CLEAN | 0 | 0 | |

## UI Issues Found & Fixed

| Issue | Screenshot | Severity | Fix Applied |
|-------|-----------|----------|-------------|
| Button misaligned by 2px | ui-feature-element.png | Minor | Adjusted margin-left |
| Text overflow on mobile | ui-mobile.png | Major | Added text-overflow: ellipsis |
| Font too small on mobile | ui-mobile.png | Major | Increased to 14px min |

## Skipped Tests (Infrastructure Only)

### [test name]
- **Reason:** [infra_permission | infra_connection]
- **Last error:** [error message]
- **Recommendation:** [what to check]

## Auto-Fixed During Testing

| Test | Error | Fix Applied | Attempt |
|------|-------|-------------|---------|
| [test] | [error] | [fix] | [#] |

## Summary

- **Functionality:** X/Y tests passed
- **UI Screenshots:** X/Y clean (Z issues found and fixed)
- **Responsive:** Tested on desktop, tablet (768px), mobile (375px)
- **Skipped:** Z tests (infrastructure only)
- **Auto-fixed:** N functionality issues, M UI issues

---
*Generated by power-pack zero-tolerance automated testing*
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
□ Pre-flight: mkdir -p pp/{config,research,working,archive,rephrased,plans} tests/pp tests/pp/screenshots
□ Pre-flight: Check test-env.json exists (if Playwright enabled)
□ Step 1: ls pp/REQ-*.md, pick first one
□ Step 2: mv pp/REQ-XXX.md pp/working/
□ Step 2: Update frontmatter: status: claimed
□ Step 3: Analyze for research needs, append ## Analysis section
□ Step 4: (if needed) Create pp/research/REQ-XXX-RESEARCH.md
□ Step 5: Spawn Explore agent, append ## Exploration section
□ Step 6: Load plan from pp/plans/REQ-XXX-plan.md (created during capture)
□ Step 7: Spawn implementation agent with plan context, append ## Implementation Summary
□ Step 8: (if Playwright) Create tests/pp/REQ-XXX.spec.js with functionality + UI screenshot tests
□ Step 9: (if Playwright) Run test loop — ZERO TOLERANCE until ALL functionality tests pass
□ Step 9b: (if Playwright) Screenshot review — read EVERY screenshot, fix ALL UI issues, loop until perfect
□ Step 10: (if Playwright) Create pp/working/REQ-XXX-VERIFICATION.md with functionality + UI results
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
  Claiming...              [done] → moved to working/
  Analyzing...             [done] → no research needed
  Exploring...             [done] → found patterns
  Loading plan...          [done] → pp/plans/REQ-013-plan.md
  Implementing...          [done] → 2 files changed
  Generating tests...      [done] → 6 functionality + 5 UI tests
  Running functionality...
    ✓ func: logout button exists (1/1)
    ✓ func: logout redirects (3/3) — fixed: redirect path
    ✓ func: session cleared (2/2) — fixed: cookie clearing
    ✓ func: edge - double click (1/1)
  Screenshot review...
    ✓ ui-initial-fullpage.png — clean
    ✓ ui-feature-element.png — fixed: button padding (2px off)
    ✓ ui-hover-state.png — clean
    ✓ ui-mobile.png — fixed: overflow on small screens
    ✓ ui-tablet.png — clean
  Verification...          [done] → VERIFICATION.md created
  Archiving...             [done] → moved to archive/
  Committing...            [done] → abc1234

All tests passed. 2 UI issues found and fixed.

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
