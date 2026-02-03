# Work Action

> **Part of the power-pack skill.** Processes pending requests with auto-research, implementation, and automated Playwright testing with fix loops.

## Overview

For each task in the queue:
1. **Analyze** — Does this need research? (auto-detect)
2. **Research** — If needed, gather best practices
3. **Explore** — Find existing patterns in codebase (Explore agent)
4. **Plan** — For complex tasks, create detailed plan (Plan agent)
5. **Implement** — Build the feature (general-purpose agent)
6. **Generate Tests** — Create Playwright scripts based on "Done When"
7. **Test Loop** — Run tests, fix failures, rerun until pass
8. **Archive** — When tests pass (or skip problematic tests)

**Agents used:**
- **Explore agent** — Finds existing patterns, file locations
- **Plan agent** — Creates step-by-step implementation plan (complex tasks)
- **general-purpose agent** — Implements the feature

## Test Environment

Before processing, verify test config exists:

```bash
cat pp/config/test-env.json 2>/dev/null
```

If missing, stop and ask user to run capture first to set up test environment.

**Config structure:**
```json
{
  "loginUrl": "https://example.com/login",
  "username": "test_user",
  "password": "***",
  "baseUrl": "https://example.com",
  "envFile": "/path/to/.env",
  "createdAt": "2026-02-03T10:00:00Z"
}
```

## Workflow

### Step 1: Find Next Request

List `REQ-*.md` files in `pp/` folder, pick the first one (sorted by number).

If no requests found, report queue empty and exit.

### Step 2: Claim the Request

1. Create `pp/working/` if it doesn't exist
2. Move request file to `pp/working/`
3. Update frontmatter:

```yaml
---
status: claimed
claimed_at: 2026-02-03T10:30:00Z
---
```

### Step 3: Analyze — Needs Research?

Read the task content and auto-detect if research is needed.

**Research triggers (if ANY match → research):**

| Pattern | Keywords/Signals |
|---------|------------------|
| External API | `integrate`, `API`, `stripe`, `twilio`, `firebase`, `aws`, `sendgrid`, `slack`, `github api` |
| Protocols | `oauth`, `jwt`, `websocket`, `sse`, `graphql`, `grpc`, `mqtt` |
| Real-time | `real-time`, `live`, `realtime`, `push notification`, `sync` |
| Payments | `payment`, `checkout`, `billing`, `subscription`, `charge` |
| Security | `encrypt`, `hash`, `secure`, `authentication` (when new system, not fixing) |
| Caching | `cache`, `redis`, `memcached`, `caching layer` |
| Queues | `queue`, `job`, `worker`, `background task`, `async processing` |
| New SDK | `sdk`, `library` + unfamiliar name |

**Skip research (just explore codebase):**

| Pattern | Keywords/Signals |
|---------|------------------|
| Bug fixes | `fix`, `bug`, `error`, `broken`, `crash`, `issue`, `not working` |
| UI changes | `button`, `field`, `form`, `modal`, `style`, `css`, `layout`, `color` |
| Simple CRUD | `add endpoint`, `create api`, `delete`, `update` (basic operations) |
| Config | `config`, `setting`, `timeout`, `env`, `variable` |
| Refactor | `rename`, `refactor`, `move`, `reorganize`, `clean up` |
| Text changes | `text`, `copy`, `label`, `message`, `title` |

**Detection logic:**

```python
def needs_research(task_content):
    content_lower = task_content.lower()

    # Skip patterns (check first)
    skip_patterns = [
        'fix', 'bug', 'error', 'broken', 'crash',
        'button', 'style', 'css', 'color', 'layout',
        'rename', 'refactor', 'move', 'clean',
        'config', 'setting', 'timeout'
    ]
    if any(pattern in content_lower for pattern in skip_patterns):
        return False

    # Research patterns
    research_patterns = [
        'integrate', 'oauth', 'jwt', 'websocket', 'graphql',
        'real-time', 'realtime', 'live update',
        'payment', 'stripe', 'checkout', 'billing',
        'encrypt', 'firebase', 'aws', 'twilio',
        'redis', 'cache', 'queue', 'worker'
    ]
    if any(pattern in content_lower for pattern in research_patterns):
        return True

    return False
```

