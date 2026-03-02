---
name: pp
description: Power-pack task queue with smart questioning, auto-research, and Playwright testing
argument-hint: add <task> | work | status | resume | help | mode
---

# Power-Pack Skill

A powerful task management system that combines quick capture with deep understanding. Merges the speed of do-work with the intelligence of GSD.

**Core Philosophy:** Understand before building. Ask questions when uncertain. Verify goals were achieved.

## CRITICAL: Capture vs Work Separation

**`/pp add` and `/pp work` are SEPARATE actions. Do NOT combine them.**

### `/pp add <task>` — Capture ONLY
- Rephrase prompt into optimized detailed version (using agent)
- Save rephrased prompt to `pp/rephrased/`
- Ask clarifying questions (ALWAYS — both Normal and Overnight modes)
- Enter plan mode and create implementation plan (EVERY task)
- Save plan to `pp/plans/`
- Create REQ file(s) with references to rephrased prompt and plan
- **NEVER write code**
- **NEVER implement anything**
- End with: "Ready to implement? Run `/pp work`"

### `/pp work` — Implementation ONLY
- Follow the workflow in [work action](./actions/work.md) step by step
- Move files through: `pp/` → `pp/working/` → `pp/archive/`
- Generate tests, run test loop, create verification

**NEVER implement during `/pp add`. NEVER skip file operations during `/pp work`.**

---

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

## Update Check (First-Time Per Session)

On the **first `/pp` command** in a new session, **before asking setup questions**, check for updates:

1. Run this command silently:
```bash
cd ~/.claude/skills/pp && git fetch origin main 2>/dev/null && git rev-list HEAD..origin/main --count 2>/dev/null
```

2. **If count > 0** (updates available):
   - Read the local VERSION file: `cat ~/.claude/skills/pp/VERSION`
   - Read the remote VERSION: `git show origin/main:VERSION 2>/dev/null`
   - Read the remote CHANGELOG: `git show origin/main:CHANGELOG.md 2>/dev/null`
   - **Auto-pull the update:**
   ```bash
   cd ~/.claude/skills/pp && git pull origin main 2>/dev/null
   ```
   - Display to the user:
   ```
   pp updated! v[old] → v[new]

   What's new:
   [Show the latest changelog entry from remote CHANGELOG.md]

   ⚠ Restart your Claude Code session to get all changes.
   (Action files update immediately, but session setup and routing
   changes only take effect in a new session.)
   ```
   - Then continue with session setup as normal

3. **If count = 0 or fetch fails** (up to date or offline):
   - Say nothing, proceed silently to session setup

**This check runs ONCE per session, not on every command.** After the first check, skip it for all subsequent `/pp` commands in the same session.

---

## Session Setup (MANDATORY — Every New Session)

**CRITICAL: On the FIRST `/pp` command in a new session, you MUST ask these FOUR questions. NO EXCEPTIONS.**

**Rules:**
- **ALWAYS ask these 4 questions at the start of every new Claude Code session** — even if you see preferences in MEMORY.md, STATE.md, or anywhere else
- **NEVER skip these questions** because you "already know" the preferences from a previous session
- **NEVER persist these preferences** to MEMORY.md or any auto-memory file — they are session-only
- Previous session preferences are INVALID — each session starts fresh
- The only time you skip these is on subsequent `/pp` commands within the SAME session (after already asking once)

Ask these FOUR questions:

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

Capture (`/pp add`) **ALWAYS asks clarifying questions in BOTH modes.** The only exception is if user says "just capture it".

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
- "Yes" — Generate and run Playwright tests for each task (zero tolerance — functionality + UI screenshot verification)
- "No" — Skip automated testing, I'll test manually
```

| Setting | Behavior |
|---------|----------|
| **Yes** | Generate Playwright tests (functionality + UI screenshots), run zero-tolerance fix-retry loop, screenshot review for UI issues |
| **No** | Skip test generation, skip test credentials prompt, no VERIFICATION.md |

**If "No":**
- Don't ask for test environment credentials
- Skip Steps 8-9b (Generate Tests, Test Loop, Screenshot Review) during `/pp work`
- Skip VERIFICATION.md generation

### Question 4: Plan Verification

```
[AskUserQuestion]
header: "Plan review"
question: "Do you want to review the implementation plan before I proceed, or should I continue directly?"
options:
- "Verify with me" — Show plan and ask for approval before proceeding
- "Continue directly" — Show plan but don't wait for approval, proceed automatically
```

| Setting | Behavior |
|---------|----------|
| **Verify with me** | Display plan, ask for approval/changes before creating REQ file |
| **Continue directly** | Display plan (always shown), proceed without waiting for confirmation |

**Store all four in memory** for this session ONLY.

**NEVER persist these to MEMORY.md, auto-memory, or any file that carries across sessions.**
**NEVER save "PP Session Config" or similar to memory files.**

These preferences are asked ONCE per Claude Code session. Subsequent `/pp` commands within the same session reuse the stored preferences. But every NEW session must ask again.

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
| Prompt quality | As-is | Auto-rephrased for maximum output |
| Questioning | Minimal | Collaborative (both modes) |
| Planning | None | Plan mode for every task |
| Research | None | Auto-detect & research unfamiliar tech |
| Testing | Runs existing | Zero-tolerance functionality + UI screenshot tests |
| Test failures | Mark failed | Fix-retry loop — must reach 100% pass |
| UI verification | None | Screenshot review with alignment/spacing checks |
| State tracking | Frontmatter | STATE.md for resume |
| Checkpoints | None | Normal/Overnight modes |

## Action References

**IMPORTANT: You MUST read and follow the detailed instructions in the action file for the command being executed.**

When routing to an action, READ THE FULL ACTION FILE before doing anything:

| Command | Action File to READ |
|---------|---------------------|
| `/pp add` | **READ [capture action](./actions/capture.md) FIRST** |
| `/pp work` | **READ [work action](./actions/work.md) FIRST** |
| `/pp status` | **READ [status action](./actions/status.md) FIRST** |
| `/pp help` | **READ [help action](./actions/help.md) FIRST** |

**DO NOT improvise. DO NOT skip reading the action file. The action files contain step-by-step instructions that MUST be followed exactly.**

## Folder Structure

```
pp/
├── REQ-001-task.md           # Pending queue
├── STATE.md                   # Current state, decisions, blockers
├── config/
│   └── test-env.json         # Test credentials (gitignored)
├── rephrased/                 # Optimized prompts (from capture step 1)
│   └── REQ-001-rephrased.md
├── plans/                     # Implementation plans (from capture step 6)
│   └── REQ-001-plan.md
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
    ├── REQ-001-task.spec.js
    └── screenshots/           # UI verification screenshots
        └── REQ-001/
            ├── ui-initial-fullpage.png
            ├── ui-feature-element.png
            ├── ui-mobile.png
            └── ui-tablet.png
```
