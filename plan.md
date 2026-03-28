# OKR-OS — The AI-Native OKR Operating System

## Context

Based on a deep read of Christina Wodtke's **Radical Focus** (2nd edition) and the
**gstack** skill architecture (https://github.com/garrytan/gstack), this plan builds
an open-source skill system for Claude Code that enforces the Radical Focus OKR
methodology as code. The system targets startup CEOs running OKR cadence with teams
of 5-50 people.

**Project name:** okr-os
**Distribution:** Public open source (full gstack-grade infrastructure)
**User model:** CEO + team cadence (shareable artifacts, single-writer)
**Data storage:** Local markdown (.okr/ in project root) + export via /okr-sync
**Objective strictness:** Hard block (ONE Objective per quarter, no override)

## Core Principles from Radical Focus

1. **One Objective per company per quarter** (qualitative, inspirational, memorable)
2. **3 Key Results** (quantitative, stretch goals at 50% confidence)
3. **Health Metrics** (green/yellow/red canaries that protect BAU)
4. **Monday Commitment meetings** (Four-Square: priorities, forecast, confidence, health)
5. **Friday Wins celebrations** (demos, progress, morale)
6. **Cadence is what makes OKRs work** — the weekly rhythm, not just goal-setting
7. **Pipeline over Roadmap** — tactics are flexible, outcomes are fixed
8. **Coaching mindset** — ask "what outcome?" not "what project?"
9. **Mission → Strategy → OKRs** hierarchy
10. **Score and learn** — end-of-quarter grading + retrospective

---

## Skills (12 total)

### Core Skills (Radical Focus methodology)

#### 1. `/okr-setup` — First-time OKR onboarding
Walks the CEO through prerequisites: mission, strategy, metrics maturity,
psychological safety. Produces `OKR-CONTEXT.md`.

**Workflow:**
1. Ask about mission (formula: "We [reduce pain/improve life] in [market] by [value proposition]")
2. Ask about current strategy
3. Assess metrics maturity (instrumentation? baselines?)
4. Ask about team dynamics / psychological safety
5. Output `OKR-CONTEXT.md` with mission, strategy, team structure, readiness score

#### 2. `/okr-set` — Quarterly OKR setting session
Facilitates the Wodtke method: freelist objectives, stack rank, pick ONE,
freelist metrics, group, pick 3 KRs, set stretch values. Hard-blocks multiple objectives.

**Anti-patterns it catches:**
- KRs that are projects/tasks (coaches toward outcomes)
- More than one Objective (hard block, no override)
- Confidence too high (>8 = sandbagging) or too low (<2 = impossible)
- Missing health metrics
- Departmental OKRs masquerading as company OKRs

#### 3. `/okr-team` — Team-level OKR alignment
Helps team leads set OKRs aligned to the company OKR. Identifies support teams
(Health Metrics only) vs. lead teams (own OKRs). Coaches outcome-thinking.

#### 4. `/monday` — Monday Commitment Meeting (Four-Square)
The core cadence ritual. Generates the Four-Square:
1. Weekly priorities toward OKR (3-4 P1s)
2. Monthly forecast
3. OKR confidence update (1-10, color-coded)
4. Health Metrics status (green/yellow/red)

Code Red protocol: if any Health Metric is RED, halts OKR work.

#### 5. `/friday` — Friday Wins Celebration
Structures demos, captures wins across all disciplines, connects wins to OKR
progress, captures "golden apples" resisted, runs 3-question exit ticket.

#### 6. `/okr-status` — Weekly Status Email Generator
Zynga-style status email: OKRs + confidence, last week done/not-done,
next week P1s, risks/blockers, notes.

#### 7. `/okr-grade` — End-of-Quarter Grading & Retrospective
Scores KRs (0.0-1.0), detects sandbagging/over-promising, reviews Code Reds,
analyzes confidence trends, captures learnings, seeds next `/okr-set`.
Includes cross-quarter learning engine (reads history/).

#### 8. `/okr-coach` — On-demand OKR coaching
Socratic method. Coaches task-based KRs into outcome-based thinking using
questions from Radical Focus and Ben Lamorte's coaching example.

### Expansion Skills

#### 9. `/okr-dashboard` — Confidence trends + health score
ASCII visualization: per-KR confidence sparklines, health score (0-100),
cadence adherence, health metric status. The "at a glance" view.

#### 10. `/okr-intro` — New team member onboarding
Generates a one-pager: mission, Objective, KRs, current confidence, this
week's focus. New hire reads one doc and is aligned in 5 minutes.

#### 11. `/okr-sync` — Slack/email/Attio integration
Formats output for distribution. Clipboard-based (no auth complexity in V1).
- `/okr-sync slack` — Slack-flavored markdown
- `/okr-sync email` — Plain-text email with subject line
- `/okr-sync attio` — Upsert OKR record via Attio MCP (if connected)

#### 12. `/okr-upgrade` — Self-update mechanism
Pulls latest from origin, re-runs setup. Like gstack's upgrade flow.

### Expansion Features (built into core skills)

- **Quarterly timeline awareness:** `bin/okr-quarter-info` returns week 1-13,
  phase (early/mid/late/final). Skills adjust coaching tone by phase.
- **Golden Apple detector:** LLM-side prompt instruction in each SKILL.md.
  When CEO describes a new opportunity, asks: "Is this a golden apple?"
- **Cross-quarter learning engine:** Built into `/okr-grade`. Reads history/
  directory for calibration patterns across quarters.
- **OKR health score:** `bin/okr-health-score` computes composite 0-100 from
  cadence adherence, confidence trajectory, priority completion, health metric stability.

---

## Architecture

### System Diagram
```
┌─────────────────────────────────────────────────────────────┐
│                    ~/.claude/skills/okr-os/                  │
│                                                              │
│  ┌──────────┐ ┌──────────┐ ┌────────┐ ┌────────┐           │
│  │okr-setup │ │ okr-set  │ │ monday │ │ friday │  ...       │
│  │SKILL.md  │ │SKILL.md  │ │SKILL.md│ │SKILL.md│           │
│  └────┬─────┘ └────┬─────┘ └───┬────┘ └───┬────┘           │
│       └─────────────┴───────────┴──────────┘                │
│                      │                                       │
│  ┌───────────────────┴───────────────────────────────────┐  │
│  │                 SHARED PREAMBLE                        │  │
│  │  bin/okr-quarter-info  bin/okr-health-score            │  │
│  │  bin/okr-update-check  bin/okr-config                  │  │
│  └───────────────────┬───────────────────────────────────┘  │
└──────────────────────┼──────────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    .okr/ (project root)                      │
│                                                              │
│  OKR-CONTEXT.md                                              │
│  quarters/Q2-2026/                                           │
│    objective.md                                              │
│    health-metrics.md                                         │
│    teams/{team}.md                                           │
│    weekly/YYYY-MM-DD-{monday|friday|status}.md               │
│    retro.md                                                  │
│  history/Q1-2026/  (completed quarters)                      │
└──────────────────────┼──────────────────────────────────────┘
                       ▼ (export only)
┌─────────────────────────────────────────────────────────────┐
│  /okr-sync: slack → clipboard, email → clipboard, attio → MCP│
└─────────────────────────────────────────────────────────────┘
```

### Skill File Structure
```
~/.claude/skills/okr-os/
  okr-setup/SKILL.md        okr-dashboard/SKILL.md
  okr-set/SKILL.md          okr-intro/SKILL.md
  okr-team/SKILL.md         okr-sync/SKILL.md
  monday/SKILL.md           okr-upgrade/SKILL.md
  friday/SKILL.md
  okr-status/SKILL.md       bin/okr-quarter-info
  okr-grade/SKILL.md        bin/okr-health-score
  okr-coach/SKILL.md        bin/okr-update-check
                             bin/okr-config
  setup                      README.md
  CHANGELOG.md               VERSION
```

### CLI Contracts

**`bin/okr-quarter-info`** (no args, or --date YYYY-MM-DD)
```
QUARTER: Q2
YEAR: 2026
WEEK: 5
WEEKS_REMAINING: 8
PHASE: mid    # early (1-4), mid (5-9), late (10-12), final (13)
```

**`bin/okr-health-score`** (--quarter Q1-2026 --okr-dir .okr)
```json
{"score": 72, "components": {
  "cadence_adherence": 85,
  "confidence_trajectory": 60,
  "priority_completion": 75,
  "health_metric_stability": 70
}}
```

### File Schemas (YAML Frontmatter)

All .okr/ files use YAML frontmatter for machine-parseable data. The markdown
body below the frontmatter is human-readable narrative. bin/ scripts parse only
the YAML. SKILL.md prompts must instruct Claude to write this exact format.

**`objective.md`**
```yaml
---
quarter: Q2-2026
objective: "Own the direct-to-business tea market"
key_results:
  - id: kr1
    description: "Revenue reaches $50K/month"
    target: 50000
    unit: dollars_per_month
    confidence: 5
  - id: kr2
    description: "25 new restaurant partners"
    target: 25
    unit: count
    confidence: 5
  - id: kr3
    description: "NPS score above 8"
    target: 8.0
    unit: score
    confidence: 5
health_metrics:
  - name: "Customer satisfaction"
    status: green
  - name: "Code health"
    status: green
  - name: "Team morale"
    status: green
created: 2026-04-01
---
```

**`weekly/YYYY-MM-DD-monday.md`**
```yaml
---
week: 7
date: 2026-05-18
priorities:
  - text: "Close 3 new restaurant leads"
    priority: P1
    status: pending    # pending | done | not_done
  - text: "Launch email drip campaign"
    priority: P1
    status: pending
  - text: "Run NPS survey"
    priority: P1
    status: pending
confidence:
  kr1: 5
  kr2: 2
  kr3: 8
health_metrics:
  - name: "Customer satisfaction"
    status: green
  - name: "Code health"
    status: yellow
  - name: "Team morale"
    status: green
code_red: false
forecast:
  - "Board meeting Apr 15"
---
```

**`weekly/YYYY-MM-DD-friday.md`**
```yaml
---
week: 7
date: 2026-05-22
wins:
  - team: Engineering
    text: "Shipped supplier dashboard v2"
    kr_tags: [kr1]
  - team: Sales
    text: "Closed Cafe Luna — $2.4K/mo recurring"
    kr_tags: [kr1, kr2]
golden_apples_resisted:
  - "Turned down BigCorp custom integration"
exit_ticket:
  keep_doing: "Weekly eng demos"
  change: "Start Monday meetings 15 min earlier"
  management_should_know: "Team wants clearer Q3 direction"
---
```

**`OKR-CONTEXT.md`**
```yaml
---
mission: "Bringing great tea to people who love it"
strategy: "Expand B2B tea supply to South Bay restaurants"
quarter_start: 1    # Month number (1=Jan, 4=Apr for fiscal year)
team_size: 12
teams:
  - name: Engineering
    type: lead       # lead | support
  - name: Sales
    type: lead
  - name: Marketing
    type: support
metrics_maturity: intermediate  # beginner | intermediate | advanced
readiness_score: 7
---
```

### bin/okr-state (new utility)

Shared utility that reads current OKR state. All skills call this instead
of reimplementing file parsing.

```
INPUT:  --okr-dir .okr (optional, defaults to .okr)
OUTPUT (stdout):
  OBJECTIVE: Own the direct-to-business tea market
  KR1: Revenue reaches $50K/month | confidence=5 | target=50000
  KR2: 25 new restaurant partners | confidence=2 | target=25
  KR3: NPS score above 8 | confidence=8 | target=8.0
  HEALTH: Customer satisfaction=green Code health=yellow Team morale=green
  CODE_RED: false
  QUARTER: Q2-2026
  WEEK: 7
  PHASE: mid
EXIT:   0 on success, 1 if no objective set, 2 if no .okr/ dir
```

### Preconditions & Error Handling

| Skill | Requires | Error if missing |
|-------|----------|-----------------|
| /okr-setup | Nothing | N/A |
| /okr-set | OKR-CONTEXT.md | "Run /okr-setup first." |
| /okr-team | Current quarter objective.md | "Run /okr-set first." |
| /monday | Current quarter objective.md | "Run /okr-set first." |
| /friday | Current quarter objective.md | "Run /okr-set first." |
| /okr-status | This week's monday.md | "Run /monday first." |
| /okr-grade | 4+ weeks of data | "Need 4+ weeks of cadence data." |
| /okr-dashboard | 2+ weeks of data | "Need 2+ weeks to show trends." |
| /okr-intro | OKR-CONTEXT.md + objective.md | "Run /okr-setup and /okr-set." |
| /okr-sync | Recent weekly files | "Run /monday, /friday, or /okr-status first." |

### Security

- Setup script auto-adds `.okr/` to `.gitignore` (OKR data contains business strategy)
- V1 telemetry is local-only analytics logging (no remote collection)
- bin/ scripts validate inputs, no user-supplied strings in shell commands

---

## Phased Delivery

### Phase 1: Core Cadence (MVP)
**Skills:** /okr-setup, /okr-set, /monday, /friday, /okr-coach
**Infra:** setup script, basic preamble, bin/okr-quarter-info
**Goal:** CEO can set OKRs and run the Monday/Friday cadence.

### Phase 2: Reporting + Teams
**Skills:** /okr-status, /okr-team, /okr-grade, /okr-dashboard
**Features:** timeline awareness, health score
**Infra:** bin/okr-health-score, bin/okr-config
**Goal:** Full cadence with status emails, team alignment, grading.

### Phase 3: Intelligence + Distribution
**Skills:** /okr-intro, /okr-sync, /okr-upgrade
**Features:** cross-quarter learning, golden apple detector
**Infra:** full preamble (local analytics), upgrade mechanism
**Goal:** Distributable product with integrations and learning.

---

## What Makes This Different

1. **Hard-blocks multiple Objectives** — enforces ONE, no override
2. **Catches task-based KRs** — coaches toward outcomes using Socratic method
3. **Health Metrics are mandatory** — first-class citizens, not optional
4. **Cadence-first** — Monday/Friday rhythm IS the product
5. **Quarterly timeline awareness** — coaching tone adapts by week
6. **Cross-quarter learning** — detects sandbagging/over-promising patterns
7. **Based on Radical Focus** — every feature traces to the book, not generic advice

---

## CEO Review Decisions

All decisions made during /plan-ceo-review on 2026-03-28:

| Decision | Choice | Reasoning |
|----------|--------|-----------|
| User model | CEO + team cadence | Shareable artifacts, not personal notes |
| Data storage | Local markdown + export | Portable, no vendor lock-in |
| Distribution | Public open source | Like gstack |
| Implementation | Full gstack clone | All infrastructure from day 1 |
| Objective strictness | Hard block | Purist Radical Focus |
| Project name | okr-os | OKR Operating System |
| Sync design | Separate /okr-sync skill | Clean separation of formatting |
| .gitignore | Auto-add .okr/ | OKR data is sensitive |
| Review mode | SCOPE EXPANSION | Cathedral build |

### Expansions Accepted (7/7)
1. /okr-dashboard (confidence trends + ASCII viz)
2. Quarterly timeline awareness (week 1-13 coaching)
3. Golden Apple detector (anti-distraction coaching)
4. /okr-intro (new team member onboarding)
5. Cross-quarter learning engine
6. /okr-sync (Slack/email/Attio integration)
7. OKR health score (composite 0-100)

Full CEO plan: `~/.gstack/projects/OKR/ceo-plans/2026-03-28-okr-os.md`

---

## Output Design Specifications

All output formats designed during /plan-design-review on 2026-03-28.

### Design Conventions

```
CHARACTERS
  Box-drawing:    ┌─┐ │ └─┘ ├─┤ (terminal only, stripped for export)
  Separators:     ─── (thin), ═══ (thick/header)
  Progress fill:  ▅ (filled), ○ (empty) — weekly artifacts
  Sparkline:      ▁▂▃▄▅▆▇█ — dashboard only
  Checkmarks:     ✅ done, ❌ not done, ⚠️ warning

EMOJI VOCABULARY (exhaustive — no others)
  🟢 green    🟡 yellow    🔴 red/Code Red
  🏆 wins     🍎 golden apple    ⚠️ warning

CONFIDENCE COLOR CODING
  1-3: RED    4-6: YELLOW    7-10: GREEN

OUTPUT WIDTH
  Terminal: 62 chars    Email: 72 chars    Slack: unconstrained

HIERARCHY (every artifact)
  Line 1: Artifact name + week
  Line 2: Quarter + health score
  Section 1: Objective + KRs (always first)
  Last: Coaching prompt or CTA

COACHING VOICE
  Always reference specific KR data. Never generic.
  Bad: "Keep pushing!"  Good: "KR2 dropped 3 pts. What changed?"

RENDERING MODES
  Terminal: Box-drawing, emoji, sparklines/fill bars
  Export (Slack/email): /okr-sync strips boxes, uses native formatting
  --plain: Pure ASCII. No emoji, no unicode. Screen-reader friendly.
```

### /monday Four-Square Output

```
┌─────────────────────────────────────────────────────────────┐
│  MONDAY COMMITMENTS — Week 7 of 13 (midpoint)              │
│  Q2 2026 · Health Score: 72/100                             │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  OBJECTIVE: Own the direct-to-business tea market            │
│                                                              │
│  KR1  Revenue $50K/mo         5/10 ▅▅▅▅▅○○○○○  → flat       │
│  KR2  25 restaurant partners  2/10 ▅▅○○○○○○○○  → DROPPING   │
│  KR3  NPS > 8                 8/10 ▅▅▅▅▅▅▅▅○○  → on track   │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│  LAST WEEK                        │  THIS WEEK               │
│  ✅ Close Cafe Luna deal          │  P1: Close 3 new leads   │
│  ✅ Ship supplier dashboard v2    │  P1: Launch email campaign│
│  ❌ Run NPS survey (delayed)      │  P1: Run NPS survey      │
│                                   │  P2: Prep investor deck   │
├─────────────────────────────────────────────────────────────┤
│  MONTHLY FORECAST                                            │
│  · Board meeting Apr 15 — need projections by Apr 10        │
├─────────────────────────────────────────────────────────────┤
│  HEALTH METRICS                                              │
│  🟢 Customer satisfaction    🟡 Code health    🟢 Team morale │
├─────────────────────────────────────────────────────────────┤
│  ⚠️  KR2 confidence dropped 3 points this week.             │
│  What changed? What can unblock restaurant partnerships?     │
└─────────────────────────────────────────────────────────────┘
```

### /friday Wins Output

```
┌─────────────────────────────────────────────────────────────┐
│  🏆 FRIDAY WINS — Week 7                                    │
│  Q2 2026 · OKR Progress: 45%                                │
├─────────────────────────────────────────────────────────────┤
│  THIS WEEK'S WINS                                            │
│                                                              │
│  Engineering                                                 │
│  · Shipped supplier dashboard v2 (KR1: revenue enabler)     │
│  · Fixed checkout bug — 15% fewer abandoned carts            │
│                                                              │
│  Sales                                                       │
│  · Closed Cafe Luna — $2.4K/mo recurring (KR1, KR2)         │
│                                                              │
│  GOLDEN APPLES RESISTED 🍎                                   │
│  · Turned down BigCorp custom integration (3 weeks eng)      │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│  EXIT TICKET                                                 │
│  Keep doing: Weekly eng demos                                │
│  Change: Start Monday meetings 15 min earlier                │
│  Management should know: Team wants clearer Q3 direction     │
└─────────────────────────────────────────────────────────────┘
```

### /okr-status Email Output

```
Subject: [OKR Status] Week 7/13 — Health: 72/100

OBJECTIVE: Own the direct-to-business tea market
─────────────────────────────────────────────────

KR1: Revenue $50K/mo ........... 5/10 (was 5) → $38K actual
KR2: 25 restaurant partners .... 2/10 (was 5) ⚠️ DROPPING
KR3: NPS > 8 ................... 8/10 (was 7) → 7.2 actual

LAST WEEK
  ✓ Close Cafe Luna deal
  ✓ Ship supplier dashboard v2
  ✗ Run NPS survey — delayed, vendor conflict

THIS WEEK (P1s)
  1. Close 3 new restaurant leads (KR2)
  2. Launch email drip campaign (KR1)
  3. Run NPS survey (KR3)

RISKS & BLOCKERS
  · KR2 pipeline is thin. Need 10+ leads this week.
  · New eng hire starts Apr 14 — velocity dip for ~2 weeks.

NOTES
  · Board meeting Apr 15. Need Q2 projections by Apr 10.
```

### /okr-set Quarter Document

```
┌─────────────────────────────────────────────────────────────┐
│  Q2 2026 — OKR SET                                          │
│  April 1 – June 30 (13 weeks)                               │
├─────────────────────────────────────────────────────────────┤
│  OBJECTIVE                                                   │
│  Own the direct-to-business tea market in the South Bay      │
│                                                              │
│  KEY RESULTS                                     Confidence  │
│  1. Revenue reaches $50K/month                      5/10     │
│  2. 25 new restaurant partners signed               5/10     │
│  3. NPS score above 8                               5/10     │
│                                                              │
│  HEALTH METRICS (protect these)                              │
│  · Customer satisfaction (target: stable)                    │
│  · Code health / uptime (target: 99.5%+)                    │
│  · Team morale (target: no burnout signals)                  │
├─────────────────────────────────────────────────────────────┤
│  CADENCE                                                     │
│  Monday: Commitment meeting    Friday: Wins celebration      │
│  First /monday: April 7       Grade by: June 16              │
├─────────────────────────────────────────────────────────────┤
│  "50% confidence means you'll need your A game.              │
│   That's the point."                                         │
└─────────────────────────────────────────────────────────────┘
```

### /okr-intro Onboarding One-Pager

```
┌─────────────────────────────────────────────────────────────┐
│  WELCOME TO THE TEAM                                         │
├─────────────────────────────────────────────────────────────┤
│  OUR MISSION                                                 │
│  Bringing great tea to people who love it.                   │
│                                                              │
│  THIS QUARTER (Q2 2026)                                      │
│  OBJECTIVE: Own the direct-to-business tea market            │
│                                                              │
│  How we know we succeeded:                                   │
│  1. Revenue $50K/month (currently $38K)                      │
│  2. 25 restaurant partners (currently 12)                    │
│  3. NPS > 8 (currently 7.2)                                  │
│                                                              │
│  WHERE WE STAND (Week 7)                                     │
│  · Revenue: tracking, needs acceleration                     │
│  · Partnerships: behind — help most needed here              │
│  · Satisfaction: strong, trending up                         │
│                                                              │
│  OUR CADENCE                                                 │
│  Monday: Commitments    Friday: Wins    Weekly: Status email │
│                                                              │
│  THIS WEEK'S FOCUS                                           │
│  P1: Close 3 new restaurant leads                            │
│  P1: Launch email campaign                                   │
│  P1: Run NPS survey                                          │
└─────────────────────────────────────────────────────────────┘
```

### /okr-sync slack Format

```
*MONDAY COMMITMENTS — Week 7/13*
Health Score: 72/100

*OBJECTIVE:* Own the direct-to-business tea market

KR1: Revenue $50K/mo → `5/10` flat
KR2: 25 partners → `2/10` ⚠️ dropping
KR3: NPS > 8 → `8/10` ✅ on track

*This week:*
• Close 3 new restaurant leads
• Launch email drip campaign
• Run NPS survey

*Health:* 🟢 Satisfaction  🟡 Code health  🟢 Morale

> ⚠️ KR2 dropped 3 points. What can unblock partnerships?
```

### /okr-grade Retrospective

```
┌─────────────────────────────────────────────────────────────┐
│  Q2 2026 RETROSPECTIVE                                      │
│  Overall Score: 0.71 — GOOD (sweet spot: 0.6-0.7)           │
│  Health Score: 72/100                                        │
├─────────────────────────────────────────────────────────────┤
│  KR1: Revenue $50K/mo                                        │
│  Target: $50K  Actual: $38K  Score: 0.76                     │
│  Trend: ▁▂▃▃▄▄▅▅▅▅▅  Calibration: slightly ambitious        │
│                                                              │
│  KR2: 25 restaurant partners                                 │
│  Target: 25   Actual: 18   Score: 0.72                       │
│  Trend: ▁▂▃▃▃▃▂▂▃▃▄  Calibration: calibrated                │
│                                                              │
│  KR3: NPS > 8                                                │
│  Target: 8.0  Actual: 7.2  Score: 0.65                       │
│  Trend: ▁▂▃▄▅▅▆▇▇▇▇  Calibration: slightly ambitious        │
├─────────────────────────────────────────────────────────────┤
│  CADENCE: 10/11 Mon (91%), 8/11 Fri (73%)                    │
│  Priority completion: 75%    Code Reds: 1                    │
├─────────────────────────────────────────────────────────────┤
│  LEARNINGS                                                   │
│  ✅ Monday commitments kept us focused                       │
│  ✅ Paired KRs caught blind spots                            │
│  ❌ NPS measurement delayed 3 weeks                          │
│  ❌ Friday attendance dropped mid-quarter                     │
├─────────────────────────────────────────────────────────────┤
│  PATTERNS (2+ quarters)                                      │
│  · Revenue KRs consistently easy (avg 0.78). Raise bar 20%. │
│  · Friday attendance declining QoQ. Mix up the format.       │
└─────────────────────────────────────────────────────────────┘
```

### Code Red Banner

```
┌─────────────────────────────────────────────────────────────┐
│  🔴 CODE RED — Code health in freefall                      │
├─────────────────────────────────────────────────────────────┤
│  OKR WORK IS PAUSED until this is resolved.                  │
│                                                              │
│  What happened: Production outages 3x this week.             │
│  Who's on it: Engineering (Raphael leading)                  │
│  Target resolution: Wednesday                                │
│                                                              │
│  When cleared, Monday commitments resume.                    │
│  This incident will be reviewed in quarterly retro.          │
└─────────────────────────────────────────────────────────────┘
```

### Golden Apple Prompt

```
────────────────────────────────────────────────────
🍎 GOLDEN APPLE CHECK

You mentioned exploring a partnership with BigCorp.
Your Objective this quarter is:

  "Own the direct-to-business tea market"

Does this directly advance that goal?

  A) Yes — add to tactics pipeline
  B) No — note for Q3 brainstorming
  C) Call a Code Red (halt OKR work, shift focus)

Atalanta lost her race picking up golden apples.
────────────────────────────────────────────────────
```

## GSTACK REVIEW REPORT

| Review | Trigger | Why | Runs | Status | Findings |
|--------|---------|-----|------|--------|----------|
| CEO Review | `/plan-ceo-review` | Scope & strategy | 1 | CLEAR | 7 proposals, 7 accepted, 0 deferred |
| Eng Review | `/plan-eng-review` | Architecture & tests (required) | 1 | CLEAR (PLAN) | 6 issues, 0 critical gaps |
| Design Review | `/plan-design-review` | UI/UX gaps | 1 | CLEAR (FULL) | score: 3/10 → 8/10, 13 decisions |
| Outside Voice | Claude subagent | Independent challenge | 1 | issues_found | 9 findings, 1 schema fix accepted |

- **UNRESOLVED:** 0 across all reviews
- **VERDICT:** CEO + ENG + DESIGN CLEARED — ready to implement.