**Update frontmatter with decision:**

```yaml
---
status: claimed
claimed_at: 2026-02-03T10:30:00Z
needs_research: true  # or false
---
```

### Step 4: Research (If Needed)

**If `needs_research: false`:** Skip to Step 5 (Implement).

**If `needs_research: true`:**

1. **Identify research topic:**
   - Extract the core technology/integration from task
   - e.g., "add WebSocket notifications" → research topic: "WebSocket real-time notifications"

2. **Run research:**

   Use Context7 and web sources to gather:
   - Recommended libraries/versions
   - Implementation patterns
   - Common pitfalls
   - Code examples

   ```
   # Context7 for library docs
   mcp__context7__resolve-library-id with libraryName: "[library]"
   mcp__context7__get-library-docs with topic: "[specific pattern]"

   # Web for best practices
   WebSearch for "[technology] best practices 2026"
   WebSearch for "[technology] common mistakes"
   ```

3. **Create research file:**

   Location: `pp/research/REQ-XXX-RESEARCH.md`

   ```markdown
   # Research: REQ-XXX [Task Title]

   **Generated:** 2026-02-03
   **Topic:** [Core technology/integration]

   ## Recommended Stack

   | Component | Choice | Version | Reason |
   |-----------|--------|---------|--------|
   | [Component] | [Library] | [Version] | [Why] |

   ## Implementation Patterns

   ### [Pattern 1 Name]
   [Description and when to use]

   ```[language]
   [Code example]
   ```

   ### [Pattern 2 Name]
   [Description and when to use]

   ```[language]
   [Code example]
   ```

   ## Common Pitfalls

   | Pitfall | Prevention |
   |---------|------------|
   | [Issue 1] | [How to avoid] |
   | [Issue 2] | [How to avoid] |

   ## Security Considerations

   - [Security point 1]
   - [Security point 2]

   ## References

   - [Source 1]
   - [Source 2]

   ---
   *Auto-generated research for power-pack*
   ```

4. **Update frontmatter:**

   ```yaml
   ---
   status: researched
   research_file: pp/research/REQ-XXX-RESEARCH.md
   ---
   ```

5. **Report research summary:**

   ```
   Researching: WebSocket notification system...

   ◆ Checking Context7 for Socket.io docs...
   ◆ Fetching best practices...
   ◆ Identifying pitfalls...

   Created: pp/research/REQ-015-RESEARCH.md

   Key findings:
   - Library: Socket.io v4.7 (browser fallbacks)
   - Pattern: Heartbeat + exponential backoff
   - Pitfall: Auth token refresh on reconnect

   Proceeding to implementation...
   ```

### Step 5: Explore Codebase

Before implementing, explore the existing codebase to find patterns and relevant files.

**Skip exploration if:**
- Task is a simple bug fix with clear file mentioned
- Task is config/value change
- Already know exactly what to modify

**Run exploration for:**
- New features
- Tasks that need to follow existing patterns
- When location is unclear

Spawn an **Explore agent**:

```
Task(prompt="
For this request:

## Request
[Full content of request file]

## Research (if exists)
[Summary from RESEARCH.md]

Find the relevant files and patterns needed to implement this:
1. Where should this change be made?
2. What existing patterns should we follow?
3. Related types/interfaces to use
4. Testing patterns if applicable

Return a summary with specific file paths and code patterns to follow.
", subagent_type="Explore")
```

**After Explore agent returns:**
- Store exploration output for implementation
- Note: If exploration finds the task is more complex than expected, may need to spawn Plan agent

### Step 6: Plan (Complex Tasks Only)

For complex tasks (multi-file, architectural), create a detailed plan.

**Triggers for planning:**
- Exploration found 5+ files to modify
- New architectural pattern needed
- Multiple components involved
- Research recommended specific implementation order

Spawn a **Plan agent**:

