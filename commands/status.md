---
name: pp:status
description: Show current state, queue, and recent completions
---

<objective>
Display the current power-pack status including queue count, current task, progress, and recent completions.
</objective>

<enforcement>
## SESSION SETUP CHECK

**If this is the FIRST /pp command in a new session, you MUST ask the 4 session setup questions BEFORE showing status.**
**NEVER skip session setup. NEVER assume answers from MEMORY.md or saved files.**

See /pp:add session_setup section for the 4 questions.
</enforcement>

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
pp Status (v2.0)

No state file found. No pending tasks.

To capture a task: /pp:add <description>
```

**If STATE.md doesn't exist but requests exist:**

```
pp Status (v2.0)

No state file found. Queue status:

Pending: [N] tasks
  - REQ-001: [title from file]
  - REQ-002: [title from file]

Run /pp:work to start processing.
```

**If STATE.md exists and idle:**

```
pp Status (v2.0)

Status: Idle
Session Mode: [Normal/Overnight]
Auto-commit: [Yes/No]
Playwright: [Yes/No]
Plan Review: [Verify/Direct]

Queue: [N] pending tasks
  1. REQ-XXX: [title]
  2. REQ-XXX: [title]

Recent Completions:
  - REQ-XXX: [title] -> [commit hash]

Run /pp:work to start processing.
```

**If STATE.md exists and working:**

```
pp Status (v2.0)

Status: Working (paused)
Session Mode: [Normal/Overnight]

Current: REQ-XXX-[slug]
Step: [claim|research|implement|test|screenshot-review|archive]
Last activity: [timestamp]

[If testing:]
Func Tests: [X]/[Y] passed
UI Screenshots: [X]/[Y] reviewed
UI Issues: [N] found, [M] fixed
Current: [test name or screenshot]
Attempt: [N]

Queue: [N] remaining tasks

Run /pp:resume to continue.
```

</step>

</process>
