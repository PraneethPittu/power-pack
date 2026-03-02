---
name: pp:work
description: Process all pending tasks in the queue with research, implementation, and testing
---

<objective>
Process pending requests with auto-research, implementation, and zero-tolerance Playwright testing (functionality + UI screenshot verification).
</objective>

<enforcement>
## STRICT COMPLIANCE REQUIRED

**You MUST follow EVERY step below in EXACT order. DO NOT skip, reorder, or combine steps.**

**READ the full action file BEFORE doing anything:**
```bash
cat ~/.claude/skills/pp/actions/work.md
```

**Follow the action file instructions step by step. The steps below are a summary — the action file has full details.**
</enforcement>

<orchestrator_rules>
**You are the orchestrator. You MUST do these yourself (NEVER delegate to agents):**
- Create folder structure
- Move request files between folders
- Update frontmatter status
- Generate Playwright test files (functionality + UI screenshot tests)
- Run the test loop
- Review screenshots for UI issues
- Create VERIFICATION.md reports
- Archive completed work
- Create git commits

**Agents do:**
- Research (web search)
- Explore codebase patterns
- Write actual code
- Fix code when tests fail
</orchestrator_rules>

<process>

<step name="preflight">
## Pre-Flight Checks

**1. Create ALL folders:**
```bash
mkdir -p pp/config pp/research pp/working pp/archive pp/rephrased pp/plans tests/pp tests/pp/screenshots
```

**2. Check session preferences (if not set, ask the 4 questions from /pp:add session_setup)**

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
</step>

<step name="step2_claim">
## Step 2: Claim the Request

**YOU MUST do this yourself:**

```bash
mkdir -p pp/working
mv pp/REQ-XXX-slug.md pp/working/
```

Update frontmatter: `status: claimed`
Update STATE.md: `Step: claim`

**DO NOT proceed until file is in working/.**
</step>

<step name="step3_analyze">
## Step 3: Analyze — Needs Research?

**Research triggers:** stripe, twilio, firebase, aws, oauth, jwt, websocket, graphql, payment, real-time
**Skip research for:** Bug fixes, UI changes, config changes, simple CRUD

Append `## Analysis` section to request file.
</step>

<step name="step4_research">
## Step 4: Research (If Needed)

If `needs_research: true`: Create `pp/research/REQ-XXX-RESEARCH.md`
If `needs_research: false`: Skip to Step 5.
</step>

<step name="step5_explore">
## Step 5: Explore Codebase

Spawn **Explore agent** to find relevant files, patterns, types, testing patterns.
Append `## Exploration` section to request file.
</step>

<step name="step6_load_plan">
## Step 6: Load Plan from Capture Phase

Plans are created during `/pp:add`. Load the existing plan:

```bash
cat pp/plans/REQ-XXX-plan.md
```

Append plan summary to request file.

**If plan file missing (old REQ without plan):** Enter plan mode now, create the plan file.
</step>

<step name="step7_implement">
## Step 7: Implement

Spawn **general-purpose agent** with: request content, research context, codebase context, and plan.
Append `## Implementation Summary` to request file.
Update STATE.md: `Step: implemented`
</step>

<step name="step8_generate_tests">
## Step 8: Generate Playwright Tests (Functionality + UI Screenshots)

**SKIP if Playwright testing disabled.**
**DO NOT SKIP if Playwright testing enabled.**

```bash
mkdir -p tests/pp tests/pp/screenshots
```

**YOU MUST create the test file yourself with BOTH:**
1. **Functionality tests** — one per "Done When" criterion + edge cases (empty input, invalid input, error states)
2. **UI screenshot tests** — full page, feature element, hover states, mobile (375px), tablet (768px)

**EVERY test takes at least one screenshot** saved to `tests/pp/screenshots/REQ-XXX/`
</step>

<step name="step9_test_loop">
## Step 9: Run Test Loop — ZERO TOLERANCE

**SKIP if Playwright testing disabled.**

**ZERO TOLERANCE on code errors. Infrastructure errors can be skipped.**