```
Task(prompt="
Create an implementation plan for this request:

## Request
[Full content of request file]

## Research Context (if exists)
[From RESEARCH.md]

## Codebase Context
[From Explore agent]

Create a detailed plan including:
1. Files to create/modify (in order)
2. Key changes in each file
3. Dependencies between changes
4. Testing approach

Be specific about file paths and function names.
", subagent_type="Plan")
```

**After Plan agent returns:**
- Store plan for implementation
- Implementation will follow the plan step by step

### Step 7: Implement the Feature

Spawn a **general-purpose agent** with all available context.

**With research + exploration + plan (full context):**

```
Task(prompt="
Implement this feature:

## Request
[Full content of request file]

## Research Context
[From RESEARCH.md - recommended stack, patterns, pitfalls]

## Codebase Context
[From Explore agent - existing patterns, file locations]

## Implementation Plan
[From Plan agent - step by step approach]

## Instructions
- Follow the implementation plan
- Use patterns from codebase context
- Apply recommendations from research
- Avoid pitfalls identified in research
- Focus on the 'Done When' criteria

When complete, provide a summary of what files were changed.
", subagent_type="general-purpose")
```

**With exploration only (medium complexity):**

```
Task(prompt="
Implement this feature:

## Request
[Full content of request file]

## Codebase Context
[From Explore agent]

## Instructions
- Follow existing patterns from codebase context
- Focus on the 'Done When' criteria
- Make minimal, focused changes

When complete, provide a summary of what files were changed.
", subagent_type="general-purpose")
```

**Simple task (no exploration/research):**

```
Task(prompt="
Implement this feature:

## Request
[Full content of request file]

## Instructions
- Implement the feature as described
- Focus on the 'Done When' criteria
- Make minimal, focused changes

When complete, provide a summary of what files were changed.
", subagent_type="general-purpose")
```

Capture the implementation summary.

### Step 8: Generate Playwright Tests

Based on the "Done When" criteria in the REQ file, generate Playwright test scripts.

**Read test config:**
```bash
TEST_CONFIG=$(cat pp/config/test-env.json)
```

**Read REQ file for test criteria:**
- `test_url` from frontmatter
- "Done When" section for assertions
- Feature description for test context

**Create test file:**

Location: `tests/pp/REQ-XXX-slug.spec.js`

```javascript
// tests/pp/REQ-013-logout-button.spec.js
const { test, expect } = require('@playwright/test');

const config = {
  loginUrl: '[from test-env.json]',
  username: '[from test-env.json]',
  password: '[from test-env.json]',
  baseUrl: '[from test-env.json]',
  testUrl: '[from REQ frontmatter]'
};

test.describe('REQ-013: [Title from REQ]', () => {

  test.beforeEach(async ({ page }) => {
    // Login
    await page.goto(config.loginUrl);
    await page.fill('[name="username"], [name="email"], #username, #email', config.username);
    await page.fill('[name="password"], #password', config.password);
    await page.click('button[type="submit"], input[type="submit"]');
    await page.waitForURL(url => !url.includes('login'));

    // Navigate to test URL
    await page.goto(config.testUrl);
  });

  // Generate one test per "Done When" criterion
  test('[criterion 1 from Done When]', async ({ page }) => {
    // Test assertion based on criterion
  });

  test('[criterion 2 from Done When]', async ({ page }) => {
    // Test assertion based on criterion
  });

});
```

**Test generation guidelines:**

| Done When Criterion | Playwright Test |
|---------------------|-----------------|
| "Button exists in header" | `await expect(page.locator('header button')).toBeVisible()` |
| "Clicking X redirects to /Y" | `await page.click('X'); await expect(page).toHaveURL(/Y/)` |
| "Form shows error for invalid input" | `await page.fill(...); await expect(page.locator('.error')).toBeVisible()` |
| "Page loads in under 2 seconds" | `const start = Date.now(); await page.goto(...); expect(Date.now() - start).toBeLessThan(2000)` |
| "Data is saved" | `await page.fill(...); await page.click('save'); await page.reload(); await expect(page.locator('...')).toHaveText(...)` |

### Step 9: Run Test Loop

