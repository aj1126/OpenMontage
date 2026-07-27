# OpenMontage Customization & State Tracking Guide

This guide documents how local alterations to OpenMontage are tracked, saved, updated, and restored.

---

## 1. Local Tracking Branch

All custom alterations reside on the dedicated Git branch:
* **Branch Name**: `customizations`
* **Base Upstream**: `origin/main` (`https://github.com/calesthio/OpenMontage.git`)

---

## 2. Daily Workflow Cheat-Sheet

### **A. Saving New Alterations**
Whenever you make further changes or additions you want to preserve:
```bash
git add .
git commit -m "feat: description of changes"
```

### **B. Updating from the Upstream Repository**
To fetch updates from the upstream project (`calesthio/OpenMontage`) without losing your customizations:
```bash
# Fetch latest upstream commits
git fetch origin

# Apply your custom commits on top of the latest upstream main
git rebase origin/main
```
> **Note**: If conflicts occur during rebase, resolve the affected files, run `git add <file>`, and execute `git rebase --continue`.

### **C. Pushing to a Personal Remote Backup**
To push your customized branch to your own personal GitHub account:
```bash
# 1. Add your personal GitHub repository as a remote
git remote add my-fork https://github.com/<your-username>/OpenMontage.git

# 2. Push your customized branch and set tracking
git push -u my-fork customizations
```

### **D. Swapping Between Upstream Main and Custom Branch**
* Switch to stock main:
  ```bash
  git checkout main
  ```
* Switch back to custom branch:
  ```bash
  git checkout customizations
  ```

---

## 4. Codebase Memory & Graph UI

* **MCP Server**: `codebase-memory-mcp` (UI variant v0.9.0 installed)
* **Web UI Dashboard**: [http://localhost:9749](http://localhost:9749)
* **Index Command**: Run `index_repository` via MCP or agent tools to refresh code graph nodes and edges.
* **Architecture Record**: Stored in `manage_adr` within `codebase-memory-mcp`.
