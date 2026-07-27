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
committing. Recommended patterns for media/tool-output projects:

```gitignore
# Generated test/pipeline media (root-level — regenerable)
test_*.mp4
final_video.mp4
test.wav

# Temp script text dumps at repo root
*.ps1.txt

# Tool environment dirs
.serena/
out/
narration.wav
```

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

## Remote Backup

> ⚠️ **First-push always fails on a clone**: `git push` targets `origin`
> (the upstream repo — read-only). Always use `git push -u my-fork <branch>`
> for your customizations branch. Once set, future `git push` calls work
> normally because the branch tracks `my-fork`.

Push your custom branch to a personal GitHub fork:

```bash
# Add your personal GitHub repo as a remote (one-time)
git remote add my-fork https://github.com/<your-username>/<repo-name>.git

# Push and set upstream tracking
git push -u my-fork customizations
```

If `git push` returns a 403 error like:
```
Permission to <org>/<repo> denied to <username>
```
Your `<username>` is visible in that error. Use it to construct the fork URL
and add the remote as above.

---

## Verification Checklist

- [ ] `customizations` branch exists (`git branch`)
- [ ] `my-fork` remote is configured (`git remote -v`)
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
