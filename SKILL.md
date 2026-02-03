---
name: pp
description: Power-pack task queue with smart questioning, auto-research, and Playwright testing
argument-hint: add <task> | work | status | resume | help | mode
---

# Power-Pack Skill

A powerful task management system that combines quick capture with deep understanding. Merges the speed of do-work with the intelligence of GSD.

**Core Philosophy:** Understand before building. Ask questions when uncertain. Verify goals were achieved.

## CRITICAL: Follow the Workflow

**When `/pp work` is invoked, you MUST follow the workflow in [work action](./actions/work.md) step by step.**

**NEVER:**
- Implement directly without creating folder structure first
- Skip the claim step (moving REQ to working/)
- Delegate file operations to agents
- Skip test generation (if Playwright enabled)
- Skip archiving completed work

**ALWAYS:**
- Run `mkdir -p pp/{config,research,working,archive} tests/pp` first
- Move REQ file to `pp/working/` before implementation
- Update STATE.md at each step
- Generate Playwright tests yourself (not via agents)
- Run the test loop until pass/skip
- Move completed work to `pp/archive/`

**The work action file contains an Orchestrator Checklist. Use it.**

## Session Setup (First-Time Prompt)

On the **first `/pp` command** in a new session, ask THREE questions:

### Question 1: Session Mode

```
[AskUserQuestion]
header: "Session Mode"
question: "How will you be using this session?"
options:
- "Normal" — I'm here, ask me at decision points
- "Overnight" — Run autonomously, don't wait for input
```

| Mode | Behavior |
|------|----------|
| **Normal** | Pause at checkpoints, ask for confirmation |
| **Overnight** | Auto-select recommended options, log decisions |

**IMPORTANT: Overnight mode only affects the WORK phase (implementation checkpoints).**

Capture (`/pp add`) **always asks clarifying questions** regardless of mode, unless user says "just capture it".

### Question 2: Auto-Commit

```
[AskUserQuestion]
header: "Auto-commit"
question: "Do you want to auto-commit changes after each task?"
options:
- "Yes" — Commit automatically after each completed task
- "No" — I'll commit manually when ready
```

| Setting | Behavior |
|---------|----------|
| **Yes** | Git commit after each task completes (Step 12) |
| **No** | Skip commit step — user commits manually |

### Question 3: Playwright Testing

```
[AskUserQuestion]
header: "Auto-testing"
question: "Do you want automated Playwright tests for this session?"
options:
- "Yes" — Generate and run Playwright tests for each task
- "No" — Skip automated testing, I'll test manually
```

| Setting | Behavior |
|---------|----------|
| **Yes** | Generate Playwright tests, run fix-retry loop (Steps 8-9) |
| **No** | Skip test generation, skip test credentials prompt, no VERIFICATION.md |

**If "No":**
- Don't ask for test environment credentials
- Skip Steps 8-9 (Generate Tests, Test Loop) during `/pp work`
- Skip VERIFICATION.md generation

**Store all three in memory** for this session (not persisted to disk).

**This is asked once per Claude session.** Subsequent `/pp` commands use the stored preferences.

To switch mode mid-session: `/pp mode normal` or `/pp mode overnight`

## Commands

| Command | Action | Description |
|---------|--------|-------------|
| `/pp help` | help | Show help documentation with all commands |
| `/pp add <description>` | capture | Capture a new task with smart questioning |
| `/pp work` | work | Process all pending tasks in the queue |
| `/pp resume` | resume | Continue from where you left off |
| `/pp status` | status | Show current state and pending work |
| `/pp mode <normal\|overnight>` | mode | Switch session mode |

## Routing Decision

### Step 1: Parse the Command

Examine what follows `/pp`:

| Pattern | Example | Route |
|---------|---------|-------|
| Empty or `status` | `/pp` or `/pp status` | → status (show current state) |
| `help` | `/pp help` | → help (show documentation) |
| `add <text>` | `/pp add make it faster` | → capture (with text as input) |
| `work` | `/pp work` | → work (process queue) |
| `resume` | `/pp resume` | → resume (continue from STATE.md) |
| `mode normal` | `/pp mode normal` | → set mode to Normal |
| `mode overnight` | `/pp mode overnight` | → set mode to Overnight |

### Step 2: Extract Payload for add

For `/pp add`, everything after `add ` is the task description:

```
/pp add make the dashboard faster
        ^^^^^^^^^^^^^^^^^^^^^^^^
        This is the payload → passed to capture action
```

### Step 3: Handle Ambiguous Input

If input doesn't match a known command but has content:
- Treat it as `/pp add <content>`
- Example: `/pp fix the login bug` → routes to capture with "fix the login bug"

## What Makes This Different

| Aspect | do-work | pp (power-pack) |
|--------|---------|-----------------|
| Questioning | Minimal | Collaborative (GSD-style) |
| Research | None | Auto-detect & research unfamiliar tech |
| Testing | Runs existing | Generates Playwright tests |
| Test failures | Mark failed | Fix-retry loop (up to 10x) |
| State tracking | Frontmatter | STATE.md for resume |
| Checkpoints | None | Normal/Overnight modes |

## Action References

- [help action](./actions/help.md) — Display help documentation
- [capture action](./actions/capture.md) — Task capture with questioning
- [work action](./actions/work.md) — Queue processing with verification
- [status action](./actions/status.md) — Current state and next steps

## Folder Structure

```
pp/
├── REQ-001-task.md           # Pending queue
├── STATE.md                   # Current state, decisions, blockers
├── config/
│   └── test-env.json         # Test credentials (gitignored)
├── research/
│   └── REQ-015-RESEARCH.md   # Auto-generated research docs
├── user-requests/             # Verbatim input preservation
│   └── UR-001/
│       ├── input.md
│       └── assets/
├── working/                   # In progress
└── archive/                   # Completed work
    └── UR-001/
        ├── input.md
        ├── REQ-001-task.md
        └── VERIFICATION.md

tests/
└── pp/                        # Generated Playwright tests
    └── REQ-001-task.spec.js
```
