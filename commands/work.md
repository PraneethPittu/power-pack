---
name: pp:work
description: Process all pending tasks in the queue with research, implementation, and testing
---

<objective>
Process pending requests with auto-research, implementation, and automated Playwright testing with fix loops.
</objective>

<orchestrator_rules>
**You are the orchestrator. You MUST do these yourself (NEVER delegate to agents):**
- Create folder structure
- Move request files between folders
- Update frontmatter status
- Generate Playwright test files
- Run the test loop
- Create VERIFICATION.md reports
- Archive completed work
- Create git commits

**Agents do:**
- Research (web search)
- Explore codebase patterns
- Create implementation plans
- Write actual code
- Fix code when tests fail
</orchestrator_rules>

<process>

<step name="preflight">
## Pre-Flight Checks

**1. Create folders:**
```bash
mkdir -p pp/config pp/research pp/working pp/archive tests/pp
```

**2. Check session preferences (from STATE.md):**
- Session mode (Normal/Overnight)
- Auto-commit (Yes/No)
- Playwright testing (Yes/No)

**3. If Playwright enabled, check test-env.json:**
```bash
cat pp/config/test-env.json 2>/dev/null || echo "NOT_FOUND"
```
If missing, STOP and ask for credentials.

**4. Check for pending requests:**
```bash
ls pp/REQ-*.md 2>/dev/null || echo "NO_REQUESTS"
```
If empty: "Queue empty. Use /pp:add to capture tasks."
</step>

<step name="step1_find">
## Step 1: Find Next Request

```bash
ls pp/REQ-*.md 2>/dev/null | head -1
```

Pick the first REQ file.
</step>

<step name="step2_claim">
## Step 2: Claim the Request

**YOU MUST do this yourself:**

```bash
mkdir -p pp/working
mv pp/REQ-XXX-slug.md pp/working/
```

Update frontmatter:
```yaml
status: claimed
claimed_at: [timestamp]
```

Update STATE.md:
```
Status: working
Working on: REQ-XXX-slug
Step: claim
```

**DO NOT proceed until file is in working/.**
</step>

<step name="step3_analyze">
## Step 3: Analyze — Needs Research?

**Research triggers:**
- External APIs: stripe, twilio, firebase, aws
- Protocols: oauth, jwt, websocket, graphql
- Real-time: live update, push notification
- Payments: payment, checkout, billing

**Skip research for:** Bug fixes, UI changes, config changes, simple CRUD

Append to request file:
```markdown
## Analysis

**Needs Research:** Yes/No
**Reason:** [explanation]
```
</step>

<step name="step4_research">
## Step 4: Research (If Needed)

If `needs_research: false`: Skip to Step 5.

If `needs_research: true`:
1. Create `pp/research/REQ-XXX-RESEARCH.md`
2. Use WebSearch for best practices
3. Document recommended stack, patterns, pitfalls
</step>

<step name="step5_explore">
## Step 5: Explore Codebase

Spawn **Explore agent**:
```
Task(prompt="
For this request: [content]
Find: Where to make changes, existing patterns, related types, testing patterns.
Return specific file paths.
", subagent_type="Explore")
```

Append exploration results to request file.
</step>

<step name="step6_plan">
## Step 6: Plan (Complex Tasks Only)

**Triggers:** 5+ files, new architecture, research recommended order

Simple task: Skip, append "Planning not required".
Complex task: Spawn Plan agent, append plan.
</step>

<step name="step7_implement">
## Step 7: Implement

Spawn **general-purpose agent**:
```
Task(prompt="
Implement this feature:
[Request content]
[Research context]
[Codebase context]
[Plan if exists]

Focus on 'Done When' criteria. Make minimal changes.
", subagent_type="general-purpose")
```

Append implementation summary to request file.
Update STATE.md: `Step: implemented`
</step>

<step name="step8_generate_tests">
## Step 8: Generate Playwright Tests

**SKIP if Playwright testing disabled.**

**YOU MUST create the test file yourself:**

```bash
mkdir -p tests/pp
```

Create `tests/pp/REQ-XXX-slug.spec.js`:
```javascript
const { test, expect } = require('@playwright/test');

const config = {
  loginUrl: '[from test-env.json]',
  username: '[from test-env.json]',
  password: '[from test-env.json]',
  baseUrl: '[from test-env.json]',
  testUrl: '[from REQ or determine]'
};

test.describe('REQ-XXX: [Title]', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto(config.loginUrl);
    await page.locator('[name="username"], [name="email"], #username').first().fill(config.username);
    await page.locator('[name="password"], #password').first().fill(config.password);
    await page.locator('button[type="submit"]').first().click();
    await page.waitForURL(url => !url.pathname.includes('login'), { timeout: 10000 });
    await page.goto(config.testUrl);
  });

  // One test per "Done When" criterion
  test('[criterion 1]', async ({ page }) => {
    // assertion
  });
});
```
</step>

