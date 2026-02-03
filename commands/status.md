---
name: pp:status
description: Show current state, queue, and recent completions
---

<objective>
Display the current power-pack status including queue count, current task, progress, and recent completions.
</objective>

<process>

<step name="check_state">
Check if `pp/STATE.md` exists:

```bash
cat pp/STATE.md 2>/dev/null || echo "NO_STATE"
```
</step>

<step name="check_queue">
Check for pending tasks:

```bash
ls pp/REQ-*.md 2>/dev/null || echo "NO_REQUESTS"
```
</step>

<step name="display">

**If STATE.md doesn't exist and no requests:**

```
pp Status

No state file found. No pending tasks.

To capture a task: /pp:add <description>
```

**If STATE.md doesn't exist but requests exist:**

```
pp Status

No state file found. Queue status:

Pending: [N] tasks
  - REQ-001: [title from file]
  - REQ-002: [title from file]

Run /pp:work to start processing.
```

**If STATE.md exists and idle:**

```
pp Status

Status: Idle
Session Mode: [Normal/Overnight]
Auto-commit: [Yes/No]
Playwright: [Yes/No]

Queue: [N] pending tasks
  1. REQ-XXX: [title]
  2. REQ-XXX: [title]

Recent Completions:
  - REQ-XXX: [title] -> [commit hash]

Run /pp:work to start processing.
```

**If STATE.md exists and working:**

```
pp Status

Status: Working (paused)
Session Mode: [Normal/Overnight]

Current: REQ-XXX-[slug]
Step: [claim|research|implement|test|archive]
Last activity: [timestamp]

[If testing:]
Tests: [X]/[Y] passed, [Z] skipped
Current test: [test name]
Attempt: [N]/10
Last error: [error message]

Queue: [N] remaining tasks

Run /pp:resume to continue.
```

**If blocked:**

```
pp Status

Status: Blocked
Current: REQ-XXX-[slug]
Blocker: [description of blocker]

Run /pp:resume to continue with remaining work.
```

</step>

</process>

<state_file_format>
The STATE.md file contains:
- Session Mode (Normal/Overnight)
- Auto-commit setting
- Playwright testing setting
- Current position (status, working on, step)
- Task queue
- Recent completions
- Decisions made
- Blockers
</state_file_format>
