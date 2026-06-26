---
description: GCP Cloud Cost Management - CFO-grade playbook for Google Cloud billing analysis, cost optimization, and budget management. Use when working with GCP billing, BigQuery costs, Gemini API usage, Compute Engine, Cloud Run, or any Google Cloud cost analysis.
---

# GCP CFO Service (Cloud Cost Management)

**Purpose:** Audit, analyze, optimize, and manage Google Cloud Platform costs.

---

## Quick Reference

### Project ID
```
nursebridge-prep (development)
NurseBridge-Production (production)
```

### Billing Export Dataset
```
Dataset: billing_export
Project: concise-hire-6bc39
Table: gcp_billing_export_v1_01D0BC_3978F2_824033
```

### BigQuery Commands
```bash
# Query monthly costs
bq query --use_legacy_sql=false \
"SELECT EXTRACT(YEAR FROM usage_start_time) as year,
        EXTRACT(MONTH FROM usage_start_time) as month,
        SUM(cost) as total_cost
 FROM billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033
 GROUP BY year, month ORDER BY year DESC, month DESC"

# Query by service
bq query --use_legacy_sql=false \
"SELECT service.description as service, SUM(cost) as cost
 FROM billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033
 WHERE usage_start_time >= '2026-01-01'
 GROUP BY service ORDER BY cost DESC"

# Query by project
bq query --use_legacy_sql=false \
"SELECT project.name as project, SUM(cost) as cost
 FROM billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033
 WHERE usage_start_time >= '2026-01-01'
 GROUP BY project ORDER BY cost DESC"

# Query by SKU
bq query --use_legacy_sql=false \
"SELECT sku.description as sku, SUM(cost) as cost
 FROM billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033
 WHERE usage_start_time >= '2026-01-01'
 GROUP BY sku ORDER BY cost DESC LIMIT 50"

# Query specific service
bq query --use_legacy_sql=false \
"SELECT sku.description as sku, SUM(cost) as cost
 FROM billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033
 WHERE usage_start_time >= '2026-01-01'
   AND service.description = 'Gemini API'
 GROUP BY sku ORDER BY cost DESC"
```

---

## GCP Billing Schema

### Key Fields

| Field | Type | Description |
|-------|------|-------------|
| `billing_account_id` | STRING | Billing account identifier |
| `service.description` | STRING | Service name (e.g., "Gemini API") |
| `sku.description` | STRING | Specific SKU (e.g., "Text input tokens") |
| `cost` | FLOAT64 | Cost in billing currency |
| `usage.amount` | FLOAT64 | Usage quantity |
| `usage.unit` | STRING | Unit of measurement |
| `usage_start_time` | TIMESTAMP | When usage started |
| `project.name` | STRING | GCP project name |
| `project.id` | STRING | GCP project ID |
| `location.region` | STRING | Region (e.g., "us-central1") |
| `labels` | ARRAY | User-defined labels |
| `credits` | ARRAY | Applied credits/discounts |

---

## Known Cost Drivers

### Monthly Totals (2026)

| Month | Total Cost | Trend |
|-------|------------|-------|
| January | $10.80 | Low |
| February | $2,573.66 | SPIKE |
| March | $2,648.51 | SPIKE |
| April | $1,779.44 | High |
| May | $1,369.51 | Decreasing |
| June | $117.21 | MUCH BETTER |

### Top Services (All Time)

| Service | Total Cost | % of Total |
|---------|------------|------------|
| **Gemini API** | **$8,867** | 58% |
| Compute Engine | $2,132 | 14% |
| Cloud Run | $968 | 6% |
| Cloud SQL | $709 | 5% |
| Networking | $689 | 5% |
| Cloud Memorystore | $577 | 4% |
| Artifact Registry | $255 | 2% |
| Secret Manager | $109 | 1% |
| Cloud Storage | $82 | 1% |

### Top SKUs (Gemini - Biggest Cost)

| SKU | Total Cost |
|-----|------------|
| Gemini 3 Pro Long - Cached Input | $4,414 |
| Gemini 3 Pro Long - Input Tokens | $1,157 |
| Gemini 3 Flash - Cached Input | $853 |
| Gemini 3 Pro Short - Cached Input | $544 |
| Gemini 3 Pro Short - Input Tokens | $495 |
| Gemini 3 Flash - Input Tokens | $369 |
| Gemini 3 Pro Short - Output | $162 |
| Gemini 3 Pro Long - Output | $161 |

### Projects by Cost

| Project | Total Cost |
|---------|------------|
| NurseBridge-Production | $10,676 |
| nursebridge-prep | $3,430 |
| Calcom Scheduling Service | $314 |
| PrepPulse | $3 |

---

## Cost Troubleshooting Checklist

When auditing a GCP account:

