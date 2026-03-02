# Help Action

> **Part of the power-pack skill.** Displays help documentation for all commands.

## Overview

The help action displays comprehensive documentation about all power-pack commands, their usage, and examples.

## Trigger

```
/pp help
```

## Output

When user runs `/pp help`, display the following:

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                            POWER-PACK HELP v2.0                            ║
╚══════════════════════════════════════════════════════════════════════════════╝

A powerful task management skill combining do-work speed with GSD intelligence.

COMMANDS
────────────────────────────────────────────────────────────────────────────────

  /pp help                     Show this help documentation
  /pp add <description>        Capture a new task with smart questioning
  /pp work                     Process all pending tasks in the queue
  /pp resume                   Continue from where you left off
  /pp status                   Show current state and queue
  /pp mode <normal|overnight>  Switch session mode

COMMAND DETAILS
────────────────────────────────────────────────────────────────────────────────

/pp add <description>
  Captures a task and adds it to the queue. For every task:
    1. Rephrases your prompt (agent-powered)
    2. Shows rephrased version for approval
    3. Asks clarifying questions (ALWAYS, both modes)
    4. Assesses complexity (simple / medium / complex)
    5. Enters plan mode (medium & complex only — skipped for simple tasks)
    6. Creates REQ file with all references

  Examples:
    /pp add add a logout button to the header
    /pp add make the dashboard load faster
    /pp add fix login bug with special characters

  Note: Questions are ALWAYS asked. Planning is for medium/complex tasks only.

/pp work
  Processes all pending tasks. For each task:
    1. Claims the request (moves to working/)
    2. Analyzes if research is needed (OAuth, WebSocket, Stripe, etc.)
    3. Researches best practices (if needed)
    4. Explores codebase for existing patterns
    5. Loads plan from capture phase (pp/plans/)
    6. Implements the feature
    7. Generates Playwright tests (functionality + UI screenshots)
    8. Runs test loop — zero tolerance on code errors (10 attempts max)
    9. Reviews ALL screenshots for UI issues — fixes until perfect
   10. Creates verification report
   11. Archives and commits (if auto-commit enabled)

/pp resume
  Continues work after terminal close or context reset.
  Restores: current task, test attempts, skipped tests, UI issues,
  screenshots reviewed, decisions made.

/pp status
  Shows: queue count, current task, step progress, UI review status,
  recent completions, blockers.

/pp mode normal
  Pauses at decision points, asks for confirmation.
  Best when you're actively working.

/pp mode overnight
  Runs autonomously, auto-selects recommended options.
  Skips destructive actions. Logs all decisions.
  Best for large queues when you'll be away.

  Note: /pp add ALWAYS asks questions regardless of mode.
  Overnight mode only affects the WORK phase (implementation checkpoints).

SESSION SETUP
────────────────────────────────────────────────────────────────────────────────

On first command of EVERY new session, you'll be asked 4 questions:
  1. Session mode: Normal (with checkpoints) or Overnight (autonomous)
  2. Auto-commit: Yes (commit after each task) or No (manual commits)
  3. Playwright testing: Yes (generate & run tests) or No (skip testing)
  4. Plan verification: Verify with me (review plans) or Continue directly

These are MANDATORY and asked every session — never persisted or assumed.

FOLDER STRUCTURE
────────────────────────────────────────────────────────────────────────────────

  pp/
  ├── REQ-*.md              Pending tasks (queue)
  ├── STATE.md              Session state for resume
  ├── config/test-env.json  Test credentials (gitignored)
  ├── research/             Auto-generated research docs
  ├── rephrased/            Rephrased prompts from capture
  ├── plans/                Implementation plans from capture
  ├── working/              Task currently being processed
  └── archive/              Completed tasks with verification

  tests/pp/                 Generated Playwright tests
  tests/pp/screenshots/     UI screenshots from test runs

TESTING — ZERO TOLERANCE
────────────────────────────────────────────────────────────────────────────────

  • Functionality tests: One per "Done When" criterion + edge cases
  • UI screenshot tests: Full page, element, hover, mobile (375px), tablet (768px)
  • Every test takes at least one screenshot
  • Infrastructure errors (403, CORS, connection refused): Skip + report
  • Code errors (500, assertion failed, element not found): Fix + retry (max 10)
  • After tests pass: Review EVERY screenshot for UI issues
  • Fix ALL UI issues, regenerate screenshots, repeat until perfect

TIPS
────────────────────────────────────────────────────────────────────────────────

  • Be specific when capturing tasks
  • Answer questions thoughtfully — they guide implementation
  • Use overnight mode for large queues
  • Check VERIFICATION.md for skipped tests and UI fixes
  • If stuck, run: rm pp/STATE.md

TROUBLESHOOTING
────────────────────────────────────────────────────────────────────────────────

  Playwright not found     → npm init playwright@latest
  Test credentials missing → Run /pp work (will prompt)
  Session mode not set     → Run /pp status (will prompt)
  Tests keep failing       → Check for 403/401 (server-side fix needed)
  Screenshots blurry       → Check viewport settings in test file

────────────────────────────────────────────────────────────────────────────────
For full documentation, see: ~/.claude/skills/pp/README.md
```

## Implementation

Simply output the help text above when `/pp help` is invoked. No file operations needed.
