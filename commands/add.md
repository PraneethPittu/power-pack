---
name: pp:add
description: Capture a new task with smart questioning
argument-hint: <task description>
---

<objective>
Capture a task with collaborative questioning to understand intent before creating the request. This action ONLY captures - it does NOT implement.
</objective>

<critical_rules>
**NEVER do any of the following during capture:**
- Write code
- Create project files
- Install dependencies
- Run commands (except mkdir for pp/ folder)
- Explore codebase for implementation
- Start building features

**ONLY do these during capture:**
- Ask clarifying questions
- Create `pp/REQ-*.md` files
- Create `pp/user-requests/UR-*/` folders
- Set up test config (if first time)
- Update `pp/STATE.md`

**After capture, tell the user:**
```
Captured: [task summary]

Ready to implement? Run /pp:work
```
</critical_rules>

<session_setup>
**On first /pp:add in a new session, ask THREE questions:**

**Question 1: Session Mode**
```
[AskUserQuestion]
header: "Session Mode"
question: "How will you be using this session?"
options:
- "Normal" — I'm here, ask me at decision points
- "Overnight" — Run autonomously, don't wait for input
```

**Question 2: Auto-Commit**
```
[AskUserQuestion]
header: "Auto-commit"
question: "Auto-commit changes after each task?"
options:
- "Yes" — Commit automatically after each completed task
- "No" — I'll commit manually when ready
```

**Question 3: Playwright Testing**
```
[AskUserQuestion]
header: "Auto-testing"
question: "Do you want automated Playwright tests?"
options:
- "Yes" — Generate and run Playwright tests for each task
- "No" — Skip automated testing, I'll test manually
```

**Store all three in pp/STATE.md.**
</session_setup>

<process>

<step name="step0_test_env">
## Step 0: Test Environment Setup (CRITICAL - Do First)

**If Playwright testing is enabled AND `pp/config/test-env.json` does NOT exist:**

```bash
cat pp/config/test-env.json 2>/dev/null || echo "NOT_FOUND"
```

If NOT_FOUND and Playwright enabled:

```
[AskUserQuestion]
header: "Test Config"
question: "I need test credentials for Playwright. Do you have a .env file?"
options:
- "Yes, I have .env" — I'll provide the path
- "No .env file" — I'll provide credentials directly
- "No login yet" — Skip for now (no auth system yet)
```

**If user has .env:** Ask for path, read it, extract credentials.

**If no .env:** Ask for:
- Login URL (e.g., https://example.com/login)
- Username
- Password
- Base URL

**Create config:**
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
  "createdAt": "[timestamp]"
}
```

Add to .gitignore:
```bash
echo "pp/config/test-env.json" >> .gitignore
```

**If "No login yet":** Create placeholder config with `"status": "pending"` and note tests will be skipped.
</step>

<step name="step1_understand">
## Step 1: Read and Understand

Read the user's input. Check:
- [ ] What they want (concrete enough to explain)
- [ ] Why it matters (the problem or desire)
- [ ] What done looks like (observable outcome)

If gaps remain, ask questions. If clear, proceed to capture.
</step>

<step name="step2_question">
## Step 2: Question If Needed

**ASK when:**
- Vague outcome: "make it better" → Better how?
- Unclear scope: "fix the search" → Which part?
- Missing context: "add a button" → Where?
- No success criteria: "make it faster" → How fast?

**DON'T ASK when:**
- Request is truly specific with clear success criteria
- User says "just capture it" or "figure it out"

Use AskUserQuestion with 2-4 concrete options plus "Let me explain".

**Usually 1-3 questions max.**
</step>

<step name="step3_check_existing">
## Step 3: Check for Existing Requests

```bash
ls pp/REQ-*.md pp/working/REQ-*.md pp/archive/*/REQ-*.md 2>/dev/null
```

If similar exists:
- In queue → Ask: update existing or create new?
- In working → Create addendum REQ
- In archive → Create new REQ
</step>

<step name="step4_complexity">
## Step 4: Assess Complexity

**Simple** (1-2 features, clear scope): Quick capture, lean format
**Complex** (3+ features, 500+ words): Full UR folder, multiple REQs
</step>

<step name="step5_create">
## Step 5: Create Request Files

```bash
mkdir -p pp/config pp/research pp/working pp/archive pp/user-requests tests/pp
```

**REQ Format:**
```markdown
---
id: REQ-001
title: Brief descriptive title
status: pending
created_at: [timestamp]
user_request: UR-001
test_url: [if known]
---

# [Brief Title]

## What
[1-3 sentences]

## Why
[Problem/value from questioning]

## Done When
[Observable outcomes - these become Playwright assertions]

## Context
[Additional details]

---
*Captured after [N] clarifying questions*
```

**Update STATE.md** with new task in queue.
</step>

<step name="step6_report">
## Step 6: Report Back

```
Captured: [task summary]

- [Key detail 1]
- [Key detail 2]
- Created: REQ-XXX-[slug].md

Ready to implement? Run /pp:work
```
</step>

</process>

<examples>

**Vague → Clarified:**
```
User: /pp:add make the app faster

Claude: [AskUserQuestion] What feels slow?
User: Page loads
Claude: [AskUserQuestion] Which pages?
User: Dashboard
Claude: [AskUserQuestion] How fast should it be?
User: Under 2 seconds

Claude: Created REQ-012-dashboard-performance.md
Captured: Dashboard must load in under 2 seconds.
Ready to implement? Run /pp:work
```

**Already Clear:**
```
User: /pp:add add logout button in header that redirects to /login

Claude: Created REQ-013-logout-button.md
Captured: Logout button in header, redirects to /login.
Ready to implement? Run /pp:work
```

**Skip Questions:**
```
User: /pp:add add dark mode, just capture it

Claude: Created REQ-025-dark-mode.md
Captured as-is: "add dark mode"
Ready to implement? Run /pp:work
```

</examples>

<anti_patterns>
- Don't ask about implementation details
- Don't refuse to capture "vague" requests - ask questions first
- Don't ask more than 3-4 questions
- Don't interrogate - collaborate
- Don't start implementing - wait for /pp:work
</anti_patterns>
