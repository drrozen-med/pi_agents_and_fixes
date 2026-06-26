# Vercel CFO - Quick Reference Card

## AUTH
```bash
VERCEL_TOKEN=vcp_xxx
HEADER="Authorization: Bearer $VERCEL_TOKEN"
BASE="https://api.vercel.com"
TEAM_ID="team_xxx"
```

## QUICK COMMANDS

### Get team info
```bash
curl -sH "$HEADER" "$BASE/v2/teams/$TEAM_ID" | jq '{plan, status}'
```

### List projects
```bash
curl -sH "$HEADER" "$BASE/v10/projects" | jq '.projects[] | {name, id}'
```

### List deployments
```bash
curl -sH "$HEADER" "$BASE/v7/deployments?limit=100" | jq '.deployments[] | {name, state, created}'
```

### Get billing
```bash
curl -sH "$HEADER" "$BASE/v1/billing/charges?from=2026-01-01T00:00:00Z&to=2026-12-31T00:00:00Z&teamId=$TEAM_ID"
```

### Delete project
```bash
curl -X DELETE -H "$HEADER" "$BASE/v1/projects/{projectIdOrName}"
```

## COST DRIVERS
| Item | Normal | Warning | Critical |
|------|--------|---------|----------|
| Origin Transfer | <10GB | 10-100GB | >100GB |
| Build CPU | <500min | 500-2000min | >2000min |
| Blob Transfer | <10GB | 10-100GB | >100GB |

## PLANS
| Plan | Price | Auto-deploys |
|------|-------|--------------|
| Hobby | FREE | Limited |
| Pro | $20/mo | Unlimited |
| Pro Plus | $20+/mo | Unlimited + Turbo |

## DOWNGRADE
Settings → Billing → Plan → Downgrade to Hobby

## SUPPORT
support@vercel.com