```
TEST LOOP
┌──────────────────────────────────────────────────┐
│  Run: npx playwright test tests/pp/REQ-XXX-*.spec.js
│       │                                           │
│  All tests pass? ──Yes──► EXIT LOOP (success)    │
│       │                                           │
│      No                                           │
│       │                                           │
│  For each failed test:                           │
│       │                                           │
│  Classify failure type                           │
│       │                                           │
│  ┌─ Infrastructure issue? ──────────────────┐    │
│  │  (403, 401, connection refused, CORS,    │    │
│  │   SSL, DNS, Playwright crash)            │    │
│  │       │                                  │    │
│  │      Yes ──► Mark SKIPPED (infra)       │    │
│  │             Continue to next test        │    │
│  └──────────────────────────────────────────┘    │
│       │                                           │
│      No (code issue: 500, assertion, exception)  │
│       │                                           │
│  Same test failed >10 times?                     │
│       │                                           │
│      Yes ──► Mark SKIPPED (max attempts)         │
│              Continue to next test               │
│       │                                           │
│      No                                           │
│       │                                           │
│  Analyze failure, fix code                       │
│       │                                           │
│  Increment attempt counter for this test         │
│       │                                           │
│  Rerun all non-skipped tests ◄───────────────────┘
└──────────────────────────────────────────────────┘
```

**Failure classification:**

| Error Pattern | Type | Action |
|---------------|------|--------|
| `net::ERR_CONNECTION_REFUSED` | infra | skip |
| `403 Forbidden` | infra | skip |
| `401 Unauthorized` | infra | skip |
| `CORS policy` | infra | skip |
| `SSL_ERROR` / `CERT_` | infra | skip |
| `DNS_PROBE_FINISHED` | infra | skip |
| `browser has been closed` | playwright | skip |
| `Target closed` | playwright | skip |
| `500 Internal Server Error` | code | try fix |
| `502 Bad Gateway` | code | try fix |
| `503 Service Unavailable` | code | try fix |
| `expect(...).toBe` failed | code | try fix |
| `Element not found` | code | try fix |
| `Timeout waiting for` | code | try fix (might be infra after 10) |

**Fixing code issues:**

When a test fails due to code:
1. Read the error message and stack trace
2. Identify the likely cause
3. Fix the code (edit the relevant file)
4. Rerun the test

Use the error context to guide fixes:
- Assertion failed → Check the implementation logic
- Element not found → Check selectors, element existence
- 500 error → Check server-side code, add error handling
- Timeout → Check async operations, loading states

**Tracking attempts:**

Maintain a counter per test:
```
{
  "logout button exists": { attempts: 3, status: "passing" },
  "logout redirects": { attempts: 7, status: "failing" },
  "session cleared": { attempts: 10, status: "skipped", reason: "max_attempts" }
}
```

### Step 10: Generate Verification Report

After test loop completes, create `pp/working/REQ-XXX-VERIFICATION.md`:

```markdown
# Test Report: REQ-XXX [Title]

**Status:** [PASS | PARTIAL PASS | FAIL]
**Date:** 2026-02-03
**Test File:** tests/pp/REQ-XXX-slug.spec.js

## Results

| Test | Status | Attempts | Notes |
|------|--------|----------|-------|
| logout button exists | ✓ PASS | 1 | |
| logout redirects to /login | ✓ PASS | 3 | Fixed redirect path |
| session is cleared | ⚠ SKIPPED | 10 | Auto-skipped: Failed 10 times |
| admin access | ⚠ SKIPPED | 1 | Auto-skipped: 403 Forbidden (infra) |

## Skipped Tests

### session is cleared
- **Reason:** Failed 10 consecutive times
- **Last error:** `Expected URL to match /login, got /dashboard`
- **Recommendation:** Manual investigation needed

### admin access
- **Reason:** Infrastructure/permission issue
- **Error:** `403 Forbidden`
- **Why skipped:** Cannot fix with code — server permission config needed
- **Recommendation:** Check server permissions for test user

## Auto-Fixed During Testing

| Test | Error | Fix Applied | Attempt |
|------|-------|-------------|---------|
| logout redirects | Wrong redirect path | Changed `/home` to `/login` in logout.php | 2 |
| logout redirects | Missing await | Added async handling | 3 |

## Summary

- **Passed:** 2/4 tests
- **Skipped:** 2/4 tests
  - 1 max attempts exceeded
  - 1 infrastructure issue
- **Auto-fixed:** 2 issues during test loop

---
*Generated by power-pack automated testing*
```

