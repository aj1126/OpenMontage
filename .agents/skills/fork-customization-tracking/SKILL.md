---
name: fork-customization-tracking
description: |
  Manage local alterations on top of an upstream GitHub clone. Use when tracking
  personal changes to a forked/cloned repository, syncing with upstream updates,
  or restoring/saving custom state. Triggers include: "save my changes", "track
  my alterations", "pull upstream updates", "restore my custom branch", or any
  git workflow for a cloned project with local modifications.
---

# Fork Customization Tracking

Use this skill when the project is a clone of an upstream repository and the
user has local modifications they want to track, save, and safely merge with
future upstream updates.

---

## Setup (One-Time)

Create a dedicated branch to hold all local alterations:

```bash
git checkout -b customizations
git add .
git commit -m "feat(customizations): initial local alterations"
```

Update `.gitignore` to exclude generated/environment-specific files before
committing (tool outputs, `.serena/`, `out/`, `narration.wav`, etc.).

---

## Daily Workflow

### Save New Changes
```bash
git add .
git commit -m "feat: describe your changes"
```

### Pull Upstream Updates (Without Losing Customizations)
```bash
git fetch origin
git rebase origin/main
```
> If conflicts occur: resolve affected files → `git add <file>` → `git rebase --continue`

### Switch Between Stock and Custom
```bash
git checkout main           # upstream stock version
git checkout customizations # your modified version
```

---

## Remote Backup (Optional)

Push your custom branch to a personal GitHub fork:

```bash
# Add your personal GitHub repo as a remote (one-time)
git remote add my-fork https://github.com/<your-username>/<repo-name>.git

# Push and track
git push -u my-fork customizations
```

---

## Verification Checklist

- [ ] `customizations` branch exists (`git branch`)
- [ ] Working tree is clean before switching branches (`git status`)
- [ ] `.gitignore` excludes all generated/env-specific files
- [ ] Rebase completes without unresolved conflicts
- [ ] `CUSTOM_WORKFLOW.md` exists and is up to date in the repo root

---

## Key Files in This Project

| File | Purpose |
|------|---------|
| [`CUSTOM_WORKFLOW.md`](../../CUSTOM_WORKFLOW.md) | Full cheat-sheet for this workflow |
| [`.agents/learning_proposal.md`](../learning_proposal.md) | Session learnings log |
