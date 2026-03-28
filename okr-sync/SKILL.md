---
name: okr-sync
version: 0.1.0
description: |
  Format OKR outputs for Slack, email, or Attio CRM.
  Use when: "sync to slack", "format for email", "share okrs",
  "post to slack", "send status email", "update attio",
  "okr sync", "export okrs".
allowed-tools:
  - Read
  - Write
  - Glob
  - Bash
  - AskUserQuestion
  - mcp__663e8143-33b0-44a9-b4b0-4174988b9edb__upsert-record
  - mcp__663e8143-33b0-44a9-b4b0-4174988b9edb__search-records
  - mcp__663e8143-33b0-44a9-b4b0-4174988b9edb__list-attribute-definitions
---

## Preamble

```bash
_UPD=$(~/.claude/skills/okr-os/bin/okr-update-check 2>/dev/null || true)
[ -n "$_UPD" ] && echo "$_UPD" || true
_STATE=$(~/.claude/skills/okr-os/bin/okr-state 2>/dev/null || true)
echo "$_STATE"
```

## Prerequisites

Requires recent weekly files in .okr/quarters/. If no recent monday.md, friday.md,
or status.md exists: "Run /monday, /friday, or /okr-status first to generate output."

## Usage

The user invokes with a target:
- `/okr-sync slack` — Format last monday or friday output for Slack
- `/okr-sync email` — Format last status email for copy-paste into email client
- `/okr-sync attio` — Push OKR data to Attio CRM (if MCP connected)

If no target specified, ask via AskUserQuestion:
"What do you want to sync?"
Options: A) Slack  B) Email  C) Attio

## Slack Format

Read the most recent monday.md or friday.md. Strip box-drawing characters.
Reformat using Slack-native markdown:

```
*MONDAY COMMITMENTS — Week N/13*
Health Score: XX/100

*OBJECTIVE:* <text>

KR1: <desc> → `N/10` <trend>
KR2: <desc> → `N/10` ⚠️ dropping
KR3: <desc> → `N/10` ✅ on track

*This week:*
• P1 priority
• P1 priority
• P1 priority

*Health:* 🟢 metric  🟡 metric  🟢 metric

> ⚠️ Coaching prompt (if confidence dropped)
```

For Friday wins:
```
*🏆 FRIDAY WINS — Week N*

*Engineering*
• Win (KR tag)

*Sales*
• Win (KR tag)

*🍎 Golden apples resisted:*
• Distraction avoided

*Exit ticket:*
Keep: ...  Change: ...  Note: ...
```

Print the formatted output to terminal. Tell the user: "Copy the output above
and paste it into your Slack channel."

## Email Format

Read the most recent status.md (from /okr-status). If none exists, read the
most recent monday.md and format it as a status email.

The email format is already designed for plain-text email (no box-drawing, 72-char
width, dot-leaders). Print it with the subject line at top:

```
Subject: [OKR Status] Week N/13 — Health: XX/100
```

Tell the user: "Copy everything above (including the Subject line) and paste
it into your email client."

## Attio Format

Check if Attio MCP tools are available. If not:
"Attio MCP is not connected. To set it up, add the Attio MCP server to your
Claude Code configuration. For now, here's the data in a format you can
enter manually."

If Attio MCP IS available:

1. Read current OKR state
2. Use AskUserQuestion: "I'll create/update a record in Attio with your OKR data.
   Which object should I use?"
   Options:
   - A) Create a 'Quarterly OKR' custom object (first time setup)
   - B) Update an existing record (specify which)
   - C) Skip — just show me the data

3. If A: Use upsert-record to create/update with fields:
   - Name: "Q{N} {YEAR} OKR"
   - Fields: objective, kr1_description, kr1_confidence, kr2_*, kr3_*, health_score, week
4. If B: Search for existing record, then update
5. If C: Print the data as key-value pairs

## Design Conventions

- Terminal output: uses box-drawing and emoji (full visual language)
- Slack output: uses Slack markdown (*bold*, `code`, •bullets, >blockquotes)
- Email output: plain text, 72-char width, dot-leaders, no emoji except ⚠️
- All formats: same information hierarchy (Objective first, KRs second, priorities third)

## Voice

Utilitarian. This skill is a formatter, not a coach. Brief, direct output.
No coaching prompts in sync output. The coaching lives in /monday and /friday.