<step name="step9_test_loop">
## Step 9: Run Test Loop

**SKIP if Playwright testing disabled.**

```
test_attempts = {}
skipped_tests = []
max_attempts = 10

WHILE non-skipped tests remain:
  1. Run: npx playwright test tests/pp/REQ-XXX-*.spec.js --reporter=list

  2. IF all pass → EXIT (success)

  3. FOR each failed test:
     - Infrastructure error (403, 401, CORS) → SKIP
     - Playwright crash → SKIP
     - Code error → Fix attempt

     IF attempts >= 10 → SKIP
     ELSE: Fix code, increment attempts

  4. RERUN
```

Update STATE.md after each iteration.
</step>

<step name="step10_verification">
## Step 10: Verification Report

**SKIP if Playwright testing disabled.**

Create `pp/working/REQ-XXX-VERIFICATION.md`:
```markdown
# Verification Report: REQ-XXX [Title]

**Status:** [PASS | PARTIAL | FAIL]
**Date:** [timestamp]

## Results
| Test | Status | Attempts | Notes |
|------|--------|----------|-------|
| [test] | ✓ PASS | 1 | |
| [test] | ⚠ SKIPPED | 10 | Max attempts |

## Summary
- **Passed:** X/Y tests
- **Skipped:** Z tests
```
</step>

<step name="step11_archive">
## Step 11: Archive

**YOU MUST do this:**

Update frontmatter:
```yaml
status: completed
completed_at: [timestamp]
tests_passed: X
tests_skipped: Y
```

```bash
mkdir -p pp/archive
mv pp/working/REQ-XXX*.md pp/archive/
```

Update STATE.md:
```
Status: idle
Working on: None
```
</step>

<step name="step12_commit">
## Step 12: Commit (If Enabled)

**Only if auto-commit = Yes:**

```bash
git add -A
git commit -m "[REQ-XXX] Title

- [implementation summary]
- Tests: X/Y passed

Co-Authored-By: Claude <noreply@anthropic.com>"
```
</step>

<step name="step13_loop">
## Step 13: Loop or Exit

```bash
ls pp/REQ-*.md 2>/dev/null
```

- More REQs → Start Step 1 again
- Empty → Report summary, exit
</step>

</process>

<checklist>
## Orchestrator Checklist

```
□ Pre-flight: mkdir -p pp/{config,research,working,archive} tests/pp
□ Pre-flight: Check test-env.json (if Playwright enabled)
□ Step 2: mv pp/REQ-XXX.md pp/working/
□ Step 2: Update frontmatter: status: claimed
□ Step 3: Append ## Analysis section
□ Step 4: (if needed) Create RESEARCH.md
□ Step 5: Spawn Explore, append ## Exploration
□ Step 6: (if complex) Spawn Plan, append ## Plan
□ Step 7: Spawn implementation, append ## Implementation Summary
□ Step 8: (if Playwright) Create tests/pp/REQ-XXX.spec.js
□ Step 9: (if Playwright) Run test loop
□ Step 10: (if Playwright) Create VERIFICATION.md
□ Step 11: Update frontmatter: status: completed
□ Step 11: mv pp/working/*.md pp/archive/
□ Step 12: (if auto-commit) git commit
□ Step 13: Loop or exit
```
</checklist>

<progress_reporting>
## Progress Format

```
Processing REQ-013-logout-button.md...
  Claiming...          [done] → moved to working/
  Analyzing...         [done] → no research needed
  Exploring...         [done] → found patterns
  Implementing...      [done] → 2 files changed
  Generating tests...  [done] → 4 test cases
  Running tests...
    ✓ logout button exists (1/1)
    ✓ logout redirects (3/3) — fixed: path
    ⚠ session cleared (10/10) — SKIPPED
  Verification...      [done]
  Archiving...         [done]
  Committing...        [done] → abc1234

Queue empty. Done!
```
</progress_reporting>

<checkpoints>
## Checkpoints (Mode Dependent)

**Normal mode:** Pause and ask user
**Overnight mode:** Auto-select recommended, log to STATE.md

Triggers:
- Multiple valid approaches
- Destructive actions (SKIP in overnight)
- External side effects (SKIP in overnight)
</checkpoints>
