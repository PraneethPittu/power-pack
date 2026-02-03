# pp (Power-Pack)

A powerful task management skill for Claude Code with smart questioning, auto-research, and automated Playwright testing.

## What is this?

`pp` helps you capture, implement, and test tasks with:
- **Smart questioning** — Understands what you want before building
- **Auto-research** — Researches unfamiliar tech before coding
- **Automated testing** — Generates Playwright tests and runs them in a fix-retry loop
- **Session memory** — Resume work across terminals/sessions
- **Checkpoints** — Asks for confirmation at key decision points (optional)

---

## Installation

### Option 1: One-liner (Recommended)

```bash
mkdir -p ~/.claude/skills && git clone https://github.com/PraneethPittu/power-pack.git ~/.claude/skills/pp && ln -sf ~/.claude/skills/pp/commands ~/.claude/commands/pp
```

### Option 2: Step by step

```bash
# 1. Clone the repo
mkdir -p ~/.claude/skills
git clone https://github.com/PraneethPittu/power-pack.git ~/.claude/skills/pp

# 2. Link commands to Claude Code (REQUIRED)
ln -sf ~/.claude/skills/pp/commands ~/.claude/commands/pp
```

### Option 3: Using degit (no git history)

```bash
npx degit PraneethPittu/power-pack ~/.claude/skills/pp
ln -sf ~/.claude/skills/pp/commands ~/.claude/commands/pp
```

### Verify Installation

```bash
ls ~/.claude/commands/pp/
# Should show: add.md, work.md, status.md, help.md, mode.md, resume.md
```

**Important:** Restart Claude Code after installation to detect the new commands.

---

## Quick Start

### 1. First-time setup

Run any `/pp` command in your project:

```
/pp:status
```

You'll be asked three questions (once per session):

**Session Mode:**
```
How will you be using this session?
- "Normal" — I'm here, ask me at decision points
- "Overnight" — Run autonomously, don't wait for input
```

**Auto-commit:**
```
Do you want to auto-commit changes after each task?
- "Yes" — Commit after each task automatically
- "No" — I'll commit manually
```

**Playwright Testing:**
```
Do you want automated Playwright tests for this session?
- "Yes" — Generate and run tests for each task
- "No" — Skip automated testing, I'll test manually
```

If you choose "No" for testing, the skill skips test credentials setup, test generation, and the fix-retry loop.

### 2. Capture a task

```
/pp:add add a logout button to the header
```

**If Playwright testing is enabled**, you'll first be asked for test credentials (once per project):
```
Do you have a .env file with test credentials?
- "Yes, I have .env" → Provide path
- "No .env file" → Provide credentials directly
- "No login yet" → Skip for now (new project or no auth yet)
```

This creates `pp/config/test-env.json` (gitignored). If you choose "No login yet", Playwright tests will be skipped until you configure credentials later.

**Then** the skill will ask clarifying questions about your task:
- Where exactly in the header?
- What should happen on click?
- How will you know it's working?

### 4. Process the queue

```
/pp:work
```

The skill will:
1. Research (if unfamiliar tech detected)
2. Explore your codebase for patterns
3. Plan (if complex task)
4. Implement the feature
5. Generate Playwright tests
6. Run tests in a loop (fix failures, retry)
7. Archive and commit (if enabled)

---

## Commands Reference

| Command | Description |
|---------|-------------|
| `/pp` | Show status (default) |
| `/pp:help` | Show help with all commands and detailed usage |
| `/pp:add <description>` | Capture a new task with smart questioning |
| `/pp:work` | Process all pending tasks in the queue |
| `/pp:resume` | Continue from where you left off (after context reset) |
| `/pp:status` | Show current state, queue, and recent completions |
| `/pp:mode normal` | Switch to normal mode (pauses at checkpoints) |
| `/pp:mode overnight` | Switch to overnight mode (runs autonomously) |

---

## Detailed Command Guide

### `/pp:help`

Shows help documentation with all available commands and their usage.

```
/pp:help
```

**Output:** Displays the full command reference, workflow overview, and troubleshooting tips.

---

### `/pp:add <description>`

Captures a new task and adds it to the queue. Uses collaborative questioning to understand your intent before creating the request.

```
/pp:add make the dashboard faster
/pp:add add dark mode toggle to settings
/pp:add fix login bug when password has special characters
```

