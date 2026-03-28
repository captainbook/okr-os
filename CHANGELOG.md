# Changelog

## 0.1.0 (2026-03-28)

Initial release of OKR-OS.

### Skills
- `/okr-setup` — First-time OKR onboarding (mission, strategy, prerequisites)
- `/okr-set` — Quarterly OKR setting session (ONE Objective, hard block)
- `/okr-team` — Team-level OKR alignment
- `/monday` — Monday Commitment Meeting (Four-Square format)
- `/friday` — Friday Wins Celebration
- `/okr-status` — Weekly Status Email Generator
- `/okr-grade` — End-of-Quarter Grading & Retrospective
- `/okr-coach` — On-demand OKR coaching (Socratic method)
- `/okr-dashboard` — Confidence trends + health score ASCII visualization
- `/okr-intro` — New team member onboarding one-pager
- `/okr-sync` — Slack/email/Attio integration
- `/okr-upgrade` — Self-update mechanism

### Infrastructure
- `bin/okr-quarter-info` — Quarter detection with fiscal year support
- `bin/okr-health-score` — Composite health score calculator
- `bin/okr-state` — Shared OKR state reader
- `bin/okr-update-check` — Version check against remote
- `bin/okr-config` — User preferences
- `setup` — Installation script
- bats-core test suite

### Methodology
- Based on Christina Wodtke's Radical Focus (2nd edition)
- Hard-blocks multiple Objectives (ONE per quarter, no override)
- Catches task-based KRs and coaches toward outcomes
- Health Metrics as first-class citizens
- Monday/Friday cadence enforcement
- Quarterly timeline awareness (coaching tone adapts by week 1-13)
- Cross-quarter learning engine
- Golden Apple detector (anti-distraction coaching)
- OKR health score (composite 0-100)
