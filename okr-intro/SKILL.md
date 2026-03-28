---
name: okr-intro
version: 0.1.0
description: |
  Generate a one-pager for new team members joining mid-quarter.
  Use when: "onboard new hire", "okr intro", "new team member",
  "explain our okrs", "what are we working on", "alignment doc".
allowed-tools:
  - Read
  - Write
  - Glob
  - Bash
  - AskUserQuestion
---

## Preamble

```bash
_UPD=$(~/.claude/skills/okr-os/bin/okr-update-check 2>/dev/null || true)
[ -n "$_UPD" ] && echo "$_UPD" || true
_STATE=$(~/.claude/skills/okr-os/bin/okr-state 2>/dev/null || true)
echo "$_STATE"
```

If `UPGRADE_AVAILABLE`, tell user. If okr-state exits non-zero, tell user what's missing.

## Prerequisites

Requires OKR-CONTEXT.md AND current quarter objective.md.
If either missing: "Run /okr-setup and /okr-set first to create your OKR context."

## Workflow

### Step 1: Gather State

Read from bin/okr-state output:
- OBJECTIVE, KR1-3 with confidence, HEALTH metrics, QUARTER, WEEK, PHASE

Read from OKR-CONTEXT.md:
- Mission, strategy

Read from latest monday.md:
- This week's P1 priorities

Read from latest friday.md (if exists):
- Recent wins (for context on momentum)

### Step 2: Generate One-Pager

Produce the onboarding document in terminal output:

```
┌─────────────────────────────────────────────────────────────┐
│  WELCOME TO THE TEAM                                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  OUR MISSION                                                 │
│  <mission from OKR-CONTEXT.md>                               │
│                                                              │
│  THIS QUARTER (<quarter> <year>)                             │
│                                                              │
│  OBJECTIVE: <objective text>                                 │
│                                                              │
│  How we know we succeeded:                                   │
│  1. <KR1 description> (currently <actual or confidence>)     │
│  2. <KR2 description> (currently <actual or confidence>)     │
│  3. <KR3 description> (currently <actual or confidence>)     │
│                                                              │
│  WHERE WE STAND (Week <N>)                                   │
│  · <KR1 status summary in plain English>                     │
│  · <KR2 status summary>                                      │
│  · <KR3 status summary>                                      │
│                                                              │
│  OUR CADENCE                                                 │
│  Monday: Commitments    Friday: Wins    Weekly: Status email │
│                                                              │
│  THIS WEEK'S FOCUS                                           │
│  <P1 priorities from latest monday.md>                       │
│                                                              │
│  HEALTH METRICS WE PROTECT                                   │
│  <emoji> <metric name>  (repeat for each)                    │
└─────────────────────────────────────────────────────────────┘
```

### Step 3: Offer to Save

Ask via AskUserQuestion:
"Here's the onboarding one-pager. Want me to save it as a file you can share?"

Options:
- A) Save to .okr/onboarding.md (overwrite each time, always current)
- B) Just display it (don't save)

If saved, write to `.okr/onboarding.md` as plain markdown (no box-drawing, so it renders
well when shared via Slack or email).

### Step 4: Sharing Tips

Tell the user:
"Share this with your new hire on their first day. It gives them full context
in 5 minutes. Update it anytime by running /okr-intro again.

For Slack-formatted version, run: /okr-sync slack"

## Voice

Warm and welcoming. This document represents the team to a new person.
Write in plain language, no jargon. Make the new hire feel like they're
joining something with clear direction and momentum.

## Golden Apple Awareness

If the preamble shows an active objective, include the Golden Apple concept
in the one-pager under a section:

```
│  HOW WE STAY FOCUSED                                        │
│  We resist "golden apples" — shiny opportunities that        │
│  don't advance our Objective. If something new comes up,     │
│  we ask: "Does this directly advance our goal?"              │
```