**What happens:**
1. **(First time only, if Playwright enabled)** Asks for test credentials if `pp/config/test-env.json` doesn't exist
2. Analyzes your description for clarity
3. Asks clarifying questions if needed (What? Why? How will you know it's done?)
4. Creates a REQ file in `pp/` folder
5. Reports what was captured

**Question types it may ask:**
- **Motivation:** "What prompted this?" / "What problem are you solving?"
- **Concreteness:** "Walk me through using this" / "Give me an example"
- **Clarification:** "When you say X, do you mean A or B?"
- **Success criteria:** "How will you know this is working?"

**Skip questions:** Add "just capture it" to skip questioning:
```
/pp:add add dark mode, just capture it
```

---

### `/pp:work`

Processes all pending tasks in the queue. This is the main execution command.

```
/pp:work
```

**What happens for each task:**

| Step | Action | Agent Used |
|------|--------|------------|
| 1. Claim | Move task to working folder | — |
| 2. Analyze | Check if research is needed | — |
| 3. Research | Gather best practices (if needed) | WebSearch, Context7 |
| 4. Explore | Find existing patterns in codebase | Explore agent |
| 5. Plan | Create implementation plan (complex tasks) | Plan agent |
| 6. Implement | Build the feature | general-purpose agent |
| 7. Generate Tests | Create Playwright test scripts | — |
| 8. Test Loop | Run tests, fix failures, retry (up to 10x) | — |
| 9. Archive | Move completed task to archive | — |
| 10. Commit | Git commit (if auto-commit enabled) | — |

**Auto-research triggers:** OAuth, JWT, WebSocket, Stripe, Firebase, real-time features, payment processing, external APIs.

**Auto-skip research:** Bug fixes, UI changes, config changes, simple CRUD.

---

### `/pp:resume`

Continues work from where you left off. Use this after:
- Closing the terminal
- Context limit reached
- Switching to another project and coming back

```
/pp:resume
```

**What it restores:**
- Current task being worked on
- Test attempt counters
- Skipped tests list
- Last error context
- Decisions made during the session

**State is stored in:** `pp/STATE.md`

---

### `/pp:status`

Shows the current state of your pp queue.

```
/pp:status
```

**Output includes:**
- Current status (idle / working / paused)
- Number of pending tasks
- Task currently being worked on (if any)
- Current step and progress
- Recent completions with test results
- Any blockers or failures

**Example output:**
```
pp Status

Status: Working (paused)
Current: REQ-015-websocket-notifications
Step: Testing (attempt 4/10)
Last activity: 2026-02-03 14:30

Tests: 3/5 passed, 0 skipped, 2 remaining

Pending queue: 2 tasks
  - REQ-016: Add dark mode
  - REQ-017: Export to PDF

Run `/pp:resume` to continue.
```

---

### `/pp:mode <normal|overnight>`

Switches the session mode mid-session.

```
/pp:mode normal      # Switch to normal mode
/pp:mode overnight   # Switch to overnight mode
```

**Normal mode:**
- Pauses at decision points
- Asks for confirmation on architectural choices
- Asks before destructive actions
- Best when you're actively working

**Overnight mode:**
- Runs autonomously without pausing
- Auto-selects recommended options
- Skips destructive actions (won't auto-delete files)
- Logs all decisions to STATE.md
- Best for large queues when you'll be away

---

## Folder Structure

When you use `/pp:add` and `/pp:work`, it creates the following folders in your project:

```
your-project/
├── pp/
│   ├── REQ-001-task.md
│   ├── REQ-002-task.md
│   ├── STATE.md
│   ├── config/
│   │   └── test-env.json
│   ├── research/
│   │   └── REQ-001-RESEARCH.md
│   ├── user-requests/
│   │   └── UR-001/
│   │       ├── input.md
│   │       └── assets/
│   ├── working/
│   │   └── REQ-001-task.md
│   └── archive/
│       └── UR-001/
│           ├── input.md
│           ├── REQ-001-task.md
│           └── VERIFICATION.md
│
└── tests/
    └── pp/
        └── REQ-001-task.spec.js
```

### Folder Descriptions

| Folder/File | Purpose |
|-------------|---------|
| `pp/` | Main folder created in your project |
| `pp/REQ-*.md` | Pending tasks waiting in the queue |
| `pp/STATE.md` | Session state for resuming work after context reset |
| `pp/config/` | Configuration files |
| `pp/config/test-env.json` | Test credentials for Playwright (gitignored) |
| `pp/research/` | Auto-generated research documents |
| `pp/research/REQ-*-RESEARCH.md` | Research findings for tasks needing external tech |
| `pp/user-requests/` | Original user input preservation |
| `pp/user-requests/UR-*/` | Each user request gets a numbered folder |
| `pp/user-requests/UR-*/input.md` | Verbatim copy of your original request |
| `pp/user-requests/UR-*/assets/` | Screenshots and attachments |
| `pp/working/` | Task currently being processed |
| `pp/archive/` | Completed tasks with verification reports |
| `pp/archive/UR-*/` | Archived user request with all related files |
| `pp/archive/UR-*/VERIFICATION.md` | Test results and verification report |
| `tests/pp/` | Generated Playwright test files |
| `tests/pp/REQ-*.spec.js` | Auto-generated test scripts |

---

## Features Explained

### 1. Smart Questioning

Instead of guessing what you want, pp asks clarifying questions:

```
You: /pp:add make the dashboard faster

pp: What's slow about the dashboard?
  - Initial load time
  - Data refresh
  - Interactions
  - Let me explain

You: Initial load time

pp: How will you know it's fixed?
  - Under 2 seconds
  - 50% faster
  - Just noticeably better
  - Let me explain

You: Under 2 seconds

pp: Created REQ-008-dashboard-load-time.md
    Target: Initial load under 2 seconds
```

### 2. Auto-Research

When pp detects unfamiliar technology, it automatically researches before building:

**Triggers research:**
- External APIs (Stripe, Twilio, Firebase)
- Protocols (OAuth, JWT, WebSocket)
- Real-time features
- Payment processing
- New libraries/SDKs

**Skips research:**
- Bug fixes
- UI changes
- Config changes
- Simple CRUD operations

```
Processing REQ-015-websocket-notifications.md...
  Analyzing...          [needs research: WebSocket]
  Researching...        [done] → RESEARCH.md created

  Key findings:
  - Library: Socket.io v4.7
  - Pattern: Heartbeat + reconnection
  - Pitfall: Token refresh on reconnect

  Implementing with research context...
```

### 3. Automated Playwright Testing

For each task, pp:
1. Generates Playwright test scripts based on your "Done When" criteria
2. Runs tests in a loop
3. Analyzes failures and fixes code
4. Retries until all tests pass
5. Auto-skips after 10 failed attempts or infrastructure issues

**Test results in VERIFICATION.md:**
```markdown
| Test | Status | Attempts | Notes |
|------|--------|----------|-------|
| logout button exists | ✓ PASS | 1 | |
| redirects to /login | ✓ PASS | 3 | Fixed redirect path |
| session cleared | ⚠ SKIPPED | 10 | Auto-skipped: max attempts |
```

### 4. Session Modes

**Normal Mode:**
- Pauses at decision points
- Asks for confirmation on destructive actions
- Best when you're actively working

**Overnight Mode:**
- Runs autonomously
- Auto-selects recommended options
- Skips destructive actions (won't auto-delete)
- Logs all decisions to STATE.md

### 5. State & Resume

Work is saved to `pp/STATE.md`. If you:
- Close the terminal
- Hit context limits
- Switch to another project

Just come back and run:
```
/pp:resume
```

It continues exactly where you left off, including:
- Current task
- Test attempt counts
- Skipped tests
- Decisions made

---

## Configuration

### Test Environment

Test credentials are asked **once during your first `/pp:add`** (when Playwright is enabled and config doesn't exist), then reused for all tasks.

```json
// pp/config/test-env.json (auto-generated, gitignored)
{
  "loginUrl": "https://example.com/login",
  "username": "test_user",
  "password": "****",
  "baseUrl": "https://example.com",
  "createdAt": "2026-02-03T10:00:00Z"
}
```

**To change test config for a specific task**, say:
- "change test config"
- "use different credentials"
- "different env for this task"

You'll be asked:
```
How do you want to update the test config?
- "Update for this task only" — Temporary override
- "Update permanently" — Replace saved config
- "Never mind" — Keep existing
```

### Session Preferences

These are asked at session start (not persisted):
- **Session mode**: Normal / Overnight
- **Auto-commit**: Yes / No
- **Playwright testing**: Yes / No

To change mode mid-session:
```
/pp:mode overnight
/pp:mode normal
```

**Note:** Playwright testing preference is set once at session start and cannot be changed mid-session.

---

## Workflow Details

### The 13-Step Process

1. **Find Next Request** — Pick first REQ from queue
2. **Claim** — Move to working/, update status
3. **Analyze** — Does this need research?
4. **Research** — Gather best practices (if needed)
5. **Explore** — Find existing patterns (Explore agent)
6. **Plan** — Create implementation plan (Plan agent, if complex)
7. **Implement** — Build the feature (general-purpose agent)
8. **Generate Tests** — Create Playwright scripts
9. **Test Loop** — Run → Fix → Retry (up to 10 times)
10. **Verification Report** — Document results
11. **Archive** — Move to archive/
12. **Commit** — Git commit (if enabled)
13. **Loop** — Next task or exit

### Test Loop Logic

```
Run tests
    ↓
All pass? → Done ✓
    ↓
Infrastructure error? (403, 401, CORS) → Skip (can't fix with code)
    ↓
Code error? (500, assertion failed)
    ↓
Failed 10 times? → Skip (needs manual investigation)
    ↓
Fix the code → Retry
```

---

## Tips

### For best results:

1. **Be specific** when capturing tasks
   - Bad: "fix the bug"
   - Good: "fix the login error when password contains special characters"

2. **Answer questions thoughtfully** — The skill uses your answers to build and test

3. **Use overnight mode** for large queues when you'll be away

4. **Check VERIFICATION.md** for skipped tests — they may need manual attention

### If something goes wrong:

1. **Check STATE.md** — See current position and any blockers
2. **Run `/pp:status`** — Get a summary of what's happening
3. **Clear state if stuck**: `rm pp/STATE.md`

---

## Troubleshooting

### "Playwright not found"
```bash
npm init playwright@latest
```

### "Test credentials missing"
Run `/pp:add <any task>` — it will prompt for credentials before capturing if Playwright testing is enabled.

### "Session mode not set"
Run `/pp:status` to trigger the first-time setup.

### Tests keep failing the same way
Check if it's an infrastructure issue (403, 401, CORS). These need manual server-side fixes.

---

## License

Free to use, modify, and share.