### Step 11: Archive

1. Update REQ frontmatter:
```yaml
---
status: completed
completed_at: 2026-02-03T11:00:00Z
tests_passed: 2
tests_skipped: 2
tests_total: 4
---
```

2. Move files to archive:
```bash
mkdir -p pp/archive
mv pp/working/REQ-XXX-*.md pp/archive/
```

3. Handle UR folder archival (same as do-work):
   - If all REQs for a UR are complete → move UR folder to archive

### Step 12: Commit (If Enabled)

**Check session preference:** Only commit if user selected "Yes" to auto-commit at session start.

**If auto-commit is DISABLED:**
```
Skipping commit (auto-commit disabled for this session).
Changes are staged but not committed. Run `git commit` when ready.
```

**If auto-commit is ENABLED:**

Create git commit with all changes:

```bash
git add -A
git commit -m "$(cat <<'EOF'
[REQ-XXX] Title

Implements: pp/archive/REQ-XXX-slug.md
Tests: tests/pp/REQ-XXX-slug.spec.js

- [implementation summary]
- Tests: X/Y passed, Z skipped

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

### Step 13: Loop or Exit

Re-check `pp/` for pending REQ files:
- If found: continue to next request
- If empty: report summary and exit

## Progress Reporting

Keep user informed:

**With auto-commit enabled:**
```
Processing REQ-013-logout-button.md...
  Implementing...        [done]
  Generating tests...    [done] → 4 test cases
  Running tests...
    ✓ logout button exists (1/1)
    ✓ logout redirects (3/3) — fixed: redirect path, async
    ⚠ session cleared (10/10) — SKIPPED: max attempts
    ⚠ admin access (1/1) — SKIPPED: 403 Forbidden

  Result: 2/4 passed, 2 skipped, 2 auto-fixed
  Archiving...           [done]
  Committing...          [done] → abc1234

⚠ 2 tests skipped. See VERIFICATION.md for details.

Checking for more requests...
Queue empty. All done!

Summary:
  - REQ-013: 2/4 tests passed, 2 skipped → abc1234
```

**With auto-commit disabled:**
```
Processing REQ-013-logout-button.md...
  Implementing...        [done]
  Generating tests...    [done] → 4 test cases
  Running tests...
    ✓ logout button exists (1/1)
    ✓ logout redirects (3/3) — fixed: redirect path, async
    ⚠ session cleared (10/10) — SKIPPED: max attempts
    ⚠ admin access (1/1) — SKIPPED: 403 Forbidden

  Result: 2/4 passed, 2 skipped, 2 auto-fixed
  Archiving...           [done]
  Committing...          [skipped] (auto-commit disabled)

⚠ 2 tests skipped. See VERIFICATION.md for details.

Checking for more requests...
Queue empty. All done!

Summary:
  - REQ-013: 2/4 tests passed, 2 skipped (not committed)

💡 Changes are ready. Run `git add . && git commit` when ready to commit.
```

## Error Handling

### Implementation fails
- Mark REQ as `failed`
- Move to archive with error
- Continue to next request

### All tests skipped
- Mark REQ as `completed` with warning
- Note in VERIFICATION.md: "All tests skipped — manual verification recommended"

### Playwright not installed
```
Playwright not found. Installing...
npm init playwright@latest --yes
```

### Test file syntax error
- Fix the generated test file
- Rerun

## Test Script Template

Full template for generated tests:

```javascript
// tests/pp/REQ-{id}-{slug}.spec.js
const { test, expect } = require('@playwright/test');

