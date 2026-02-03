# Capture Action

> **Part of the power-pack skill.** Captures tasks with collaborative questioning — understand intent before creating requests.

## IMPORTANT: Overnight Mode Does NOT Skip Capture Questions

**Overnight mode only affects the WORK phase** (auto-selects at checkpoints during implementation).

During capture, **ALWAYS ask clarifying questions** regardless of session mode, unless:
- User explicitly says "just capture it" or "figure it out"
- Request is extremely specific with clear success criteria (rare)

Even detailed/long requests (500+ words) still need questions about:
- Success criteria: "How will you know it's working?"
- Priority: "Which part matters most?"
- Scope boundaries: "Should this include X or just Y?"

**The length of a request does NOT equal clarity.**

---

## Test Environment (Mandatory - BLOCKING)

**STOP! Before capturing ANY task, you MUST check test environment.**

This is a BLOCKER — do not proceed to questioning or capture until resolved.

### First-Time Setup

**Step 1: Check if config exists:**

```bash
cat pp/config/test-env.json 2>/dev/null
```

**If config doesn't exist**, ask these mandatory questions:

```
[AskUserQuestion]
header: "Test Config"
question: "I need test environment details for automated testing. Do you have a .env file with credentials?"
options:
- "Yes, I have .env" — I'll provide the path
- "No .env file" — I'll provide credentials directly
```

**If user has .env:**
```
[AskUserQuestion]
header: ".env Path"
question: "What's the path to your .env file?"
→ User provides path

Read the .env file and extract:
- Login URL (look for: LOGIN_URL, AUTH_URL, BASE_URL)
- Username (look for: TEST_USER, USERNAME, ADMIN_USER)
- Password (look for: TEST_PASS, PASSWORD, ADMIN_PASS)
- Base URL (look for: APP_URL, BASE_URL, SITE_URL)

If any are missing, ask for them specifically.
```

**If user has no .env — ask each:**

```
[AskUserQuestion]
header: "Login URL"
question: "What's the login URL for testing?"
→ e.g., https://example.com/login

[AskUserQuestion]
header: "Username"
question: "What username should tests use to log in?"
→ e.g., test_user

[AskUserQuestion]
header: "Password"
question: "What password should tests use?"
→ e.g., (user provides)

[AskUserQuestion]
header: "Base URL"
question: "What's the base URL of the application?"
→ e.g., https://example.com
```

**Create config file:**

```bash
mkdir -p pp/config
```

Write `pp/config/test-env.json`:
```json
{
  "loginUrl": "https://example.com/login",
  "username": "test_user",
  "password": "***",
  "baseUrl": "https://example.com",
  "envFile": "/path/to/.env or null",
  "createdAt": "2026-02-03T10:00:00Z"
}
```

**Add to .gitignore** (contains credentials):
```bash
echo "pp/config/test-env.json" >> .gitignore
```

### Per-Task Test URL

For each task, also ask:

```
[AskUserQuestion]
header: "Test URL"
question: "What URL should we test this feature on?"
options:
- "[baseUrl]/dashboard" — Dashboard page
- "[baseUrl]/settings" — Settings page
- "Let me specify" — Different URL
```

Store in the REQ file's `test_url` frontmatter field.

---

## Philosophy

**You are a thinking partner, not a task recorder.**

The user often has a fuzzy idea. Your job is to help them sharpen it. Ask questions that make them think "oh, I hadn't considered that" or "yes, that's exactly what I mean."

- **Clarity over speed**: Ask questions when uncertain rather than guessing
- **Collaborate, don't interrogate**: Follow the thread of conversation
- **Challenge vagueness**: "Good" means what? "Fast" means how? "Users" means who?
- **Know when to stop**: When you understand it clearly, capture it

## When to Ask Questions

### ASK when any of these apply:

| Signal | Example Input | What's Unclear |
|--------|---------------|----------------|
| **Vague outcome** | "make it better" | Better how? |
| **Unclear scope** | "fix the search" | Which part? |
| **Missing context** | "add a button" | Where? What does it do? |
| **Ambiguous terms** | "users should see updates" | Real-time? On refresh? Email? |
| **Multiple interpretations** | "improve performance" | Load time? Memory? API speed? |
| **No success criteria** | "make it faster" | How fast? How will you know? |

### DON'T ASK when:

