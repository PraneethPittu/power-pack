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
║                            POWER-PACK HELP                                   ║
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
  Captures a task and adds it to the queue. Asks clarifying questions to
  understand your intent before creating the request.

  Examples:
    /pp add add a logout button to the header
    /pp add make the dashboard load faster
    /pp add fix login bug with special characters

  Skip questions:
    /pp add add dark mode, just capture it

/pp work
  Processes all pending tasks. For each task:
    1. Analyzes if research is needed (OAuth, WebSocket, Stripe, etc.)
    2. Researches best practices (if needed)
    3. Explores codebase for existing patterns
    4. Plans implementation (for complex tasks)
    5. Implements the feature
    6. Generates Playwright tests
    7. Runs tests in fix-retry loop (up to 10 attempts)
    8. Archives and commits (if auto-commit enabled)

/pp resume
  Continues work after terminal close or context reset.
  Restores: current task, test attempts, skipped tests, decisions made.

/pp status
  Shows: queue count, current task, step progress, recent completions, blockers.

/pp mode normal
  Pauses at decision points, asks for confirmation.
  Best when you're actively working.

/pp mode overnight
  Runs autonomously, auto-selects recommended options.
  Skips destructive actions. Logs all decisions.
  Best for large queues when you'll be away.

SESSION SETUP
────────────────────────────────────────────────────────────────────────────────

On first command, you'll be asked:
  1. Session mode: Normal (with checkpoints) or Overnight (autonomous)
  2. Auto-commit: Yes (commit after each task) or No (manual commits)

FOLDER STRUCTURE
────────────────────────────────────────────────────────────────────────────────

  pp/
  ├── REQ-*.md              Pending tasks (queue)
  ├── STATE.md              Session state for resume
  ├── config/test-env.json  Test credentials (gitignored)
  ├── research/             Auto-generated research docs
  ├── working/              Task currently being processed
  └── archive/              Completed tasks with verification

  tests/pp/         Generated Playwright tests

TIPS
────────────────────────────────────────────────────────────────────────────────

  • Be specific when capturing tasks
  • Answer questions thoughtfully — they guide implementation
  • Use overnight mode for large queues
  • Check VERIFICATION.md for skipped tests
  • If stuck, run: rm pp/STATE.md

TROUBLESHOOTING
────────────────────────────────────────────────────────────────────────────────

  Playwright not found     → npm init playwright@latest
  Test credentials missing → Run /pp work (will prompt)
  Session mode not set     → Run /pp status (will prompt)
  Tests keep failing       → Check for 403/401 (server-side fix needed)

────────────────────────────────────────────────────────────────────────────────
For full documentation, see: ~/.claude/skills/pp/README.md
```

## Implementation

Simply output the help text above when `/pp help` is invoked. No file operations needed.