// Test configuration
const config = {
  loginUrl: '{loginUrl}',
  username: '{username}',
  password: '{password}',
  baseUrl: '{baseUrl}',
  testUrl: '{testUrl}'
};

test.describe('REQ-{id}: {title}', () => {

  // Setup: Login before each test
  test.beforeEach(async ({ page }) => {
    // Navigate to login
    await page.goto(config.loginUrl);

    // Fill credentials (try multiple selectors for compatibility)
    const usernameSelectors = '[name="username"], [name="email"], #username, #email, input[type="email"]';
    const passwordSelectors = '[name="password"], #password, input[type="password"]';

    await page.locator(usernameSelectors).first().fill(config.username);
    await page.locator(passwordSelectors).first().fill(config.password);

    // Submit
    await page.locator('button[type="submit"], input[type="submit"], .login-btn, #login-btn').first().click();

    // Wait for redirect away from login
    await page.waitForURL(url => !url.pathname.includes('login'), { timeout: 10000 });

    // Navigate to test URL
    await page.goto(config.testUrl);
    await page.waitForLoadState('networkidle');
  });

  /*
   * Generated tests based on "Done When" criteria:
   * {done_when_criteria}
   */

  test('{criterion_1}', async ({ page }) => {
    {test_code_1}
  });

  test('{criterion_2}', async ({ page }) => {
    {test_code_2}
  });

  // ... more tests

});
```

## Skipped Test Documentation

When a test is skipped, the VERIFICATION.md includes:

**For max attempts (10 failures):**
```markdown
### {test_name}
- **Reason:** Failed 10 consecutive times
- **Skip type:** `max_attempts`
- **Last error:** `{error_message}`
- **Fix attempts made:**
  1. {fix_1} — still failed
  2. {fix_2} — still failed
  ...
- **Recommendation:** Manual investigation needed — {brief analysis}
```

**For infrastructure issues:**
```markdown
### {test_name}
- **Reason:** Infrastructure/permission issue
- **Skip type:** `infra_{subtype}`
- **Error:** `{error_message}`
- **Why skipped:** Cannot fix with code — {explanation}
- **Recommendation:** {what to check/fix on server side}
```

**Skip subtypes:**
- `infra_permission` — 403, 401
- `infra_connection` — Connection refused, DNS failed
- `infra_security` — CORS, SSL/TLS errors
- `infra_playwright` — Browser crash, Playwright limitation

## State Management

Update `pp/STATE.md` at each step transition for resume capability.

### When to Update State

| Event | Update |
|-------|--------|
| Claim task | `status: working`, `step: claim`, task details |
| Start research | `step: research` |
| Research done | `step: implement`, research file |
| Implementation done | `step: test` |
| Each test attempt | `step_detail` with attempt #, error |
| Test skipped | Add to skipped list |
| Test passed | Update counts |
| Task complete | `status: idle`, add to completions |

### State File Updates

**On claim (Step 2):**
```markdown
## Current Position

**Status:** working
**Queue:** [N] pending
**Working on:** REQ-XXX-slug
**Step:** claim
**Last activity:** [timestamp]

## In Progress

| Field | Value |
|-------|-------|
| REQ | REQ-XXX-slug |
| Step | claim |
| Started | [timestamp] |
```

**On test loop (Step 7):**
```markdown
## In Progress

| Field | Value |
|-------|-------|
| REQ | REQ-XXX-slug |
| Step | testing |
| Test file | tests/pp/REQ-XXX.spec.js |
| Tests total | 5 |
| Tests passed | 3 |
| Tests skipped | 1 |
| Current test | reconnection handling |
| Attempt | 4/10 |
| Last error | Token refresh failing |
```

**On completion (Step 9):**
```markdown
## Current Position

**Status:** idle
**Queue:** [N-1] pending
**Working on:** None
**Last activity:** [timestamp]

## Recent Completions

