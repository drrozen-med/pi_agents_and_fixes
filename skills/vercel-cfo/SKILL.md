---
description: Vercel Cloud Cost Management - CFO-grade playbook for Vercel account auditing, billing analysis, cost optimization, and subscription management. Use when working with Vercel billing, deployments, projects, or cost reduction.
---

# Vercel CFO Service (Cloud Cost Management)

**Purpose:** Audit, analyze, optimize, and manage Vercel cloud costs.

---

## Quick Reference

### Authentication
```
Token format: vcp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Header: Authorization: Bearer <token>
```

### Team ID Format
```
team_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### API Base URL
```
https://api.vercel.com
```

### OpenAPI Documentation
```
https://openapi.vercel.sh/ (7.5MB, 230 endpoints)
```

---

## Common Operations

### Get Team Info
```bash
curl -H "Authorization: Bearer $VERCEL_TOKEN" \
  "https://api.vercel.com/v2/teams/{teamId}"
```

### List Projects
```bash
curl -H "Authorization: Bearer $VERCEL_TOKEN" \
  "https://api.vercel.com/v10/projects"
```

### List Deployments
```bash
curl -H "Authorization: Bearer $VERCEL_TOKEN" \
  "https://api.vercel.com/v7/deployments?limit=100"
```

### Get Billing Charges (FOCUS Format)
```bash
curl -H "Authorization: Bearer $VERCEL_TOKEN" \
  "https://api.vercel.com/v1/billing/charges?from=2026-01-01T00:00:00.000Z&to=2026-12-31T00:00:00.000Z&teamId={teamId}"
```

### Delete Project
```bash
curl -X DELETE \
  -H "Authorization: Bearer $VERCEL_TOKEN" \
  "https://api.vercel.com/v1/projects/{projectIdOrName}"
```

### Cancel Deployment
```bash
curl -X PATCH \
  -H "Authorization: Bearer $VERCEL_TOKEN" \
  "https://api.vercel.com/v12/deployments/{id}/cancel"
```

---

## Key API Endpoints

| Category | Endpoint | Methods | Description |
|----------|----------|---------|-------------|
| **Team** | `/v2/teams/{teamId}` | GET, PATCH | Get/update team info |
| **Projects** | `/v10/projects` | GET | List all projects |
| **Projects** | `/v1/projects/{idOrName}` | DELETE | Delete project |
| **Deployments** | `/v7/deployments` | GET | List deployments |
| **Deployments** | `/v13/deployments/{id}` | DELETE | Delete deployment |
| **Deployments** | `/v12/deployments/{id}/cancel` | PATCH | Cancel deployment |
| **Billing** | `/v1/billing/charges` | GET | Get FOCUS-format charges |
| **Domains** | `/v5/domains` | GET | List domains |
| **Domains** | `/v7/domains` | POST | Add domain |
| **Domains** | `/v6/domains/{domain}` | DELETE | Delete domain |
| **Aliases** | `/v4/aliases` | GET | List aliases |
| **Events** | `/v3/deployments/{idOrUrl}/events` | GET | Get deployment events |
| **Checks** | `/v2/projects/{idOrName}/checks` | GET, POST | Manage checks |

---

## Pricing Reference

### Bandwidth / Data Transfer

| Component | Rate | Notes |
|-----------|------|-------|
| Fast Origin Transfer | $0.06/GB | Uncached data from origin |
| Fast Data Transfer | $0.15/GB | Cached data |
| Blob Data Transfer | $0.05/GB | Blob storage egress |

### Compute

| Component | Rate | Notes |
|-----------|------|-------|
| Build CPU (Standard) | $0.0035/min | Default tier |
| Build CPU (Turbo) | $0.0035/min | Faster, uses more CPU |
| Fluid Active CPU | $0.128/vCPU-hr | Serverless compute |
| Function Duration | $0.0006/GB-sec | Serverless execution |

### Storage

| Component | Rate | Notes |
|-----------|------|-------|
| Blob Storage | $0.023/GB-mo | Per GB per month |
| Blob Simple Ops | $0.0000004/op | Read/write |
| Blob Advanced Ops | $0.000005/op | Range, multipart |

### Requests

| Component | Rate | Notes |
|-----------|------|-------|
| Edge Requests | $0.000002/req | First 10M included |
| Function Invocations | $0.00006/invocation | First 100K included |

---

## Plans

| Plan | Price | Features |
|------|-------|----------|
| Hobby | FREE | Limited, no SLA |
| Pro | $20/mo | Team features, 100GB bandwidth |
| Enterprise | Custom | SSO, Audit Log, SLA |

### Plan Comparison
- **Hobby**: Single user, 100GB bandwidth/mo, no serverless functions
- **Pro**: Unlimited team members, 1TB bandwidth/mo, serverless functions, ISR
- **Pro Plus**: Everything in Pro + advanced features (Turbo builds, etc.)

---

## Cost Troubleshooting Checklist

When auditing a Vercel account:

### 1. Check Current Plan
```bash
curl -s -H "Authorization: Bearer $VERCEL_TOKEN" \
  "https://api.vercel.com/v2/teams/{teamId}" | jq '{plan: .billing.plan, status: .billing.status}'
