# Status Action

> **Part of the power-pack skill.** Shows current state and enables resuming across sessions.

## Overview

The status action reads `pp/STATE.md` and displays:
- Current position (what task, which step)
- Recent completions
- Any blockers or failures
- Next recommended action

## Commands

| Command | Action |
|---------|--------|
| `/pp status` | Show status (default when no args) |
| `/pp status` | Show status explicitly |
| `/pp resume` | Continue from last position |

## STATE.md Location

```
pp/STATE.md
```

Created automatically when work starts. Updated at each step transition.

## STATE.md Format

```markdown
# power-pack State

**Last updated:** 2026-02-03T14:30:00Z

## Current Position

**Status:** [idle | working | paused]
**Queue:** [N] pending
**Working on:** [REQ-XXX-slug or "None"]
**Step:** [claim | research | implement | test | archive]
**Step detail:** [e.g., "Test attempt 4/10 on 'reconnection' test"]
**Last activity:** [timestamp]

## In Progress

| Field | Value |
|-------|-------|
| REQ | REQ-015-websocket-notifications |
| Step | testing |
| Test file | tests/pp/REQ-015-websocket.spec.js |
| Tests passed | 3/5 |
| Tests skipped | 0 |
| Current test | reconnection handling |
| Attempt | 4/10 |
| Last error | Token refresh failing on reconnect |

## Recent Completions

| REQ | Title | Tests | Result | Commit | Date |
|-----|-------|-------|--------|--------|------|
| REQ-014 | Add logout button | 4/4 | ✓ Pass | abc123 | 2026-02-03 |
| REQ-013 | Fix search bug | 3/3 | ✓ Pass | def456 | 2026-02-02 |
| REQ-012 | Dashboard speed | 2/4 | ⚠ Partial | ghi789 | 2026-02-01 |

## Pending Queue

| REQ | Title | Created |
|-----|-------|---------|
| REQ-016 | Add dark mode | 2026-02-03 |
| REQ-017 | Export to PDF | 2026-02-03 |

## Decisions Made This Session

- REQ-015: Using Socket.io v4.7 (from research)
- REQ-015: Heartbeat interval set to 25s
- REQ-014: Logout button placed in header right

## Blockers

- REQ-015: "reconnection" test failing after 4 attempts
  - Error: Token refresh not triggering on reconnect
  - Tried: Added refresh call in onDisconnect — still failing

## Test Environment

- Config: pp/config/test-env.json ✓
- Base URL: https://example.com
- Last verified: 2026-02-03

---
*State file for power-pack skill*
```

## Show Status

When user runs `/pp status` or `/pp status`:

**If STATE.md doesn't exist:**
```
power-pack Status

No state file found. Queue status:

Pending: [N] tasks
  - REQ-001: [title]
  - REQ-002: [title]

Run `/pp work` to start processing.
```

**If idle (nothing in progress):**
```
power-pack Status

Status: Idle
Queue: 3 pending tasks
Last completed: REQ-014 (Add logout button) → abc123

Pending:
  1. REQ-015: WebSocket notifications
  2. REQ-016: Add dark mode
  3. REQ-017: Export to PDF

Run `/pp work` to start processing.
```

**If work in progress:**
```
power-pack Status

Status: Working (paused)
Current: REQ-015-websocket-notifications
Step: Testing (attempt 4/10)
Last activity: 2026-02-03 14:30

Current test: "reconnection handling"
Last error: Token refresh failing on reconnect

Tests: 3/5 passed, 0 skipped, 2 remaining

Run `/pp resume` to continue.
```

**If blocked:**
```
power-pack Status

Status: Blocked
Current: REQ-015-websocket-notifications
Blocker: "reconnection" test failed 10 times — auto-skipped

Tests: 3/5 passed, 1 skipped, 1 remaining

Run `/pp resume` to continue with remaining tests.
```

## Resume Work

When user runs `/pp resume`:

1. **Read STATE.md**
2. **Check current position:**
   - If `status: idle` → Start normal work loop
   - If `status: working` → Resume from saved step

3. **Resume from step:**

| Saved Step | Resume Action |
|------------|---------------|
| `claim` | Re-claim and continue |
| `research` | Check if RESEARCH.md exists, continue or redo |
| `implement` | Check implementation status, continue or redo |
| `test` | Resume test loop from saved attempt count |
| `archive` | Complete archival |

4. **Restore context:**
   - Load test attempt counters
   - Load skipped tests list
   - Load last error for context

**Resume output:**
```
Resuming REQ-015-websocket-notifications...

Last state:
  Step: Testing
  Progress: 3/5 passed, attempt 4/10 on "reconnection"
  Last error: Token refresh failing

Continuing test loop...

  ✓ reconnection handling (6/10) — fixed: added token check
  ✓ offline queue (1/1)

Result: 5/5 passed
Archiving... [done]
Committing... [done] → xyz789

Queue: 2 remaining
Continue? (yes/no)
```

## State Updates

The work action updates STATE.md at these points:

| Event | State Update |
|-------|--------------|
| Claim task | `status: working`, `step: claim`, task details |
| Start research | `step: research` |
| Research complete | `step: implement`, research file path |
| Implementation complete | `step: test` |
| Each test attempt | `step_detail` with attempt count, last error |
| Test skip | Add to skipped tests list |
| Test pass | Update passed count |
| Archive | `status: idle`, move to recent completions |
| Error/pause | Save full state for resume |

**Update frequency:** After each significant step change, not after every micro-action.

## Clearing State

State auto-clears for completed tasks. To manually reset:

```bash
rm pp/STATE.md
```

Or through skill:
```
/pp clear-state
```

## Session Handoff

When session ends (context limit, user exits):

The state is already saved because we update after each step. User can:
1. Open new terminal
2. Run `/pp status` to see where they were
3. Run `/pp resume` to continue

No special "save" action needed — state is always current.
