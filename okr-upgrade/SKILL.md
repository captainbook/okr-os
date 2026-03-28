---
name: okr-upgrade
version: 0.1.0
description: |
  Update okr-os to the latest version.
  Use when: "upgrade okr-os", "update okr skills", "get latest version",
  "okr-os update", "new version".
allowed-tools:
  - Read
  - Bash
  - AskUserQuestion
---

## Preamble

```bash
_SCRIPT_DIR=$(cd "$(dirname "$(readlink ~/.claude/skills/okr-os 2>/dev/null || echo ~/.claude/skills/okr-os)")" && pwd)
echo "INSTALL_DIR: $_SCRIPT_DIR"
_CURRENT_VERSION=$(cat "$_SCRIPT_DIR/VERSION" 2>/dev/null || echo "unknown")
echo "CURRENT_VERSION: $_CURRENT_VERSION"
_IS_GIT=$(cd "$_SCRIPT_DIR" && git rev-parse --is-inside-work-tree 2>/dev/null || echo "false")
echo "IS_GIT_INSTALL: $_IS_GIT"
```

## Workflow

### Step 1: Detect Installation Type

From preamble output:
- If `IS_GIT_INSTALL: true` — installed via `git clone`. Upgrade with `git pull`.
- If `IS_GIT_INSTALL: false` — installed manually (copied files). Cannot auto-upgrade.
  Tell user: "okr-os was installed manually (not via git clone). To upgrade,
  download the latest version and re-run ./setup"

### Step 2: Check for Updates

```bash
cd "$_SCRIPT_DIR" && git fetch origin main 2>/dev/null
_REMOTE_VERSION=$(cd "$_SCRIPT_DIR" && git show origin/main:VERSION 2>/dev/null || echo "unknown")
echo "REMOTE_VERSION: $_REMOTE_VERSION"
_LOCAL_CHANGES=$(cd "$_SCRIPT_DIR" && git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
echo "LOCAL_CHANGES: $_LOCAL_CHANGES"
```

If versions match: "You're already on the latest version (v$CURRENT_VERSION). No upgrade needed."

If local changes exist: warn via AskUserQuestion:
"You have local changes to okr-os files. Upgrading will overwrite them."
Options:
- A) Upgrade anyway (discard local changes)
- B) Cancel — I'll back up my changes first

### Step 3: Perform Upgrade

```bash
cd "$_SCRIPT_DIR" && git reset --hard origin/main
```

### Step 4: Re-run Setup

```bash
cd "$_SCRIPT_DIR" && ./setup
```

### Step 5: Show What Changed

```bash
cd "$_SCRIPT_DIR" && git log --oneline "$_CURRENT_VERSION"..HEAD 2>/dev/null | head -20
```

Read CHANGELOG.md and extract the section between the old and new version.
Present a summary: "Updated from v{old} to v{new}. Here's what changed:"

### Step 6: Clear Update Check Cache

```bash
rm -f ~/.okr-os/.update-snooze 2>/dev/null || true
```

## Security Note

This skill pulls code from a remote git repository and executes a setup script.
The setup script only creates symlinks and makes files executable. It does not
run arbitrary code beyond that.

Users should verify the remote URL points to the official okr-os repository:
```bash
cd "$_SCRIPT_DIR" && git remote get-url origin
```

## Voice

Brief and factual. State what version you're on, what's available, what changed.
No sales pitch for upgrading. Just the facts.
