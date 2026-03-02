---
name: pp:add
description: Capture a new task with smart questioning
argument-hint: <task description>
---

<objective>
Capture a task with prompt rephrasing, collaborative questioning, and mandatory planning. This action ONLY captures - it does NOT implement.
</objective>

<enforcement>
## STRICT COMPLIANCE REQUIRED

**You MUST follow EVERY step below in EXACT order. DO NOT skip, reorder, or combine steps.**

**If you skip any step, the capture is INVALID and must be redone.**

**READ the full action file BEFORE doing anything:**
```bash
cat ~/.claude/skills/pp/actions/capture.md
```

**Follow the action file instructions step by step. The steps below are a summary — the action file has full details.**
</enforcement>

<critical_rules>
**NEVER do any of the following during capture:**
- Write code
- Create project files (except pp/ files)
- Install dependencies
- Explore codebase for implementation
- Start building features

**After capture, tell the user:**
```
Captured: [task summary]

Ready to implement? Run /pp:work
```

**DO NOT automatically start implementation. Wait for /pp:work.**
</critical_rules>

<session_setup>
## SESSION SETUP — MANDATORY, EVERY NEW SESSION

**CRITICAL: You MUST ask these FOUR questions on the FIRST /pp command in a new session.**
**NEVER skip these. NEVER assume answers from memory, MEMORY.md, STATE.md, or any saved file.**
**Each new Claude Code session starts FRESH — previous preferences are INVALID.**

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
- "Yes" — Generate and run Playwright tests (zero tolerance — functionality + UI screenshots)
- "No" — Skip automated testing, I'll test manually
```

**Question 4: Plan Verification**
```
[AskUserQuestion]
header: "Plan review"
question: "Do you want to review the implementation plan before I proceed?"
options:
- "Verify with me" — Show plan and ask for approval before proceeding
- "Continue directly" — Show plan but proceed automatically
```

**Store in memory for THIS session only. NEVER persist to MEMORY.md or auto-memory files.**
</session_setup>

<process>

<step name="step0_test_env">
## Step 0: Test Environment Setup

**If Playwright enabled AND `pp/config/test-env.json` doesn't exist:**
- Ask for test credentials (.env path or manual input)
- Create `pp/config/test-env.json`
- Add to `.gitignore`

**If exists or Playwright disabled:** Skip to Step 1.
</step>

<step name="step1_rephrase">
## Step 1: REPHRASE THE PROMPT (MANDATORY)

**DO NOT SKIP THIS STEP.**

```bash
mkdir -p pp/rephrased
```

Spawn a **general-purpose agent** to rephrase the user's raw prompt into an optimized, detailed prompt that will extract maximum quality output from Claude Code.

The agent should:
- Clearly state the objective
- Break down requirements into specific, concrete items
- Specify expected behavior and edge cases
- Include success criteria
- Use precise technical language
- NOT add fictional requirements — only expand and clarify
- NOT change the user's intent

**Save to** `pp/rephrased/REQ-XXX-rephrased.md`

**Show the rephrased prompt to the user.**

**Use the rephrased prompt (not the original) for all subsequent steps.**
</step>

<step name="step2_understand">
## Step 2: Read and Understand

Read the **rephrased prompt**. Check:
- [ ] What they want (concrete enough to explain)
- [ ] Why it matters (the problem or desire)
- [ ] What done looks like (observable outcome)

If gaps remain, ask questions.
</step>

<step name="step3_question">
## Step 3: Ask Clarifying Questions (MANDATORY — BOTH MODES)

**ALWAYS ask clarifying questions regardless of session mode (Normal or Overnight).**
**The ONLY exception: user explicitly says "just capture it" or "figure it out".**

1. Pick the most important gap
2. Ask ONE focused question using AskUserQuestion
3. Build on their answer
4. Repeat until clear (usually 1-3 questions max)

**ASK when:** Vague outcome, unclear scope, missing context, no success criteria
</step>

<step name="step4_check_existing">
## Step 4: Check for Existing Requests

```bash
ls pp/REQ-*.md pp/working/REQ-*.md pp/archive/*/REQ-*.md 2>/dev/null
```

If similar exists: Ask update or create new?
</step>

<step name="step5_complexity">
## Step 5: Assess Complexity

**Simple** (1-2 features, clear scope): Quick capture, lean format
**Complex** (3+ features, 500+ words): Full UR folder, multiple REQs
</step>

<step name="step6_plan">
## Step 6: PLAN THE TASK (Medium & Complex Only)

**Skip for simple tasks** (single-line fixes, small UI tweaks, typo fixes, color/text changes).
**Enter plan mode for medium/complex tasks** (multi-file changes, new features, architecture decisions).

Use complexity from Step 5 to decide:
- **Simple** → Skip plan, go straight to Step 7
- **Medium/Complex** → Plan mode required:

```bash
mkdir -p pp/plans
```

1. **Enter plan mode** using the EnterPlanMode tool
2. In plan mode: explore codebase, understand patterns, design implementation, identify files, consider edge cases
3. **Save plan** to `pp/plans/REQ-XXX-plan.md`
4. **Show plan to user** (always)
5. **If "Verify with me":** Ask for approval/changes before proceeding
6. **If "Continue directly":** Show plan and continue without waiting
</step>

<step name="step7_create">
## Step 7: Create Request Files

```bash
mkdir -p pp/config pp/research pp/working pp/archive pp/rephrased pp/plans pp/user-requests tests/pp
```

Create REQ file with:
- References to `pp/rephrased/REQ-XXX-rephrased.md`
- References to `pp/plans/REQ-XXX-plan.md`
- "Done When" criteria from questioning
- All context from rephrased prompt

Update STATE.md with new task in queue.
</step>

<step name="step8_report">
## Step 8: Report Back

```
Captured: [task summary]

- [Key detail 1]
- [Key detail 2]
- Rephrased: pp/rephrased/REQ-XXX-rephrased.md
- Plan: pp/plans/REQ-XXX-plan.md
- Created: REQ-XXX-[slug].md

Ready to implement? Run /pp:work
```
</step>

</process>

<anti_patterns>
## What NOT to Do
- Don't skip the rephrase step — EVERY task gets rephrased
- Don't skip questions — ALWAYS ask (both modes)
- Don't skip planning — EVERY task enters plan mode
- Don't skip showing rephrased prompt to user
- Don't skip showing plan to user
- Don't ask about implementation details
- Don't refuse to capture "vague" requests — ask questions first
- Don't ask more than 3-4 questions
- Don't start implementing — wait for /pp:work
- Don't persist session preferences to MEMORY.md
</anti_patterns>