```
test_attempts = {}
max_attempts = 10

WHILE non-passed tests remain:
  1. Run: npx playwright test tests/pp/REQ-XXX-*.spec.js --reporter=list
  2. IF all pass → Proceed to Step 9b (screenshot review)
  3. FOR each failed test:
     - Infrastructure error (403, 401, CORS, connection refused, SSL)
       → SKIP immediately (server-side issue, can't fix with code)
       → Report in VERIFICATION.md
     - Playwright crash (browser closed, target closed)
       → Fix test setup, retry (count as attempt)
     - Code error (500, assertion failed, element not found)
       → MUST FIX, increment attempt counter
       → If attempts >= 10 → SKIP, report as "needs manual investigation"
       → If stuck after 5 attempts → try completely different approach
  4. RERUN all non-skipped tests
```

Update STATE.md after each iteration.
</step>

<step name="step9b_screenshot_review">
## Step 9b: Screenshot Review — ZERO TOLERANCE UI CHECK

**After all functionality tests pass, review EVERY screenshot for UI issues.**

1. **Read each screenshot** using the Read tool (which can read images)
2. **Check for:** alignment issues, spacing problems, overflow, text cut-off, font sizes, color consistency, responsive layout, hover states, touch target sizes
3. **If ANY UI issue found (no matter how small):**
   - Fix the code (CSS, HTML, JS)
   - Re-run affected tests to regenerate screenshots
   - Re-review new screenshots
   - Repeat until PERFECT

**DO NOT proceed to Step 10 until ALL screenshots are clean.**
</step>

<step name="step10_verification">
## Step 10: Verification Report

**SKIP if Playwright testing disabled.**

Create `pp/working/REQ-XXX-VERIFICATION.md` with:
- Functionality test results
- UI screenshot review results
- Issues found and fixed
- Summary of passes, skips, fixes
</step>

<step name="step11_archive">
## Step 11: Archive

**YOU MUST do this:**

Update frontmatter: `status: completed`

```bash
mkdir -p pp/archive
mv pp/working/REQ-XXX*.md pp/archive/
```

Update STATE.md: `Status: idle`
</step>

<step name="step12_commit">
## Step 12: Commit (If Enabled)

**Only if auto-commit = Yes:**

```bash
git add -A
git commit -m "[REQ-XXX] Title

- [implementation summary]
- Tests: X/Y passed, Z UI issues fixed

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
## Orchestrator Checklist — VERIFY EACH STEP

```
□ Pre-flight: mkdir -p pp/{config,research,working,archive,rephrased,plans} tests/pp tests/pp/screenshots
□ Pre-flight: Check test-env.json (if Playwright enabled)
□ Step 1: ls pp/REQ-*.md, pick first one
□ Step 2: mv pp/REQ-XXX.md pp/working/
□ Step 2: Update frontmatter: status: claimed
□ Step 3: Analyze for research, append ## Analysis
□ Step 4: (if needed) Create RESEARCH.md
□ Step 5: Spawn Explore, append ## Exploration
□ Step 6: Load plan from pp/plans/REQ-XXX-plan.md
□ Step 7: Spawn implementation agent with plan, append ## Implementation Summary
□ Step 8: (if Playwright) Create tests/pp/REQ-XXX.spec.js with functionality + UI tests
□ Step 9: (if Playwright) Run test loop — ZERO TOLERANCE until ALL pass
□ Step 9b: (if Playwright) Read EVERY screenshot, fix ALL UI issues, loop until clean
□ Step 10: (if Playwright) Create VERIFICATION.md with functionality + UI results
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
  Claiming...              [done] → moved to working/
  Analyzing...             [done] → no research needed
  Exploring...             [done] → found patterns
  Loading plan...          [done] → pp/plans/REQ-013-plan.md
  Implementing...          [done] → 2 files changed
  Generating tests...      [done] → 6 functionality + 5 UI tests
  Running functionality...
    ✓ func: logout button exists (1/1)
    ✓ func: logout redirects (2/2) — fixed: path
    ✓ func: session cleared (1/1)
  Screenshot review...
    ✓ ui-initial-fullpage.png — clean
    ✓ ui-feature-element.png — fixed: padding
    ✓ ui-mobile.png — clean
  Verification...          [done]
  Archiving...             [done]
  Committing...            [done] → abc1234

All tests passed. 1 UI issue found and fixed.
Queue empty. Done!
```
</progress_reporting>
