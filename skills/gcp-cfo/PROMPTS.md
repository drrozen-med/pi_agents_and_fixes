# GCP CFO - Reusable Prompts

## Audit GCP Account

```
Audit the GCP account for project [PROJECT_ID].

Use BigQuery billing export:
- Dataset: billing_export
- Table: gcp_billing_export_v1_01D0BC_3978F2_824033

1. Get monthly cost totals for the last 6 months
2. Identify top 5 services by cost
3. Identify top 5 SKUs by cost
4. Identify costs by project
5. Look for anomalies (sudden spikes, unexpected services)
6. Calculate total spend and trend

Report findings in plain English with:
- Monthly breakdown
- Service breakdown
- Top cost drivers
- Anomalies detected
- Recommendations for cost reduction
```

## Explain Unexpected GCP Bill

```
I received an unexpectedly high GCP bill.

Project: [PROJECT_ID]
Billing table: billing_export.gcp_billing_export_v1_01D0BC_3978F2_824033

Please:
1. Query the last 3 months of billing data
2. Identify the top cost drivers
3. Explain in plain English why each cost exists
4. Identify any anomalies or unexpected usage
5. Recommend how to reduce costs

Focus on:
- Gemini API usage (often the biggest cost)
- Compute Engine instances
- Cloud Run services
- Any services with unexpected costs
```

## Stop GCP Costs

```
I need to immediately stop unexpected GCP costs.

Project: [PROJECT_ID]

Please:
1. Query current month spend
2. Identify the services causing costs
3. For each service, explain:
   - What it is
   - How to stop/pause it
   - Risk of stopping
4. Prioritize by cost impact

Common quick wins:
- Cloud Run: Set min instances to 0
- Compute: Stop VMs
- Gemini: Add API key restrictions
```

## Optimize Gemini Costs

```
I want to reduce my Gemini API costs. Currently paying $X/month.

Project: [PROJECT_ID]

Please:
1. Query Gemini API usage by SKU
2. Identify which models are being used
3. Calculate savings from switching to cheaper models:
   - Gemini 3 Flash (90% cheaper than Pro)
   - Prompt caching (saves 90% on repeated tokens)
4. Provide code changes needed
5. Estimate monthly savings

Current models in use:
[Query from billing data]
```

## Set GCP Budget Alert

```
Set up budget alerts for my GCP project.

Project: [PROJECT_ID]
Billing Account: [BILLING_ACCOUNT_ID]

Please:
1. Create a $500/month budget alert
2. Create a $1000/month budget alert
3. Set up email notifications
4. Explain how to add more thresholds

Use gcloud billing budgets commands.
```

## Find Unused GCP Resources

```
Find unused or idle GCP resources that are costing money.

Project: [PROJECT_ID]

Please:
1. Query for services with high cost but low usage
2. Identify Compute instances running 24/7
3. Find Cloud Run services with min instances > 0
4. Check for oversized Memorystore instances
5. Look for services with zero usage but still running

Query the billing table for:
- Low usage / high cost ratios
- Services running continuously
```

## Generate GCP Engineer Tickets

```
Create GitHub-ready issues for a cloud engineer to fix GCP cost problems.

Project: [PROJECT_ID]

Please:
1. Audit the account
2. Create separate issue files for each problem:
   - Issue 1: Gemini API optimization
   - Issue 2: Compute Engine rightsizing
   - Issue 3: Cloud Run optimization
   - Issue 4: Unused resources cleanup
   - Issue 5: Summary
3. Each issue should include:
   - Problem description
   - Evidence (costs, usage)
   - Root cause
   - Investigation steps
   - Recommended fix
   - Estimated savings
   - gcloud commands if applicable

Save to github-issues/ folder.
```

## Compare GCP vs Alternatives

```
Compare GCP services to alternatives for cost optimization.

Current usage:
- Gemini API: $[AMOUNT]/month
- Compute Engine: $[AMOUNT]/month
- Cloud Run: $[AMOUNT]/month

Please:
1. Compare Gemini API vs OpenAI, Anthropic, Groq
2. Compare Compute Engine vs AWS EC2, Azure VMs
3. Compare Cloud Run vs AWS Lambda, Azure Functions
4. Estimate savings from switching
5. Recommend best alternatives
```

## Monthly Cost Report

```
Generate a monthly cost report for GCP.

Project: [PROJECT_ID]
Month: [MONTH, e.g., June 2026]

Please:
1. Query all costs for the month
2. Break down by service
3. Break down by project (if multi-project)
4. Compare to previous month
5. Calculate day-by-day trend
6. Identify any anomalies
7. Generate executive summary

Format as:
- Executive summary (3 bullet points)
- Detailed breakdown
- Trend analysis
- Recommendations
```

## Optimize Cloud Run

```
Optimize Cloud Run costs.

Project: [PROJECT_ID]

Please:
1. Query Cloud Run usage from billing data
2. Identify services with high cost
3. For each service, check:
   - Min instances (should be 0)
   - Memory allocation
   - Concurrency settings
4. Calculate potential savings from:
   - Scaling to zero
   - Memory optimization
   - Concurrency tuning

Provide specific gcloud commands to apply changes.
```

## Request GCP Credit

```
I want to request a credit from GCP for unexpected charges.

Project: [PROJECT_ID]

Please:
1. Compile billing history showing usage pattern
2. Identify the root cause of unexpected costs
3. Draft a polite email to GCP support asking for:
   - Explanation of the charges
   - Potential credit or adjustment
   - Ways to prevent future issues
4. Include:
   - Timeline of charges
   - Service breakdown
   - Steps taken to fix

Keep tone professional and non-demanding.
```

---

## Template Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `[PROJECT_ID]` | GCP project ID | `nursebridge-prep` |
| `[BILLING_ACCOUNT_ID]` | Billing account | `XXXXX-XXXXX-XXXXX` |
| `[AMOUNT]` | Dollar amount | `5000` |
| `[MONTH]` | Month/Year | `June 2026` |

---

*Use these prompts as templates for GCP CFO tasks*