### 1. Check Monthly Totals
```sql
SELECT EXTRACT(YEAR FROM usage_start_time) as year,
       EXTRACT(MONTH FROM usage_start_time) as month,
       SUM(cost) as total_cost
FROM billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033
GROUP BY year, month ORDER BY year DESC, month DESC
```

### 2. Identify Top Services
```sql
SELECT service.description, SUM(cost) as cost
FROM billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033
WHERE usage_start_time >= '2026-01-01'
GROUP BY service ORDER BY cost DESC
```

### 3. Drill Down by Project
```sql
SELECT project.name, SUM(cost) as cost
FROM billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033
WHERE usage_start_time >= '2026-01-01'
GROUP BY project ORDER BY cost DESC
```

### 4. Check for Anomalies
```sql
-- Day-by-day breakdown for current month
SELECT DATE(usage_start_time) as date, SUM(cost) as daily_cost
FROM billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033
WHERE usage_start_time >= '2026-06-01'
GROUP BY date ORDER BY date
```

### 5. Check Gemini API Usage (Biggest Cost)
```sql
SELECT sku.description, SUM(cost) as cost, SUM(usage.amount) as usage
FROM billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033
WHERE service.description = 'Gemini API'
  AND usage_start_time >= '2026-01-01'
GROUP BY sku ORDER BY cost DESC
```

### 6. Check for Unused Resources
```sql
-- Resources with zero cost (may be running idle)
SELECT project.name, service.description, COUNT(*) as records
FROM billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033
WHERE cost = 0 AND usage.amount > 0
GROUP BY project, service
```

---

## Common Problems & Solutions

### Problem: Gemini API Costs Too High

**Symptoms:**
- $8,867 total Gemini costs
- $7,238 in March 2026 alone
- Gemini 3 Pro Long cached tokens: $4,414

**Causes:**
1. Using expensive models (Gemini 3 Pro) when cheaper options available
2. No caching of prompts
3. Too many tokens being sent

**Solutions:**
1. Switch to Gemini Flash (70% cheaper)
2. Implement prompt caching
3. Optimize token usage
4. Add usage limits/budgets

**Reference:** https://cloud.google.com/gemini-api/pricing

### Problem: Compute Engine Costs High

**Symptoms:**
- $2,132 total Compute Engine costs
- $674 in April 2026

**Causes:**
1. Running VMs 24/7
2. Large instance sizes
3. Preemptible instances not used

**Solutions:**
1. Use preemptible instances for batch work
2. Right-size instances
3. Use committed use discounts
4. Consider spot VMs

### Problem: Cloud Run Costs

**Symptoms:**
- $968 total Cloud Run costs
- $449 in May 2026

**Causes:**
1. Instances running too long
2. Too many cold starts
3. Memory over-allocation

**Solutions:**
1. Set min instances to 0 (scale to zero)
2. Optimize memory allocation
3. Use concurrency settings
4. Check for memory leaks

### Problem: Cloud Memorystore (Redis)

**Symptoms:**
- $577 total Memorystore costs
- $222 in April 2026

**Causes:**
1. Instance too large for needs
2. Running in wrong region
3. Not using replication efficiently

**Solutions:**
1. Downsize instance
2. Use standard tier instead of enterprise
3. Check if actually needed

---

## Budget Management

### Set Budget Alerts
```bash
# Via gcloud
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Monthly Budget" \
  --budget-amount=5000 \
  --threshold-rule-threshold-percent=0.5,0.9,1.0 \
  --notification-channel=CHANNEL_ID
```

### Check Current Spending
```bash
# Current month spend
bq query --use_legacy_sql=false \
"SELECT SUM(cost) as current_spend
 FROM billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033
 WHERE usage_start_time >= '2026-06-01'"
```

---

## Optimization Checklist

| Priority | Action | Estimated Savings | Effort |
|----------|--------|-------------------|--------|
| 🔴 HIGH | Switch Gemini 3 Pro → Flash | $500-2000/mo | 1-2 hrs |
| 🔴 HIGH | Implement Gemini prompt caching | $200-500/mo | 2-4 hrs |
| 🔴 HIGH | Set Cloud Run min=0 | $100-300/mo | 10 min |
| 🟡 MEDIUM | Right-size Compute instances | $100-500/mo | 2-4 hrs |
| 🟡 MEDIUM | Downsize Memorystore | $50-150/mo | 30 min |
| 🟡 MEDIUM | Use preemptible VMs | $50-200/mo | 1 hr |
| 🟢 LOW | Enable committed use discounts | Variable | 10 min |
| 🟢 LOW | Clean up unused resources | $20-100/mo | 2-4 hrs |

---

## GCP Pricing Reference

### Compute Engine