- The request is **truly specific AND has clear success criteria** ("add a logout button to the header that redirects to /login" — we know exactly what "done" looks like)
- Technical implementation is unclear (that's for the builder)
- You're just curious (capture what they said)
- User explicitly says "just capture it" or "figure it out"

**WARNING: Long/detailed requests are NOT automatically "specific and actionable"**

A 500-word request might describe WHAT they want in detail but still lack:
- Success criteria (how will we test it?)
- Priority (which feature first?)
- Scope boundaries (what's included vs excluded?)

**When in doubt, ask at least ONE question about success criteria.**

## Question Types

Use these as inspiration, not a checklist. Pick what's relevant to the conversation.

### Motivation — Why this exists

- "What prompted this?"
- "What are you doing today that this replaces?"
- "What would you do if this existed?"
- "What's the problem you're trying to solve?"

### Concreteness — What it actually is

- "Walk me through using this"
- "You said X — what does that actually look like?"
- "Give me an example"
- "What would the user see/do?"

### Clarification — What they mean

- "When you say Z, do you mean A or B?"
- "You mentioned X — tell me more about that"
- "Which part specifically?"

### Success — How you'll know it's working

- "How will you know this is working?"
- "What does done look like?"
- "What should be different when this is complete?"

## Using AskUserQuestion

Use AskUserQuestion to help users think by presenting concrete options to react to.

**Good options:**
- Interpretations of what they might mean
- Specific examples to confirm or deny
- Concrete choices that reveal priorities
- 2-4 options (not too many)

**Bad options:**
- Generic categories ("Technical", "Business", "Other")
- Leading options that presume an answer
- Too many options (overwhelming)

**Always include an escape hatch:**
- "Let me explain" — for when none of the options fit

### Example: Vague Request

```
User: "make the dashboard faster"

AskUserQuestion:
- header: "Faster"
- question: "What's slow about the dashboard?"
- options:
  - "Initial load" — Takes too long to appear
  - "Data refresh" — Updates are laggy
  - "Interactions" — Clicking/scrolling feels slow
  - "Let me explain"
```

### Example: Following Up on Success Criteria

```
User: "Initial load"

AskUserQuestion:
- header: "Target"
- question: "How will you know it's fixed?"
- options:
  - "Under 2 seconds" — Specific measurable target
  - "Feels instant" — Subjective but noticeable improvement
  - "Match [competitor]" — Benchmark against something
  - "Let me explain"
```

### Example: Clarifying Scope

```
User: "fix the search"

AskUserQuestion:
- header: "Search"
- question: "Which part of search needs work?"
- options:
  - "Results quality" — Not finding the right things
  - "Speed" — Too slow to return results
  - "UI/UX" — Interface is confusing
  - "Let me explain"
```

## Anti-Patterns (What NOT to Do)

- **Checklist walking** — Going through question types regardless of what they said
- **Canned questions** — "What's your success criteria?" regardless of context
- **Interrogation** — Firing questions without building on answers
- **Rushing** — Minimizing questions to get to capture faster
- **Shallow acceptance** — Taking vague answers without probing
- **Over-questioning** — Asking 10 questions for a simple task
- **Technical probing** — Asking about implementation (that's for the builder)

## Workflow

### Step 1: Read and Understand

Read the user's input. Before doing anything:
- What are they trying to accomplish?
- Is it clear enough to capture?
- What's ambiguous or missing?

**Quick mental checklist:**
- [ ] What they want (concrete enough to explain to a stranger)
- [ ] Why it matters (the problem or desire driving it)
- [ ] What done looks like (observable outcome)

If gaps remain, ask questions. If clear, proceed to capture.

### Step 2: Question If Needed

If anything is unclear:
1. Pick the most important gap
2. Ask ONE focused question using AskUserQuestion
3. Build on their answer
4. Repeat until clear (usually 1-3 questions max)

**Follow the energy:** Whatever they emphasized, dig into that. What excited them? What problem sparked this?

**Know when to stop:** When you understand what they want, why they want it, and what done looks like — proceed to capture.

### Step 3: Check for Existing Requests

Before creating new files, check:
- `pp/` (pending queue)
- `pp/working/` (in progress)
- `pp/archive/` (completed)

**If similar request exists:**

| Location | Action |
|----------|--------|
| Queue | Ask: update existing or create new? |
| Working | Create addendum REQ (can't modify in-progress) |
| Archive | Create new REQ or addendum |

### Step 4: Assess Complexity

**Simple request** (1-2 features, <200 words, clear scope):
- Quick capture, lean format
- Minimal UR (just input.md with verbatim text)

**Complex request** (3+ features, >500 words, detailed requirements):
- Full UR folder with verbatim preservation
- Multiple REQ files with cross-references
- Batch constraints captured

### Step 5: Create Request Files

#### Folder Structure

```
pp/
├── REQ-001-task.md           # Queue (pending)
├── user-requests/
│   └── UR-001/
│       ├── input.md          # Verbatim input
│       └── assets/           # Screenshots, etc.
├── working/                   # In progress (immutable)
└── archive/                   # Completed (immutable)
```

#### Simple Request Format

```markdown
---
id: REQ-001
title: Brief descriptive title
status: pending
created_at: 2025-01-26T10:00:00Z
user_request: UR-001
test_url: https://example.com/dashboard
---

# [Brief Title]

## What
[1-3 sentences describing what is being requested]

## Why
[The problem this solves or value it provides — from questioning]

## Done When
[Observable outcome — how we'll know it's complete]
[These become Playwright test assertions]

## Context
[Any additional context, constraints, or details mentioned]

## Assets
[Screenshots or links to reference materials]

---
*Captured after [N] clarifying questions*
*Source: [original verbatim request]*
```

#### Complex Request Format

```markdown
---
id: REQ-005
title: OAuth login flow
status: pending
created_at: 2025-01-26T10:00:00Z
user_request: UR-001
related: [REQ-006, REQ-007]
batch: auth-system
test_url: https://example.com/login
---

# OAuth Login Flow

## What
[Clear description of the feature]

## Why
[Problem being solved — from motivation questions]

## Done When
[Success criteria — from success questions]
[These become Playwright test assertions]

## Detailed Requirements
[ALL requirements extracted — DO NOT SUMMARIZE]

- Requirement 1
- Requirement 2
- etc.

## Constraints
[Limitations or restrictions mentioned]

## Dependencies
[What this needs or what needs this]

## Open Questions
[Ambiguities the builder should clarify]

## Full Context
See [user-requests/UR-001/input.md](./user-requests/UR-001/input.md) for complete verbatim input.

---
*Captured after [N] clarifying questions*
```

### Step 6: Report Back

After creating files:
- List what was created
- Summarize what was captured (reflecting the clarified understanding)
- Keep it concise

```
Captured: Dashboard load time optimization

- Target: Under 2 seconds initial load
- Focus: Initial page render, not data refresh
- Created: REQ-008-dashboard-load-time.md

Ready to process? Run `/pp work`
```

## Examples

### Example 1: Simple but Vague → Clarified

```
User: /pp add make the app faster

Claude: [AskUserQuestion]
header: "Faster"
question: "What feels slow right now?"
options:
- "Page loads" — Initial load or navigation
- "Interactions" — Clicking, typing, scrolling
- "Data operations" — Saving, loading, syncing
- "Let me explain"

User: Page loads

Claude: [AskUserQuestion]
header: "Which pages"
question: "All pages or specific ones?"
options:
- "Dashboard" — The main dashboard
- "All pages" — General slowness everywhere
- "Specific pages" — Let me list them
- "Let me explain"

User: Dashboard

Claude: [AskUserQuestion]
header: "Target"
question: "How fast should it be?"
options:
- "Under 2 seconds" — Specific target
- "50% faster" — Relative improvement
- "Just noticeably better" — No specific number
- "Let me explain"

User: Under 2 seconds

Claude: Created REQ-012-dashboard-load-performance.md

Captured: Dashboard must load in under 2 seconds (currently slow on initial load).

Ready to process? Run `/pp work`
```

### Example 2: Already Clear → Direct Capture

```
User: /pp add add a logout button in the header that redirects to /login

Claude: Created REQ-013-logout-button.md

Captured: Logout button in header, redirects to /login.

Ready to process? Run `/pp work`
```

(No questions needed — request was specific and actionable)

### Example 3: Complex Multi-Feature

```
User: /pp add I need a complete notification system. Users should get notified
when someone comments on their post, when they get new followers, and
when their content is featured. They should be able to control which
notifications they receive. Also need email notifications for important
stuff, not just in-app.

Claude: [AskUserQuestion]
header: "Priority"
question: "Which notification type matters most?"
options:
- "Comments" — Engagement on their content
- "Followers" — Social growth
- "Featured" — Recognition/visibility
- "All equal"

User: Comments

Claude: [AskUserQuestion]
header: "Email"
question: "What counts as 'important' for email notifications?"
options:
- "All comments" — Every comment sends email
- "First comment only" — Just when discussion starts
- "User chooses" — Preference setting
- "Let me explain"

User: User chooses

Claude: This is a complex request. Creating full capture...

Created:
- pp/user-requests/UR-005/input.md (full verbatim)
- pp/REQ-020-notification-comments.md (priority: high)
- pp/REQ-021-notification-followers.md
- pp/REQ-022-notification-featured.md
- pp/REQ-023-notification-preferences.md
- pp/REQ-024-email-notifications.md

Captured: Notification system with comment/follower/featured alerts,
user-controlled preferences, and email for user-chosen events.
Comment notifications are highest priority.

Ready to process? Run `/pp work`
```

### Example 4: User Wants to Skip Questioning

```
User: /pp add add dark mode, just capture it don't ask questions

Claude: Created REQ-025-dark-mode.md

Captured as-is: "add dark mode"
(Builder will determine scope and implementation)

Ready to process? Run `/pp work`
```

## What NOT To Do

- Don't ask about implementation details (that's for the builder)
- Don't refuse to capture because it's "too vague" — ask questions first, then capture
- Don't ask more than 3-4 questions for a single task
- Don't use canned questions regardless of context
- Don't interrogate — this is collaborative
- Don't assume — when uncertain, ask
- Don't lose information — preserve verbatim input in UR
