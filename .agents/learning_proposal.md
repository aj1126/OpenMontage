# Learning Proposal — Session 2026-07-27

Generated from this session's interactions via `/learn` + `/code-review-optimization-learning`.

---

## 1. Proposal Artifact Storage Location (NEW RULE)

### Classification
**Rule** — Universal behavioral guardrail for `/learn` and `/code-review-optimization-learning` workflows.

### What Was Observed
When the user approved `learning_proposal.md`, it was written only as an ephemeral brain artifact (`antigravity-cli/brain/<conversation-id>/`). The user then had to separately request the content be stored in project files.

The explicit correction: *"store the resulting content (proposal) in the project files"*

### Root Cause
The `/learn` mandatory workflow says "create a `learning_proposal.md` artifact" but does not specify that for project-specific learnings, the file should also be co-located in the project repository for permanent access.

### Proposed Rule
> When executing `/learn` or `/code-review-optimization-learning` in the context of a specific project workspace, **always write the `learning_proposal.md` into the project directory** (e.g. `.agents/learning_proposal.md`) in addition to the brain artifact. This ensures the proposal survives session resets and is version-controlled.

---

## 2. Documentation Permanence (UPDATE to code-review-optimization-learning skill)

### Classification
**Skill update** — Required Output Report Structure section.

### What Was Observed
The full workflow guide for git state tracking was surfaced as a chat response. The user explicitly requested: *"document your last response so I can access it again whenever I need in the future"* — indicating a preference for persistent project-level documentation over ephemeral chat answers.

### Proposed Addition to `code-review-optimization-learning` SKILL.md
Added to **§ 3. How to Create/Update a Custom Skill**:

> **Permanence Rule**: Any workflow guides, cheat-sheets, or procedural documentation surfaced as a chat response should be committed to the project repository as a markdown file (e.g. `CUSTOM_WORKFLOW.md`, `SETUP_GUIDE.md`). Do not leave operational knowledge as chat-only responses.

---

## 3. Fork Customization Tracking Pattern (NEW SKILL — project-level)

### Classification
**Skill** — New project-local skill at `.agents/skills/fork-customization-tracking/SKILL.md`

### Key workflow steps
- Create a `customizations` branch off upstream `main`
- Commit local alterations to that branch
- Use `git fetch origin && git rebase origin/main` to pull upstream without losing changes
- Optionally push to a personal GitHub fork for remote backup
- Use `.gitignore` to exclude tool-generated and environment-specific files

---

## 4. Python Module Fallback Pattern (ALREADY CAPTURED — verify coverage)

### Classification
Already captured in `.agents/skills/text-to-speech/SKILL.md`.

**Verification**: Confirm the pattern is referenced in any new Python tool skills via a tool authoring checklist.

---

## 🛠️ Changes Applied

| Action | File |
|--------|------|
| Created | `.agents/learning_proposal.md` (this file) |
| Created | `.agents/skills/fork-customization-tracking/SKILL.md` |
| Updated | Global `code-review-optimization-learning` SKILL.md |