| REQ | Title | Tests | Result | Commit | Date |
|-----|-------|-------|--------|--------|------|
| REQ-XXX | [title] | 4/5 | ⚠ Partial | abc123 | [date] |
| ... previous ... |
```

### Reading State for Resume

When `/pp resume` is called:

1. Read `pp/STATE.md`
2. Parse "In Progress" section
3. Restore:
   - Current REQ file path
   - Current step
   - Test attempt counters
   - Skipped tests list
   - Last error context
4. Continue from saved step

See [status action](./status.md) for full resume logic.

## Checkpoints (Session Mode Dependent)

Checkpoints pause execution to get user confirmation. Behavior depends on session mode.

### Session Mode

At first `/pp status` command in a session, user selects:
- **Normal** — Pause at checkpoints
- **Overnight** — Auto-select, no pauses

Mode is stored in memory for the session (not persisted).

### Checkpoint Triggers

| Trigger | Example | When to Checkpoint |
|---------|---------|-------------------|
| Multiple approaches | Socket.io vs Native WS | Research found alternatives |
| Destructive action | Delete files, drop table | Irreversible changes |
| External side effect | Push to remote, send email | Leaves the local system |
| Research conflict | Docs say X, code uses Y | Unclear which to follow |
| Large scope | 10+ files affected | Big blast radius |
| Security sensitive | Auth, encryption, tokens | Needs careful review |

### Normal Mode — Checkpoint Flow

```
Implementing REQ-015...
  Created WebSocket handler...

  ╔══════════════════════════════════════════════════════════════╗
  ║  CHECKPOINT: Architecture Decision                           ║
  ╚══════════════════════════════════════════════════════════════╝

  Research found 2 valid approaches:

  A) Socket.io (recommended)
     - Auto-reconnect, fallbacks, larger ecosystem
     - Bundle: +45KB

  B) Native WebSocket
     - Smaller bundle, manual reconnect logic
     - Bundle: +2KB

  Research recommends: A (Socket.io)

  ──────────────────────────────────────────────────────────────
  → Select approach: A / B
  ──────────────────────────────────────────────────────────────

User: A

  ✓ Decision: Socket.io
  Continuing implementation...
```

### Overnight Mode — Auto-Select

```
Implementing REQ-015...
  Created WebSocket handler...

  Decision: Socket.io vs Native WebSocket
  ⚡ Auto-selected: Socket.io (research recommended)

  Continuing implementation...
```

### Logging Decisions

All checkpoint decisions (user or auto) are logged to STATE.md:

```markdown
## Decisions Made This Session

| Time | REQ | Decision | Choice | Mode |
|------|-----|----------|--------|------|
| 14:30 | REQ-015 | WebSocket library | Socket.io | Auto (overnight) |
| 14:45 | REQ-015 | Auth refresh | On reconnect | Auto (overnight) |
| 15:00 | REQ-016 | Delete old files | Confirmed | User (normal) |
```

### Checkpoint Types

**Decision checkpoint:**
```
╔══════════════════════════════════════════════════════════════╗
║  CHECKPOINT: [Decision Type]                                  ║
╚══════════════════════════════════════════════════════════════╝

[Context and options]

Recommended: [option]

→ Select: A / B / C
```

**Confirmation checkpoint:**
```
╔══════════════════════════════════════════════════════════════╗
║  CHECKPOINT: Confirm Action                                   ║
╚══════════════════════════════════════════════════════════════╝

About to: [destructive/external action]
Affects: [what will change]

→ Proceed? (yes/no)
```

**Review checkpoint:**
```
╔══════════════════════════════════════════════════════════════╗
║  CHECKPOINT: Review Required                                  ║
╚══════════════════════════════════════════════════════════════╝

[What needs review]

→ Type "approved" to continue, or describe issues
```

### Overnight Mode Defaults

When auto-selecting in overnight mode:

| Checkpoint Type | Auto-Select Rule |
|-----------------|------------------|
| Multiple approaches | Use research recommendation |
| Destructive action | Skip (don't auto-delete) |
| External side effect | Skip (don't auto-push) |
| Research conflict | Use research recommendation |
| Large scope | Proceed (already planned) |
| Security sensitive | Use research recommendation |

**Critical:** Destructive and external actions are SKIPPED in overnight mode, not auto-confirmed. They're logged as "Skipped (overnight mode)" and can be done manually later.
