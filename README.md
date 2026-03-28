# OKR-OS

The AI-native OKR operating system for startup CEOs. Enforces the [Radical Focus](https://www.amazon.com/Radical-Focus-SECOND-Achieving-Objectives/dp/1955469016) methodology as Claude Code skills.

## What is this?

OKR-OS is a set of 12 slash commands for [Claude Code](https://claude.ai/code) that coach you through the OKR process. It's not a dashboard. It's not a tracker. It's a coach that holds you accountable to the cadence that makes OKRs actually work.

Based on Christina Wodtke's Radical Focus (2nd edition). Every feature traces directly to the book.

## Quick Start

```bash
git clone https://github.com/YOUR_USERNAME/okr-os.git ~/.claude/skills/okr-os
cd ~/.claude/skills/okr-os
./setup
```

Then in Claude Code:

```
/okr-setup     # Set your mission, strategy, and prerequisites
/okr-set       # Define this quarter's Objective and Key Results
/monday        # Run your Monday commitment meeting
/friday        # Celebrate Friday wins
```

## Skills

### Core Cadence
| Skill | What it does | When to use |
|-------|-------------|-------------|
| `/okr-setup` | First-time onboarding | Once, at the start |
| `/okr-set` | Set quarterly OKR | Start of each quarter |
| `/monday` | Monday commitment meeting | Every Monday |
| `/friday` | Friday wins celebration | Every Friday |
| `/okr-coach` | On-demand OKR coaching | Anytime you need help writing OKRs |

### Reporting & Teams
| Skill | What it does | When to use |
|-------|-------------|-------------|
| `/okr-status` | Generate status email | Weekly, for stakeholders |
| `/okr-team` | Set team-level OKRs | After company OKR is set |
| `/okr-grade` | End-of-quarter grading | 2 weeks before quarter ends |
| `/okr-dashboard` | ASCII confidence trends | Anytime, for a quick overview |

### Distribution
| Skill | What it does | When to use |
|-------|-------------|-------------|
| `/okr-intro` | New hire onboarding doc | When someone joins mid-quarter |
| `/okr-sync` | Format for Slack/email/Attio | After /monday, /friday, or /okr-status |
| `/okr-upgrade` | Update okr-os | When a new version is available |

## How It Works

OKR-OS stores everything as local markdown files in `.okr/` in your project root:

```
.okr/
  OKR-CONTEXT.md              # Mission, strategy, team structure
  quarters/Q2-2026/
    objective.md               # THE Objective + 3 Key Results
    health-metrics.md          # Green/yellow/red canaries
    teams/engineering.md       # Team-level OKRs
    weekly/
      2026-04-07-monday.md     # Monday Four-Square
      2026-04-11-friday.md     # Friday Wins
      2026-04-11-status.md     # Status email
    retro.md                   # End-of-quarter retrospective
  history/Q1-2026/             # Past quarters (for learning)
```

All files use YAML frontmatter for machine-parseable data, with human-readable markdown below.

## What Makes This Different

1. **Hard-blocks multiple Objectives.** You get ONE per quarter. No override. No config to change it. This is the methodology.
2. **Catches task-based KRs.** "Launch the new dashboard" is a task, not a KR. The coach will push you toward "Dashboard DAU reaches 500" instead.
3. **Health Metrics are mandatory.** Not optional. You define what you're protecting while you stretch.
4. **Cadence-first.** The Monday/Friday rhythm IS the product. Setting OKRs and forgetting about them is the #1 failure mode. OKR-OS won't let that happen.
5. **Quarterly timeline awareness.** Week 1 coaching is different from week 12 coaching. The system knows where you are and adjusts.
6. **Cross-quarter learning.** After 2+ quarters, the grading skill detects your calibration patterns. Are you a chronic sandbagger? The system will tell you.
7. **Golden Apple detector.** When you mention a shiny new opportunity mid-quarter, the system asks: "Is this a golden apple? Does it advance your Objective?"

## Design Principles

From Radical Focus:

- **One Objective to rule them all.** Focus is subtraction, not addition.
- **KRs are outcomes, not outputs.** Measure results, not activity.
- **The cadence is what makes OKRs work.** Not the goal-setting. The weekly rhythm.
- **50% confidence = right difficulty.** If you're sure you'll hit it, it's too easy. If you're sure you won't, it's too hard.
- **Health Metrics protect what you've built** while you stretch for what's next.
- **Score and learn.** Every quarter is a learning cycle. 0.6-0.7 is the sweet spot.

## Used By

<!--
  Using OKR-OS at your company? We'd love to feature your logo here.

  Submit a PR adding your company to the list below, or open an issue
  with your company name and logo URL. SVG preferred, 120px height max.
-->

<p align="center">
  <em>Your company could be here.</em>
</p>

**Add your logo:** If your startup uses OKR-OS to run your OKR cadence, we want to hear from you. Submit a PR adding your company to this section, or [open an issue](../../issues/new?title=Add+our+logo&template=add-logo.md) with:

- Company name
- Logo (SVG or PNG, 120px height max)
- One sentence on how you use OKR-OS
- (Optional) link to your site

We feature every company that ships with OKR-OS. No minimum size, no approval process. If you're using it, you belong here.

## Why I Built This

I'm [Jerome Bajou](https://www.linkedin.com/in/jeromebajou/), CEO and co-founder of [Captainbook.io](https://captainbook.io). We've been running OKRs since 2022, and I'm convinced Christina Wodtke's framework played a real part in getting us where we are today. In just a few years, we put Captainbook on the traveltech map, competing against players with 10x our budget and 50x our headcount. Focus was our edge, and OKRs gave us that focus.

But here's the thing about being early stage: you can't afford an OKR consultant. You can't hire a Chief of Staff to run the process. And you definitely can't spend half a day every quarter figuring out if your KRs are outcomes or tasks. You just need to move fast and stay pointed in the right direction.

OKR-OS is my answer to that. An AI coach that knows the methodology cold, holds you to the cadence, and catches the mistakes before they cost you a quarter. I built it for myself, and I'm putting it here for anyone who wants the same unfair advantage that radical focus gives a small team with a big mission.

This project is not affiliated with or endorsed by Christina Wodtke. It's an independent, open-source tool inspired by her book. If you haven't read [Radical Focus](https://www.amazon.com/Radical-Focus-SECOND-Achieving-Objectives/dp/1955469016), go read it. This tool is the practice. The book is the theory. You need both.

## Requirements

- [Claude Code](https://claude.ai/code)
- bash (macOS or Linux)
- No other dependencies

## License

MIT
