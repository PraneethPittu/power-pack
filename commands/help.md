---
name: pp:help
description: Show help documentation for all power-pack commands
---

<objective>
Display comprehensive help documentation for all power-pack commands.
</objective>

<process>

Output the following help text:

```
POWER-PACK v2.0 HELP

A powerful task management skill combining do-work speed with GSD intelligence.

COMMANDS
--------
  /pp:help                     Show this help documentation
  /pp:add <description>        Capture a new task with smart questioning
  /pp:work                     Process all pending tasks in the queue
  /pp:resume                   Continue from where you left off
  /pp:status                   Show current state and queue
  /pp:mode <normal|overnight>  Switch session mode

COMMAND DETAILS
---------------

/pp:add <description>
  Captures a task with the full capture pipeline:
    1. Rephrases your prompt into an optimized detailed version (agent)
    2. Asks clarifying questions (ALWAYS — both Normal and Overnight modes)
    3. Enters plan mode to create implementation plan (EVERY task)
    4. Shows plan for review (based on session preference)
    5. Creates REQ file with rephrased prompt + plan references

  Examples:
    /pp:add add a logout button to the header
    /pp:add make the dashboard load faster
    /pp:add fix login bug with special characters

  Skip questions:
    /pp:add add dark mode, just capture it

/pp:work
  Processes all pending tasks. For each task:
    1. Claims task (moves to working/)
    2. Analyzes if research is needed (OAuth, WebSocket, Stripe, etc.)
    3. Researches best practices (if needed)
    4. Explores codebase for existing patterns
    5. Loads implementation plan (from capture phase)
    6. Implements the feature
    7. Generates Playwright tests — functionality + UI screenshots (if enabled)
    8. Runs tests with ZERO TOLERANCE (must reach 100% pass)
    9. Reviews ALL screenshots for UI issues (alignment, spacing, responsive)
   10. Loops UI fixes until every screenshot is perfect
   11. Archives and commits (if auto-commit enabled)

/pp:resume
  Continues work after terminal close or context reset.
  Restores: current task, test attempts, skipped tests, decisions made.

/pp:status
  Shows: queue count, current task, step progress, recent completions, blockers.

/pp:mode normal
  Pauses at decision points, asks for confirmation.
  Best when you're actively working.

/pp:mode overnight
  Runs autonomously, auto-selects recommended options.
  Skips destructive actions. Logs all decisions.
  Best for large queues when you'll be away.
  Note: Capture (/pp:add) ALWAYS asks questions regardless of mode.

SESSION SETUP (4 questions, asked every new session)
-----------------------------------------------------
  1. Session mode: Normal (with checkpoints) or Overnight (autonomous)
  2. Auto-commit: Yes (commit after each task) or No (manual commits)
  3. Playwright testing: Yes (zero-tolerance testing) or No (skip testing)
  4. Plan verification: Verify with me (review plan) or Continue directly

If Playwright testing is enabled, you'll also be asked for test credentials.

FOLDER STRUCTURE
----------------
  pp/
  ├── REQ-*.md              Pending tasks (queue)
  ├── STATE.md              Session state for resume
  ├── config/test-env.json  Test credentials (gitignored)
  ├── rephrased/            Optimized prompts (from capture)
  ├── plans/                Implementation plans (from capture)
  ├── research/             Auto-generated research docs
  ├── working/              Task currently being processed
  └── archive/              Completed tasks with verification

  tests/pp/                 Generated Playwright tests
  tests/pp/screenshots/     UI verification screenshots

KEY FEATURES (v2.0)
-------------------
  - Prompt rephrasing: Every task prompt is optimized by an agent
  - Mandatory planning: Every task enters plan mode during capture
  - Zero-tolerance testing: Functionality + UI screenshot verification
  - Screenshot review: Checks alignment, spacing, responsive, visual issues
  - Questions in both modes: Capture always asks questions (Normal + Overnight)

TIPS
----
  - Be specific when capturing tasks
  - Answer questions thoughtfully - they guide implementation
  - Use overnight mode for large queues
  - Check VERIFICATION.md for test results and UI fixes
  - If stuck, run: rm pp/STATE.md

TROUBLESHOOTING
---------------
  Playwright not found     -> npm init playwright@latest
  Test credentials missing -> Run /pp:add (will prompt if Playwright enabled)
  Session mode not set     -> Run /pp:status (will prompt)
  Tests keep failing       -> Check for 403/401 (server-side fix needed)

UPDATE
------
  To update: cd ~/.claude/skills/pp && git pull origin main
  Check version: cat ~/.claude/skills/pp/VERSION
```

</process>