```

### 2. Identify Expensive Line Items
- **Fast Origin Transfer** > 100GB = No caching configured
- **Build CPU Minutes** high = Too many deployments or Turbo builds
- **Blob Data Transfer** > 100GB = Heavy Blob storage usage
- **Fluid Compute** > $50 = Serverless usage issues

### 3. Check Deployment Activity
```bash
curl -s -H "Authorization: Bearer $VERCEL_TOKEN" \
  "https://api.vercel.com/v7/deployments?limit=100" | \
  jq '[.deployments[] | {date: (.createdAt/1000 | strftime("%Y-%m-%d")), project: .name, state: .state}] | group_by(.date) | .[] | {date: .[0].date, count: . | length}'
```

### 4. Check Build Machine Setting
```bash
curl -s -H "Authorization: Bearer $VERCEL_TOKEN" \
  "https://api.vercel.com/v2/teams/{teamId}" | jq '.resourceConfig.buildMachine'
```
- `"turbo"` = Most expensive
- `"standard"` or `"enhanced"` = Cheaper

### 5. Look for Unauthorized Integrations
Check audit events for:
- ChatGPT/Vercel App connections
- Third-party integrations with deployment permissions
- Unexpected tokens or access grants

```bash
curl -s -H "Authorization: Bearer $VERCEL_TOKEN" \
  "https://api.vercel.com/v2/events" | jq '.events[] | select(.type | contains("token") or contains("integration")) | {type, text}'
```

---

## Common Problems & Solutions

### Problem: High "Fast Origin Transfer" Bill

**Cause:** Content not being cached, served from origin on every request.

**Symptoms:**
- 6+ TB/month origin transfer
- Bill 50%+ from this line item

**Solutions:**
1. Add Cache-Control headers to responses
2. Enable ISR (Incremental Static Regeneration)
3. Use edge caching
4. Check for SSR on every request

**Reference:** https://vercel.com/docs/concepts/edge-network/overview

### Problem: High Build CPU Costs

**Cause:** 
- Too many deployments
- Turbo build machines enabled
- Failed deployments consuming resources

**Solutions:**
1. Switch from Turbo to Standard build machine
2. Disable auto-deploy on non-main branches
3. Delete unused projects
4. Clean up failed/blocked deployments

**Settings:** Dashboard → Project → Settings → General → Build & Development Settings

### Problem: High Blob Storage Costs

**Cause:**
- Storing large files in Vercel Blob
- Serving files directly from Blob (egress charges)

**Solutions:**
1. Audit which projects use Blob
2. Move to cheaper storage (AWS S3, Cloudflare R2)
3. Delete unused Blob data
4. Use CDN for file delivery

### Problem: Unauthorized Deployments

**Cause:** Third-party integration (e.g., ChatGPT, other AI tools) has deployment permissions.

**Symptoms:**
- 50+ deployments in short period
- Deployments from unexpected sources

**Solutions:**
1. Revoke integration permissions
2. Delete unused tokens
3. Review audit events for suspicious activity

---

## Subscription Management

### Downgrade to Hobby (Free)
```
Dashboard → Settings → Billing → Plan → Downgrade to Hobby
```

### Cancel Subscription
```
Dashboard → Settings → Billing → Cancel Subscription
```

**Note:** No API endpoint for subscription changes. Must use dashboard.

### Verify Downgrade
```bash
curl -s -H "Authorization: Bearer $VERCEL_TOKEN" \
  "https://api.vercel.com/v2/teams/{teamId}" | jq '{plan: .billing.plan, expiredSubscriptions: .billing.expiredSubscriptions}'
