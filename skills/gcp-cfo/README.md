# GCP CFO Service

Cloud cost management for Google Cloud Platform.

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Main skill documentation |
| `QUICKREF.md` | Quick reference card |
| `PROMPTS.md` | Reusable prompt templates |

## Example Audit Data

Located in: `/home/claude-agent/gcp-audit/`

Contains:
- `monthly_costs.json` - Monthly cost trend
- `services_costs.json` - Cost by service
- `projects_costs.json` - Cost by project
- `gemini_costs.json` - Gemini API breakdown

## Usage

When working on GCP billing tasks:

1. Read `SKILL.md` for full documentation
2. Use `QUICKREF.md` for quick queries
3. Reference `PROMPTS.md` for task templates

## Secrets

No secrets needed - uses gcloud CLI with configured service account.

## Quick Start

```bash
# Set project
gcloud config set project nursebridge-prep

# Query monthly costs
bq query --use_legacy_sql=false \
"SELECT EXTRACT(MONTH FROM usage_start_time) as m,
        SUM(cost) as cost
 FROM billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033
 WHERE usage_start_time >= '2026-01-01'
 GROUP BY m ORDER BY m DESC"
```

## Key Insights from Real Audit

| Month | Total | Gemini | Notes |
|-------|-------|--------|-------|
| Jan 2026 | $11 | $0 | Low start |
| Feb 2026 | $2,574 | $1,590 | Usage begins |
| Mar 2026 | $2,649 | $7,238 | PEAK |
| Apr 2026 | $1,779 | $0.23 | Decreasing |
| May 2026 | $1,370 | $0.19 | Further drop |
| Jun 2026 | $117 | $37 | Stable |

**Total 2026 Spend:** ~$8,500

**Biggest Lesson:** Gemini API can spike unexpectedly. Set budgets and monitor closely.

## Extending

To add new capabilities:
1. Update `SKILL.md` with new queries/patterns
2. Add reusable prompts to `PROMPTS.md`
3. Update `QUICKREF.md` with quick commands
