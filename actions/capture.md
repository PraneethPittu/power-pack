# Capture Action

> **Part of the power-pack skill.** Captures tasks with collaborative questioning — understand intent before creating requests.

## CRITICAL: Capture Does NOT Implement

**This action ONLY captures tasks. It does NOT implement them.**

**NEVER do any of the following during capture:**
- Write code
- Create project files (except pp/ files)
- Install dependencies
- Run commands (except mkdir for pp/ folder)
- Start building features

**ONLY do these during capture:**
- Rephrase the user's prompt (using an agent)
- Ask clarifying questions
- Enter plan mode and create a plan
- Create `pp/REQ-*.md` files
- Create `pp/rephrased/` and `pp/plans/` files
- Create `pp/user-requests/UR-*/` folders
- Set up test config (if first time)
- Update `pp/STATE.md`

**After capture is complete, tell the user:**
```
Captured: [task summary]

Ready to implement? Run `/pp work`
```

**DO NOT automatically start implementation. Wait for `/pp work`.**

---

## MANDATORY CAPTURE CHECKLIST

**Before capturing ANY task, complete this checklist in order:**

- [ ] **Step 0:** If Playwright testing is enabled AND `pp/config/test-env.json` doesn't exist → Ask for test credentials FIRST
- [ ] **Step 1:** Rephrase the user's prompt into an optimized, detailed prompt using an agent
- [ ] **Step 2:** Show rephrased prompt to user and save to `pp/rephrased/`
- [ ] **Step 3:** Ask clarifying questions (ALWAYS — both Normal and Overnight modes)
- [ ] **Step 4:** Check for existing similar requests
- [ ] **Step 5:** Assess complexity (simple vs complex)
- [ ] **Step 6:** Enter plan mode — create a detailed plan for the task (EVERY task, no exceptions)
- [ ] **Step 7:** Save plan to `pp/plans/` and show to user (verify or auto-continue based on session preference)
- [ ] **Step 8:** Create REQ file(s) with rephrased prompt + plan references, update STATE.md

**DO NOT SKIP any step.** Every step is mandatory for every task.

---

## IMPORTANT: ALWAYS Ask Questions — Both Modes

**Clarifying questions are MANDATORY in BOTH Normal and Overnight modes.**

During capture, **ALWAYS ask clarifying questions** regardless of session mode, unless:
- User explicitly says "just capture it" or "figure it out"

Even detailed/long requests (500+ words) still need questions about:
- Success criteria: "How will you know it's working?"
- Priority: "Which part matters most?"
- Scope boundaries: "Should this include X or just Y?"

**The length of a request does NOT equal clarity.**

**Overnight mode only affects the WORK phase** (auto-selects at checkpoints during implementation). Capture behavior is identical in both modes.

---

## Test Environment (Once Per Session)

**First, check session preference:** If user selected "No" for Playwright testing during session setup, skip this entire section and proceed directly to capture.

---

**If Playwright testing is enabled**, check if `pp/config/test-env.json` exists:

```bash
cat pp/config/test-env.json 2>/dev/null
```

### If Config EXISTS → Use It (Don't Ask Again)

Simply proceed to capture. The existing config will be used for all tasks.

**Optionally mention:** "Using saved test environment. Say 'change test config' if you need different credentials for this task."

### If Config DOESN'T EXIST → Ask Once

```
[AskUserQuestion]
header: "Test Config"
question: "I need test environment details for automated testing. Do you have a .env file with credentials?"
options:
- "Yes, I have .env" — I'll provide the path
- "No .env file" — I'll provide credentials directly
- "No login yet" — Skip for now, I'll set it up later or need Claude to create auth first
```

**If user selects "No login yet":**
- Skip test environment setup for now
- Create a placeholder config:
```json
{
  "status": "pending",
  "reason": "No auth system yet",
  "createdAt": "2026-02-03T10:00:00Z"
}
```
- Note in the REQ file: "Test environment not configured - manual testing required or set up auth first"
- During `/pp work`, skip Playwright test generation and show reminder: "No test credentials configured. Run `/pp add set up authentication` first or say 'change test config' to add credentials."

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

### User Wants to Change Config for a Task

If user says "change test config", "different credentials", "use different env", etc.:

```
[AskUserQuestion]
header: "Config Change"
question: "How do you want to update the test config?"
options:
- "Update for this task only" — Temporary override, won't save
- "Update permanently" — Replace saved config
- "Never mind" — Keep using existing config
```

**If "this task only":** Store override in REQ file's frontmatter:
```yaml
test_override:
  loginUrl: "https://staging.example.com/login"
  username: "staging_user"
```

**If "permanently":** Update `pp/config/test-env.json` with new values.

