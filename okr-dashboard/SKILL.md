---
name: okr-dashboard
version: 0.1.0
triggers:
  - "okr dashboard"
  - "show me our okrs"
  - "how are we doing"
  - "okr overview"
  - "confidence trends"
allowed-tools:
  - Read
  - Glob
  - Bash
  - AskUserQuestion
---

# OKR Dashboard — ASCII Visualization

Read-only skill that renders a compact ASCII dashboard showing OKR status, confidence sparklines, health metrics, and cadence adherence.

## Preamble

Before rendering, run these setup checks:

```bash
bin/okr-update-check
bin/okr-quarter-info
bin/okr-state
bin/okr-health-score
```

This skill requires at least 2 weeks of weekly check-in data to render trends. If fewer than 2 monday.md files exist for the current quarter, stop and report:

> Need 2+ weeks to show trends. Come back after your second Monday check-in.

## Workflow

1. **Read current OKR state** — run `bin/okr-state` to get the current objective, key results, targets, and actuals.
2. **Build confidence history** — read all `monday.md` files in the current quarter directory. Extract the confidence rating (1-10) for each KR from each week.
3. **Compute health score** — run `bin/okr-health-score` to get the overall health score (0-100) and individual health metrics.
4. **Build sparklines** — for each KR, map the weekly confidence values to block characters to form a sparkline string.
5. **Determine trend direction** — for each KR, compare the last 2 weeks of confidence data to classify the trend.
6. **Render the ASCII dashboard** — assemble everything into the fixed-width box-drawing format below.

## Sparkline Building

Map confidence values (1-10) to Unicode block characters. One block per week of data.

| Confidence | Block |
|------------|-------|
| 1-2        | ▁     |
| 3          | ▂     |
| 4          | ▃     |
| 5          | ▄     |
| 6          | ▅     |
| 7          | ▆     |
| 8          | ▇     |
| 9-10       | █     |

Example: confidences `[2, 3, 4, 5, 6, 6, 6]` renders as `▁▂▃▄▅▅▅`

## Trend Detection

Compare the last 2 weeks of confidence data for each KR:

- **Up**: last week > previous week. Display: `on track`
- **Flat**: last week == previous week. Display: `holding`
- **Dropping**: last week < previous week. Display: `DROPPING` (uppercase, this is a warning)

## Output Format

Render a 62-character-wide box using Unicode box-drawing characters. Every line within the box is padded to exactly 62 characters between the side borders.

```
╔══════════════════════════════════════════════════════════════╗
║  OKR DASHBOARD — QN YYYY (Week N of 13, PHASE)             ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  OBJECTIVE: <text>                                           ║
║  Health Score: XX/100                                        ║
║                                                              ║
║  KR1: <desc> (currently <actual>)                            ║
║  Confidence: ▁▂▃▄▅▅▅ (N/10)   <- trend                      ║
║                                                              ║
║  KR2: <desc> (currently <actual>)                            ║
║  Confidence: ▁▂▃▃▃▂▂ (N/10)   <- DROPPING                   ║
║                                                              ║
║  KR3: <desc> (currently <actual>)                            ║
║  Confidence: ▁▂▃▄▅▆▇ (N/10)   <- on track                   ║
║                                                              ║
║  HEALTH METRICS                                              ║
║  <indicator> metric: status                                  ║
║                                                              ║
║  CADENCE: N/N Mondays, N/N Fridays (X% adherence)            ║
║  Priority completion: X% (N/N P1s done)                      ║
║  Code Reds this quarter: N                                   ║
╚══════════════════════════════════════════════════════════════╝
```

Where:
- **QN YYYY** — current quarter and year (e.g., Q2 2026)
- **Week N of 13** — current week number within the quarter
- **PHASE** — current phase from quarter-info (e.g., EXECUTE, CLOSE)
- **Health indicators** — use green/yellow/red circle emoji per metric from health-score output
- **<actual>** — the current measured value for the KR
- **trend** — one of: `on track`, `holding`, `DROPPING`

## Voice

Data-driven and factual. No coaching, no suggestions, no editorializing. Just the numbers. The dashboard is a snapshot, not a conversation. Coaching belongs in `/monday`.

## Constraints

- This is a **read-only** skill. It does not write any files.
- It only reads existing data and renders the visualization.
- If data is missing or malformed, report what is missing rather than guessing.
- Do not offer advice or next steps. Just render the dashboard.
