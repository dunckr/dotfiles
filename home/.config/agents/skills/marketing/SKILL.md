---
name: marketing
description: Load one of 50 marketing skills (coreyhaines31/marketingskills) on demand without installing them. Use when the user asks for help with marketing, growth, CRO, landing pages, copywriting, SEO, ads, cold email, email sequences, pricing, positioning, launches, analytics, attribution, churn, referrals, or any go-to-market task. Also use when the user says "marketing skill" or asks which marketing skills exist.
---

# Marketing skills

The skills live in a git clone at `~/.cache/marketingskills`, not in `~/.claude/skills`. The helper at `~/.claude/skills/marketing/marketing.sh` clones on first use.

Available skills (name and first sentence of each description):

!`~/.claude/skills/marketing/marketing.sh list`

## Loading a skill

1. Pick the skill whose description best matches the request. If the user named one, use that. If two apply, load both.
2. Load it into context:

   ```bash
   ~/.claude/skills/marketing/marketing.sh show <name>
   ```

3. Follow the loaded SKILL.md as if it were a normal installed skill. The first line of the output is the skill directory. Resolve its `references/`, `assets/`, and `evals/` links relative to that directory and read them with `cat` when the skill tells you to.
4. When a loaded skill says "see <other-skill>", that refers to another skill in this same set. Load it with `show` too, do not assume it is installed.

## Updating

Refresh the clone when the user asks for the latest version:

```bash
~/.claude/skills/marketing/marketing.sh sync --update
```

Skill names changed between v1 and v2 of the repo. If a name from the user's memory is missing, run `list` and pick the closest match.