### Per-Task Test URL (Optional)

During capture, you may ask which page to test if it's not obvious from the request:

```
[AskUserQuestion]
header: "Test URL"
question: "What page should we test this feature on?"
options:
- "Dashboard" — [baseUrl]/dashboard
- "Settings" — [baseUrl]/settings
- "Let me specify" — Different URL
- "Figure it out" — Decide during implementation
```

Store in REQ file's `test_url` frontmatter. If not specified, the work phase will determine it.

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

### Step 0: Test Environment Setup (CRITICAL - Do First)

**If Playwright testing is enabled for this session AND `pp/config/test-env.json` does NOT exist, you MUST set up test credentials BEFORE capturing the task.**

```bash
# Check if config exists
cat pp/config/test-env.json 2>/dev/null
```

**If the file does NOT exist and Playwright is enabled:**
1. Go back to the "Test Environment (Once Per Session)" section above
2. Ask the user for .env file path OR manual credentials
3. Create `pp/config/test-env.json`
4. Add to `.gitignore`
5. THEN proceed to Step 1

**If the file exists OR Playwright is disabled:** Proceed directly to Step 1.

---

### Step 1: Rephrase the Prompt (MANDATORY)

**CRITICAL: Before anything else, rephrase the user's raw prompt into an optimized, detailed prompt that will extract maximum output from Claude Code.**

1. **Create rephrased folder:**
```bash
mkdir -p pp/rephrased
```

2. **Spawn a general-purpose agent** to rephrase:

```
Agent(prompt="
You are an expert prompt engineer. Your job is to take a user's raw task description and rephrase it into the BEST possible prompt that would extract maximum quality output from Claude Code (an AI coding assistant).

## Raw User Prompt:
[paste user's exact input here]

## Your Task:
Rephrase this into a detailed, actionable, well-structured prompt that:
- Clearly states the objective
- Breaks down what needs to be done into specific, concrete requirements
- Specifies expected behavior and edge cases
- Includes success criteria (what 'done' looks like)
- Mentions quality standards (accessibility, responsiveness, error handling)
- Uses precise technical language where appropriate
- Is structured with clear sections (Objective, Requirements, Expected Behavior, Success Criteria)

## Rules:
- Do NOT add fictional requirements — only expand and clarify what the user intended
- Do NOT change the user's intent — enhance the clarity and detail
- Keep the scope the same — don't inflate the task
- Make it actionable for an AI coding assistant
- Use markdown formatting for readability

Return ONLY the rephrased prompt, nothing else.
", subagent_type="general-purpose")
```

3. **Save the rephrased prompt** to `pp/rephrased/REQ-XXX-rephrased.md`:

```markdown
---
id: REQ-XXX
original_prompt: "[user's raw input]"
rephrased_at: [timestamp]
---

# Rephrased Prompt: [Brief Title]

[Rephrased prompt from agent]

---
*Original: "[user's raw input]"*
*Rephrased by prompt engineering agent*
```

4. **Show the rephrased prompt to the user:**

```
Rephrased your task for maximum effectiveness:

[Show the rephrased prompt]

Proceeding with this enhanced prompt for capture...
```

**Now use the rephrased prompt (not the original) for all subsequent steps.**

---

### Step 2: Read and Understand (Using Rephrased Prompt)

Read the **rephrased prompt**. Before doing anything:
- What are they trying to accomplish?
- Is it clear enough to capture?
- What's still ambiguous or missing even after rephrasing?

**Quick mental checklist:**
- [ ] What they want (concrete enough to explain to a stranger)
- [ ] Why it matters (the problem or desire driving it)
- [ ] What done looks like (observable outcome)

If gaps remain, ask questions. If clear, proceed to capture.

### Step 3: Question (ALWAYS — Both Modes)

**ALWAYS ask clarifying questions regardless of session mode (Normal or Overnight).**

The only exception: user explicitly says "just capture it" or "figure it out".

1. Pick the most important gap
2. Ask ONE focused question using AskUserQuestion
3. Build on their answer
4. Repeat until clear (usually 1-3 questions max)

**Follow the energy:** Whatever they emphasized, dig into that. What excited them? What problem sparked this?

**Know when to stop:** When you understand what they want, why they want it, and what done looks like — proceed.

### Step 4: Check for Existing Requests

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

### Step 5: Assess Complexity

**Simple request** (1-2 features, <200 words, clear scope):
- Quick capture, lean format
- Minimal UR (just input.md with verbatim text)

**Complex request** (3+ features, >500 words, detailed requirements):
- Full UR folder with verbatim preservation
- Multiple REQ files with cross-references
- Batch constraints captured

### Step 6: Plan the Task (Medium & Complex Tasks Only)

