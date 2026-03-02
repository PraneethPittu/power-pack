# Changelog

All notable changes to Power-Pack (pp) will be documented in this file.

## [2.0.0] - 2026-03-02

### Added
- **Prompt Rephrasing** — Every task prompt is rephrased by an agent into an optimized, detailed prompt for maximum Claude Code output. Saved to `pp/rephrased/`
- **Mandatory Plan Mode** — Every task enters plan mode during capture to create a thorough implementation plan. Saved to `pp/plans/`
- **Plan Verification Option** — New 4th session question: choose to review plans before proceeding or auto-continue
- **Zero-Tolerance Testing** — Functionality tests must reach 100% pass. No skipping code-fixable failures
- **UI Screenshot Verification** — Takes screenshots during testing and reviews them for alignment, spacing, responsive, and visual issues. Loops until every screenshot is clean
- **Responsive Testing** — Automatic mobile (375px) and tablet (768px) viewport tests
- Auto-update check on session startup — notifies when a new version is available
- `VERSION` file for version tracking
- `CHANGELOG.md` for documenting changes
- New folders: `pp/rephrased/`, `pp/plans/`, `tests/pp/screenshots/`

### Changed
- Clarifying questions now asked in **both** Normal and Overnight modes (previously overnight could skip)
- Planning is now **mandatory for every task** (previously only complex tasks)
- Test loop no longer skips after max attempts for code-fixable failures — tries different approaches instead
- Work Step 6 now loads plan from capture phase instead of creating new plan

### How to update
```bash
cd ~/.claude/skills/pp && git pull origin main
```

---

## [1.1.0] - 2026-03-02

### Added
- Auto-update check on session startup — notifies when a new version is available
- `VERSION` file for version tracking
- `CHANGELOG.md` for documenting changes

### How to update
```bash
cd ~/.claude/skills/pp && git pull origin main
```

---

## [1.0.0] - 2026-02-16

### Initial Release
- Smart questioning with `/pp:add`
- 13-step work workflow with `/pp:work`
- Auto-research for unfamiliar tech
- Automated Playwright testing with fix-retry loop
- Session modes: Normal and Overnight
- State persistence and resume with `/pp:resume`
- Auto-commit option
- Test environment configuration
