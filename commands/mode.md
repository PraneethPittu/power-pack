---
name: pp:mode
description: Switch session mode (normal or overnight)
argument-hint: <normal|overnight>
---

<objective>
Switch the power-pack session mode between Normal and Overnight.
</objective>

<process>

<step name="parse">
Parse the argument to determine which mode to switch to.

- `/pp:mode normal` → Switch to Normal mode
- `/pp:mode overnight` → Switch to Overnight mode
- `/pp:mode` (no argument) → Show current mode and explain options
</step>

<step name="validate">
If no valid argument provided, show help:

```
Session Mode

Current mode: [read from pp/STATE.md or "Not set"]

Usage:
  /pp:mode normal     - Pause at decision points, ask for confirmation
  /pp:mode overnight  - Run autonomously, auto-select recommended options

Normal mode is best when you're actively working.
Overnight mode is best for large queues when you'll be away.
```
</step>

<step name="update">
If valid argument provided:

1. Read `pp/STATE.md` (create if doesn't exist)
2. Update the `**Session Mode:**` line to the new value
3. Confirm the change:

```
Session mode changed to [Normal/Overnight].

[If Normal]: Will pause at decision points and ask for confirmation.
[If Overnight]: Will run autonomously and auto-select recommended options.
```
</step>

</process>

<modes>

**Normal Mode:**
- Pauses at decision points
- Asks for confirmation on architectural choices
- Asks before destructive actions
- Best when you're actively working

**Overnight Mode:**
- Runs autonomously without pausing
- Auto-selects recommended options
- Skips destructive actions (won't auto-delete files)
- Logs all decisions to STATE.md
- Best for large queues when you'll be away

</modes>