**Skip this step for simple tasks** (single-line fixes, small UI tweaks, typo fixes, color changes, text changes).

**Enter plan mode for medium and complex tasks** (multi-file changes, new features, architecture decisions, integrations).

This step uses Claude Code's plan mode to create a detailed implementation plan for the task. Plan mode is the best way to think through implementation before writing code.

1. **Create plans folder:**
```bash
mkdir -p pp/plans
```

2. **Enter plan mode** using the EnterPlanMode tool. In plan mode:
   - Explore the codebase thoroughly (use Glob, Grep, Read)
   - Understand existing patterns and architecture
   - Design the implementation approach
   - Identify files to create/modify
   - Consider edge cases and potential issues
   - Create a step-by-step implementation plan

3. **After planning, save the plan** to `pp/plans/REQ-XXX-plan.md`:

```markdown
---
id: REQ-XXX
title: [Brief Title]
planned_at: [timestamp]
files_to_modify: [list of files]
estimated_complexity: simple | moderate | complex
---

# Implementation Plan: [Title]

## Objective
[What this plan achieves]

## Codebase Analysis
[Key findings from exploring the codebase]

## Implementation Steps
1. [Step 1 — specific file + what to change]
2. [Step 2 — specific file + what to change]
3. ...

## Files to Create/Modify
| File | Action | Description |
|------|--------|-------------|
| path/to/file.js | modify | Add logout handler |
| path/to/new.js | create | New component |

## Edge Cases & Considerations
- [Edge case 1]
- [Edge case 2]

## Testing Strategy
- [What to test]
- [Expected assertions]

---
*Generated in plan mode*
```

4. **Check session preference for plan verification:**

   **If user selected "Verify plan with me" during session setup:**
   - Display the full plan to the user
   - Ask:
   ```
   [AskUserQuestion]
   header: "Plan Review"
   question: "Does this plan look good, or do you want to add/change anything?"
   options:
   - "Looks good, proceed" — Continue with this plan
   - "I have changes" — Let me suggest modifications
   - "Redo the plan" — Start planning from scratch
   ```
   - If user has changes: incorporate them, update the plan file, show again
   - If redo: re-enter plan mode

   **If user selected "Continue directly" during session setup:**
   - Display the plan to the user (always show it)
   - Continue without waiting for confirmation

5. **Link the plan in the REQ file** (in Step 8)

---

### Step 7: Create Request Files

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
rephrased_prompt: pp/rephrased/REQ-001-rephrased.md
plan: pp/plans/REQ-001-plan.md
test_url: https://example.com/dashboard
---

# [Brief Title]

## What
[1-3 sentences describing what is being requested — from rephrased prompt]

## Why
[The problem this solves or value it provides — from questioning]

## Done When
[Observable outcome — how we'll know it's complete]
[These become Playwright test assertions]

## Context
[Any additional context, constraints, or details mentioned]

## Rephrased Prompt
See [pp/rephrased/REQ-001-rephrased.md] for the enhanced prompt.

## Implementation Plan
See [pp/plans/REQ-001-plan.md] for the detailed plan.

## Assets
[Screenshots or links to reference materials]

---
*Captured after [N] clarifying questions*
*Rephrased prompt: pp/rephrased/REQ-001-rephrased.md*
*Plan: pp/plans/REQ-001-plan.md*
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
rephrased_prompt: pp/rephrased/REQ-005-rephrased.md
plan: pp/plans/REQ-005-plan.md
related: [REQ-006, REQ-007]
batch: auth-system
test_url: https://example.com/login
---

# OAuth Login Flow

## What
[Clear description of the feature — from rephrased prompt]

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

## Rephrased Prompt
See [pp/rephrased/REQ-005-rephrased.md] for the enhanced prompt.

## Implementation Plan
See [pp/plans/REQ-005-plan.md] for the detailed plan.

## Full Context
See [user-requests/UR-001/input.md](./user-requests/UR-001/input.md) for complete verbatim input.

---
*Captured after [N] clarifying questions*
*Rephrased prompt: pp/rephrased/REQ-005-rephrased.md*
*Plan: pp/plans/REQ-005-plan.md*
```

### Step 8: Create Request Files and Report Back

Create the REQ file(s) using the formats above, with references to the rephrased prompt and plan files.

After creating files:
- List what was created (REQ, rephrased prompt, plan)
- Summarize what was captured (reflecting the clarified understanding)
- Keep it concise

```
Captured: Dashboard load time optimization

- Target: Under 2 seconds initial load
- Focus: Initial page render, not data refresh
- Rephrased: pp/rephrased/REQ-008-rephrased.md
- Plan: pp/plans/REQ-008-plan.md
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