```

---

## Audit Workflow

When auditing a Vercel account:

### Step 1: Gather Credentials
1. Get token from GCP Secret Manager: `VERCEL_TOKEN`
2. Get team ID from API or dashboard

### Step 2: Download All Data
```bash
# Team info
curl -s -H "Authorization: Bearer $TOKEN" "https://api.vercel.com/v2/teams/{teamId}" > team_info.json

# Projects
curl -s -H "Authorization: Bearer $TOKEN" "https://api.vercel.com/v10/projects" > projects.json

# Deployments (last 100)
curl -s -H "Authorization: Bearer $TOKEN" "https://api.vercel.com/v7/deployments?limit=100" > deployments.json

# Billing charges (last 30 days)
curl -s -H "Authorization: Bearer $TOKEN" \
  "https://api.vercel.com/v1/billing/charges?from=$(date -d '30 days ago' +%Y-%m-%d)T00:00:00.000Z&to=$(date +%Y-%m-%d)T00:00:00.000Z&teamId={teamId}" > billing.json

# Audit events
curl -s -H "Authorization: Bearer $TOKEN" "https://api.vercel.com/v2/events" > events.json
```

### Step 3: Analyze
1. Check plan and billing status
2. Calculate cost breakdown
3. Identify top cost drivers
4. Find deployment patterns
5. Look for anomalies

### Step 4: Report
Generate audit report with:
- Current plan and status
- Monthly cost breakdown
- Top 5 cost drivers
- Recommendations
- Estimated savings

---

## Cost Optimization Checklist

| Priority | Action | Savings | Effort |
|----------|--------|---------|--------|
| 🔴 HIGH | Downgrade to Hobby | $20-500+/mo | 5 min |
| 🔴 HIGH | Switch Turbo → Standard builds | $30-50/mo | 5 min |
| 🔴 HIGH | Delete unused projects | Varies | 10 min |
| 🟡 MEDIUM | Add caching headers | $200-400/mo | 2-4 hrs |
| 🟡 MEDIUM | Disable auto-deploy | $20-40/mo | 10 min |
| 🟡 MEDIUM | Audit Blob usage | $30-50/mo | 1-2 hrs |
| 🟢 LOW | Enable ISR | Variable | 4-8 hrs |
| 🟢 LOW | Move to cheaper storage | Variable | 1-2 days |

---

## Secrets

| Secret | Purpose |
|--------|---------|
| `VERCEL_TOKEN` | Personal access token for API access |

---

## File Locations

| File | Description |
|------|-------------|
| `audit_report.json` | Structured audit data |
| `team_info_raw.json` | Raw team API response |
| `projects_raw.json` | Raw projects API response |
| `deployments_raw.json` | Raw deployments API response |
| `events.json` | Audit log events |
| `openapi_full.json` | Complete OpenAPI spec |

---

## External References

- **OpenAPI Spec:** https://openapi.vercel.sh/
- **Pricing:** https://vercel.com/pricing
- **Docs:** https://vercel.com/docs
- **Support:** support@vercel.com
- **Dashboard:** https://vercel.com/dashboard

---

## Common Error Codes

| Code | Meaning |
|------|--------|
| 400 | Bad Request - Invalid parameters |
| 401 | Unauthorized - Invalid token |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found |
| 429 | Rate Limited |
| 500 | Server Error |

---

*Last updated: 2026-06-16*
*For CFO-Cloud-PI v1.0*
