# Vercel CFO Service

Cloud cost management for Vercel accounts.

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Main skill documentation (use this) |
| `QUICKREF.md` | Quick reference card |
| `PROMPTS.md` | Reusable prompt templates |

## Example Audit Data

Located in: `/home/claude-agent/vercel-audit/`

Contains:
- `audit_report.json` - Real audit of Dr. Uri's account
- `VERCEL_API_DOCUMENTATION.md` - Full API reference
- `VERCEL_KNOWLEDGE.md` - Pricing and billing info
- `github-issues/` - Example issues for cloud engineer

## Usage

When working on Vercel tasks:

1. Read `SKILL.md` for full documentation
2. Use `QUICKREF.md` for common commands
3. Reference `PROMPTS.md` for task templates

## Secrets

| Secret | Location | Purpose |
|--------|----------|---------|
| `VERCEL_TOKEN` | GCP Secret Manager | API access |

## Audit Data Example

See `/home/claude-agent/vercel-audit/` for a complete example of:
- Team billing analysis
- Project inventory
- Deployment patterns
- Cost breakdown
- GitHub issues for remediation
- Email template for support refund request

## Quick Start

```bash
# Get token from GCP
gcloud secrets versions access latest --secret=VERCEL_TOKEN --project=nursebridge-prep

# Basic audit
curl -H "Authorization: Bearer $VERCEL_TOKEN" \
  "https://api.vercel.com/v2/teams/{teamId}"
```

## Extending

To add new capabilities:
1. Update `SKILL.md` with new endpoints/patterns
2. Add reusable prompts to `PROMPTS.md`
3. Update `QUICKREF.md` with quick commands
