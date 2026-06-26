# GCP CFO - Quick Reference Card

## AUTH
```bash
# Uses gcloud CLI (no token needed if configured)
gcloud auth application-default login
gcloud config set project nursebridge-prep
```

## DATASET
```
Project: concise-hire-6bc39
Dataset: billing_export
Table: gcp_billing_export_v1_01D0BC_3978F2_824033
```

## QUICK COMMANDS

### Monthly totals
```sql
SELECT EXTRACT(YEAR FROM usage_start_time) as y,
       EXTRACT(MONTH FROM usage_start_time) as m,
       SUM(cost) as cost
FROM billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033
GROUP BY y, m ORDER BY y DESC, m DESC
```

### By service
```sql
SELECT service.description, SUM(cost) as cost
FROM billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033
GROUP BY service ORDER BY cost DESC
```

### By project
```sql
SELECT project.name, SUM(cost) as cost
FROM billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033
GROUP BY project ORDER BY cost DESC
```

### By SKU (detailed)
```sql
SELECT sku.description, SUM(cost) as cost
FROM billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033
GROUP BY sku ORDER BY cost DESC LIMIT 50
```

### Current month
```sql
SELECT SUM(cost) FROM billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033
WHERE usage_start_time >= '2026-06-01'
```

## COST THRESHOLDS
| Service | Normal | Warning | Critical |
|---------|--------|---------|----------|
| Gemini API | <$100/mo | $100-500 | >$500 |
| Compute Engine | <$100/mo | $100-300 | >$300 |
| Cloud Run | <$50/mo | $50-200 | >$200 |
| Cloud SQL | <$50/mo | $50-150 | >$150 |

## PRICING SNAPSHOT
| Service | Cost |
|---------|------|
| Gemini Flash | $0.00035/1K in |
| Gemini 3 Pro | $0.0035/1K in |
| Cloud Run CPU | $0.000024/vCPU-sec |
| e2-micro | $0.0084/hr |

## ALERTS
```bash
gcloud billing budgets create \
  --billing-account=XXXXX \
  --display-name="Budget Alert" \
  --budget-amount=1000 \
  --threshold-rule-threshold-percent=0.8
```

## GEMINI SWITCH
```
Old: Gemini 3 Pro Long - $3.50/1K tokens
New: Gemini Flash - $0.35/1K tokens
SAVINGS: 90%
```
