---
name: okr-status
version: 0.1.0
description: |
  Generate the weekly OKR status email — Zynga-style from Radical Focus.
  Triggers: "status email", "weekly status", "okr update email", "write status"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Bash
  - AskUserQuestion
---

# Weekly OKR Status Email

You generate a plain-text status email the CEO can copy-paste and send.
The format is inspired by the Zynga weekly status emails described in
Christina Wodtke's *Radical Focus*: compact, scannable, no fluff.

---

## Preamble — gather state

Before any interaction, silently run these three commands and absorb
their output. Do NOT print the raw output to the user.

```bash
bin/okr-update-check   # check for okr-os updates
bin/okr-quarter-info   # quarter name, week number, phase
bin/okr-state           # current objective, KRs, confidence, health
```

If `UPGRADE_AVAILABLE` is printed, tell the user: "A newer version of
okr-os is available. Run /okr-upgrade to update."

From `bin/okr-quarter-info` capture:
- `QUARTER` (e.g. Q2-2026)
- `WEEK` (1-13)
- `PHASE` (early, mid, late, final)
- `YEAR`

From `bin/okr-state` capture:
- `OBJECTIVE` text
- Each `KR{n}` with description, confidence score, and target
- `HEALTH` metric statuses
- `CODE_RED` status
- `LAST_MONDAY` filepath
- `LAST_FRIDAY` filepath

If `bin/okr-state` exits with code 1 (no objective set), print:

> **No active OKR set.** Run `/okr-set` first.

Then stop.

---

## Locate this week's monday.md

Find the current week's Monday file at:

```
.okr/quarters/{QUARTER}/weekly/{YYYY-MM-DD}-monday.md
```

where `{YYYY-MM-DD}` is the most recent Monday (today if Monday, else
the preceding Monday).

**If no monday.md exists for this week, stop and tell the user:**

> "Run /monday first. The status email pulls from this week's Monday
> Commitment Meeting data."

This is a hard requirement. The status email is generated FROM the
Monday meeting, not as a replacement for it.

---

## Load data files

### This week's monday.md

Parse the YAML frontmatter to extract:
- `priorities` — this week's P1 commitments (with `kr_connection`)
- `confidence` — `kr1`, `kr2`, `kr3` scores (1-10)
- `last_week_results` — each item with `status` (done/not_done) and
  optional `reason`
- `health_metrics` — each with `name` and `status` (green/yellow/red)
- `health_score` — composite score (0-100)
- `code_red` — boolean

### Last week's monday.md

If a previous monday.md exists (the file before this week's), parse
its `confidence` block to get the prior week's KR scores. These become
the "was N" values for week-over-week comparison.

If no prior week exists (first week of quarter), omit the "was N"
notation and skip the LAST WEEK section.

### objective.md

Read `.okr/quarters/{QUARTER}/objective.md` for the full KR
descriptions and targets (the `key_results` array in frontmatter).

---

## Compute health score

Run:

```bash
bin/okr-health-score --quarter {QUARTER}
```

Capture the `score` value from the JSON output. If the command fails
(insufficient data), fall back to computing a simple score from health
metrics: green=100, yellow=50, red=0, averaged.

---

## Ask the CEO for additional input

Use `AskUserQuestion` for two pieces the data files do not contain:

### Risks & Blockers

Ask:
> "Any risks or blockers to flag in the status email? These should be
> things stakeholders need to know about — resource constraints,
> external dependencies, decisions needed. Type 'none' if all clear."

### Notes

Ask:
> "Any additional notes for the status email? Team wins, context for
> stakeholders, upcoming changes. Type 'none' to skip."

---

## Generate the status email

Build a plain-text email following these design conventions:

- **72-character max line width** — ensures email wrapping works
- **Dot-leaders** between KR description and score for scannability
- **"was N"** shows week-over-week confidence change
- **Warning emoji** only on KRs where confidence DROPPED 2+ points
- **Numbered priorities** — signals rank order
- **No box-drawing characters** — plain text only, email-safe
- **Horizontal rule** uses a plain dash line under the objective

### Formatting rules

**Subject line:**
```
[OKR Status] Week {N}/13 -- Health: {score}/100
```

**KR lines:**
Each KR line must fit 72 chars. Use dot-leaders between the
description and the score. Format:

```
KR{n}: {desc} ........... {score}/10 (was {prev}) -> {actual}
```

- Truncate `{desc}` if needed to fit within 72 chars
- If confidence DROPPED 2+ points from last week, append a warning
  flag: `DROPPING` with a warning emoji
- If no prior week data, omit `(was {prev})`
- `{actual}` is a brief current-state note if available from the
  monday.md, otherwise omit the arrow and actual

**Last week results:**
```
LAST WEEK
  {mark} {item text}
```

- Use a checkmark character for done items
- Use an X character for not_done items, followed by a dash and the
  brief reason

**This week priorities:**
```
THIS WEEK (P1s)
  1. {priority text} ({KR tag})
  2. {priority text} ({KR tag})
  3. {priority text} ({KR tag})
```

- Number each priority
- Include the KR connection tag in parentheses

**Risks & Blockers:**
```
RISKS & BLOCKERS
  . {risk description}
```

If none, omit this section entirely.

**Notes:**
```
NOTES
  . {note text}
```

If none, omit this section entirely.

### Full template

```
Subject: [OKR Status] Week {N}/13 -- Health: {score}/100

OBJECTIVE: {objective text}
----------------------------------------------

KR1: {desc} ........... {n}/10 (was {prev})
KR2: {desc} ........... {n}/10 (was {prev}) DROPPING
KR3: {desc} ........... {n}/10 (was {prev})

LAST WEEK
  {checkmark} done item
  {x} not done item -- brief reason

THIS WEEK (P1s)
  1. priority (KR1)
  2. priority (KR2)
  3. priority (KR3)

RISKS & BLOCKERS
  . risk description

NOTES
  . note
```

### Line-width enforcement

After generating the email, verify every line is at most 72 characters.
If any line exceeds 72 chars, wrap it intelligently:
- KR lines: truncate the description, keep the score
- Priority lines: wrap with 5-space indent on continuation
- Other lines: wrap at word boundaries with 4-space indent

---

## Save the status email

Write the generated email to:

```
.okr/quarters/{QUARTER}/weekly/{YYYY-MM-DD}-status.md
```

where `{YYYY-MM-DD}` is today's date.

Create the directory if it does not exist:

```bash
mkdir -p .okr/quarters/{QUARTER}/weekly
```

The file should contain the full email text as-is (no additional
frontmatter — it is a copy-paste artifact, not a data file).

---

## Print to terminal

After saving, print the full email to the terminal so the CEO can
copy-paste it directly. Introduce it with:

> "Status email saved and ready to send:"

Then print the email text verbatim.

---

## Edge cases

- **First week of quarter**: No "was" values, no LAST WEEK section.
  The email is shorter and that is fine.
- **Code Red active**: Add a prominent line after the objective:
  ```
  *** CODE RED: {metric} -- OKR work paused ***
  ```
- **All KRs above 8**: Add a note after KR lines:
  ```
  (All KRs high-confidence -- are targets ambitious enough?)
  ```
- **Multiple KRs dropping**: If 2+ KRs dropped 2+ points, add:
  ```
  ** Multiple KRs declining -- consider reprioritizing **
  ```
