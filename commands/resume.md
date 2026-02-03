---
name: pp:resume
description: Continue work from where you left off after context reset
---

<objective>
Resume power-pack work from the last saved position in STATE.md. Restores full context including current task, test attempts, skipped tests, and decisions made.
</objective>

<process>

<step name="check_state">
Check if `pp/STATE.md` exists:

```bash
cat pp/STATE.md 2>/dev/null || echo "NO_STATE"
```

If no STATE.md exists:
```
No saved state found.

Run /pp:status to see the queue, or /pp:work to start processing.
```
Exit.
</step>

<step name="parse_state">
Read STATE.md and extract:
- Current status (idle/working/paused)
- Working on (REQ file)
- Current step (claim/research/implement/test/archive)
- Test attempt counters
- Skipped tests list
- Last error context
- Decisions made
</step>

<step name="resume_idle">
If status is `idle`:
```
State shows idle - no work in progress.

Queue: [N] pending tasks

Run /pp:work to start processing.
```
</step>

<step name="resume_working">
If status is `working`:

1. Display resume context:
```
Resuming [REQ-XXX-slug]...

Last state:
  Step: [step name]
  Progress: [details from STATE.md]
  Last error: [if any]

Continuing from [step]...
```

2. Resume from the saved step:

| Saved Step | Resume Action |
|------------|---------------|
| `claim` | Re-verify claim, continue to research/implement |
| `research` | Check if RESEARCH.md exists, continue or redo |
| `implement` | Check implementation status, continue or redo |
| `test` | Resume test loop from saved attempt count |
| `archive` | Complete archival |

3. Continue with the work flow as defined in /pp:work
</step>

<step name="restore_context">
Restore session context:
- Load session mode (Normal/Overnight)
- Load auto-commit setting
- Load Playwright testing setting
- Load test attempt counters
- Load skipped tests list
- Load decisions made during the session
</step>

</process>

<output_format>
```
Resuming [REQ-XXX-slug]...

Last state:
  Step: Testing
  Progress: 3/5 passed, attempt 4/10 on "reconnection"
  Last error: Token refresh failing

Continuing test loop...

  [test results as they run]

Result: 5/5 passed
Archiving... [done]
Committing... [done] -> [hash]

Queue: [N] remaining
Continue? (yes/no)
```
</output_format>