| Machine Type | Cost/hr | Notes |
|--------------|---------|-------|
| e2-micro | $0.0084 | 2 vCPU, 1GB |
| e2-small | $0.0168 | 2 vCPU, 2GB |
| e2-medium | $0.0336 | 2 vCPU, 4GB |
| n1-standard-1 | $0.0475 | 1 vCPU, 3.75GB |
| n1-standard-2 | $0.095 | 2 vCPU, 7.5GB |

### Cloud Run

| Resource | Cost |
|----------|------|
| CPU | $0.00002400/vCPU-second |
| Memory | $0.00000250/GiB-second |
| Requests | Free (first 2M/mo) |

### Gemini API (As of 2026)

| Model | Input/1K tokens | Output/1K tokens |
|-------|-----------------|------------------|
| Gemini 3 Pro Long | $0.0035 | $0.0105 |
| Gemini 3 Pro Short | $0.0015 | $0.006 |
| Gemini 3 Flash | $0.00035 | $0.0007 |
| Gemini 2.5 Flash | $0.00015 | $0.0006 |

### Cloud Storage

| Class | $/GB/mo |
|-------|---------|
| Standard | $0.020 |
| Nearline | $0.010 |
| Coldline | $0.004 |
| Archive | $0.0012 |

### Cloud SQL

| Instance | $/hr |
|----------|------|
| db-f1-micro | $0.0175 |
| db-g1-small | $0.0525 |
| db-n1-standard-1 | $0.105 |

### Cloud Memorystore

| Tier | $/hr |
|------|------|
| Basic (1GB) | $0.045 |
| Standard (1GB) | $0.080 |

---

## Secrets & Access

| Secret | Purpose |
|--------|---------|
| `GOOGLE_SERVICE_ACCOUNT_JSON` | GCP API access |
| GCP Super Admin | Project admin rights |

### Required APIs
- BigQuery API
- Cloud Billing API
- Compute Engine API
- Cloud Run API
- Gemini API

---

## File Locations

| File | Description |
|------|-------------|
| `/home/claude-agent/gcp-audit/` | Audit data from real account |
| `monthly_costs.json` | Monthly cost breakdown |
| `services_costs.json` | Cost by service |
| `projects_costs.json` | Cost by project |
| `gemini_costs.json` | Gemini API cost breakdown |

---

## External References

- **GCP Pricing:** https://cloud.google.com/pricing
- **Gemini Pricing:** https://cloud.google.com/gemini-api/pricing
- **Compute Engine:** https://cloud.google.com/compute/vm-instance-pricing
- **Cloud Run:** https://cloud.google.com/run/pricing
- **Billing Export:** https://cloud.google.com/billing/docs/how-to/export-data-bigquery

---

## Common Error Codes

| Error | Meaning |
|-------|---------|
| Access Denied | Missing billing permissions |
| Not Found | Project/dataset doesn't exist |
| Quota Exceeded | API quota exceeded |
| Rate Limited | Too many requests |

---

## Audit Workflow

When auditing a GCP account:

### Step 1: Get Monthly Overview
```sql
SELECT EXTRACT(YEAR FROM usage_start_time) as year,
       EXTRACT(MONTH FROM usage_start_time) as month,
       SUM(cost) as total_cost
FROM billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033
GROUP BY year, month ORDER BY year DESC, month DESC
```

### Step 2: Identify Top Services
```sql
SELECT service.description, SUM(cost) as cost
FROM billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033
GROUP BY service ORDER BY cost DESC LIMIT 10
```

### Step 3: Identify Top SKUs
```sql
SELECT sku.description, SUM(cost) as cost
FROM billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033
GROUP BY sku ORDER BY cost DESC LIMIT 20
```

### Step 4: Identify Top Projects
```sql
SELECT project.name, SUM(cost) as cost
FROM billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033
GROUP BY project ORDER BY cost DESC
```

### Step 5: Day-by-Day Analysis
```sql
SELECT DATE(usage_start_time) as date,
       SUM(cost) as daily_cost
FROM billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033
WHERE usage_start_time >= '2026-06-01'
GROUP BY date ORDER BY date
```

### Step 6: Generate Report
Save findings to audit_report.json with:
- Monthly totals
- Service breakdown
- Project breakdown
- Top 10 SKUs
- Anomalies detected
- Recommendations

---

## Example Real Audit Results

From Dr. Uri's account (June 2026):

### Monthly Trend
| Month | Cost | Notes |
|-------|------|-------|
| Jan 2026 | $11 | Low (new account) |
| Feb 2026 | $2,574 | Gemini usage starts |
| Mar 2026 | $2,649 | PEAK - $7,238 Gemini alone |
| Apr 2026 | $1,779 | Decreasing |
| May 2026 | $1,370 | Further decrease |
| Jun 2026 | $117 | Major reduction |

### Key Insight
Gemini API costs dropped from $7,238 (March) to $37 (June) - 99.5% reduction!

---

*Last updated: 2026-06-16*
*For CFO-Cloud-PI v1.0*
