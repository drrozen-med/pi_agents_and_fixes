# Vercel CFO - Reusable Prompts

## Audit Vercel Account

```
Audit the Vercel account for team [TEAM_ID] with token [VERCEL_TOKEN].

1. Get team info and check current plan/billing status
2. List all projects and count them
3. List recent deployments (last 100) and analyze patterns
4. Get billing charges for the last 30 days
5. Identify top cost drivers and explain each one in plain English
6. Look for anomalies (too many deploys, unexpected usage, etc.)
7. Provide cost optimization recommendations with estimated savings

Save findings to audit_report.json with:
- team info
- project list
- deployment stats
- billing breakdown
- top 5 cost drivers
- recommendations
```

## Explain Unexpected Bill

```
I received a $X bill from Vercel that I didn't expect.

Token: [VERCEL_TOKEN]
Team: [TEAM_ID]

Please:
1. Get my current plan and billing status
2. Download my latest invoice/billing data
3. List all my projects and their recent deployment activity
4. Identify what is causing the high costs
5. Explain in plain English why I'm being charged
6. Provide specific recommendations to reduce costs

Focus on:
- Fast Origin Transfer (uncached data)
- Build CPU usage (deployments)
- Blob storage (if applicable)
- Any suspicious activity
```

## Stop Vercel Billing

```
I need to immediately stop billing on my Vercel account.

Token: [VERCEL_TOKEN]  
Team: [TEAM_ID]

Please:
1. Verify current plan and billing status
2. Downgrade to free Hobby plan (via API or explain how)
3. Delete unused projects that may be causing costs
4. Verify billing has stopped
5. Confirm no pending invoices

Warn me if there are any live sites that will go down.
```

## Request Vercel Refund

```
I want to request a refund from Vercel for unexpectedly high charges.

Token: [VERCEL_TOKEN]
Team: [TEAM_ID]

Please:
1. Compile a summary of my billing history
2. Identify the root cause of high charges (misconfiguration, etc.)
3. Draft a polite email to support@vercel.com asking for:
   - Explanation of charges
   - Potential refund or credit
   - Confirmation of plan downgrade
4. Include specific invoice amounts and dates
5. Suggest I'm switching to free plan and fixing the issues

Keep the tone professional and non-demanding.
```

## Optimize Vercel Costs

```
I want to optimize my Vercel costs. Current bill is approximately $X/month.

Token: [VERCEL_TOKEN]
Team: [TEAM_ID]

Please:
1. Audit current usage and billing
2. Identify all cost optimization opportunities
3. For each opportunity, calculate estimated savings
4. Create a prioritized action plan:
   - Quick wins (5 min): Settings changes
   - Medium effort (1-2 hrs): Code/config changes
   - Long term (1+ days): Architecture changes
5. Provide specific API calls or dashboard steps for each fix
6. Estimate total monthly savings if all recommendations are implemented

Common optimizations:
- Switch from Turbo to Standard build machines
- Add caching headers
- Reduce deployment frequency
- Delete unused projects
- Move Blob storage to cheaper alternative
```

## Investigate Deployment Spam

```
I'm seeing way too many deployments in my Vercel account.

Token: [VERCEL_TOKEN]
Team: [TEAM_ID]

Please:
1. List all deployments for the last 30 days
2. Group by date to show deployment patterns
3. Group by project to identify which project(s) are affected
4. Check audit events for any integrations or tokens that may be causing auto-deploys
5. Look for ChatGPT or other AI tool integrations
6. Identify if any deployments are failing repeatedly
7. Recommend how to stop the spam (revoke tokens, disable auto-deploy, etc.)
```

## Generate Cloud Engineer Tickets

```
Create GitHub-ready issues for a cloud engineer to fix Vercel cost problems.

Token: [VERCEL_TOKEN]
Team: [TEAM_ID]

Please:
1. Audit the account and identify all cost issues
2. Create separate issue files for each problem:
   - Issue 1: Build machine costs
   - Issue 2: Origin transfer costs (no caching)
   - Issue 3: Blob storage costs
   - Issue 4: Excessive deployments
   - Issue 5: Summary
3. Each issue should include:
   - Problem description
   - Evidence (API data, costs, etc.)
   - Root cause
   - Investigation steps
   - Recommended fix
   - Estimated savings
   - References to Vercel docs

Save to github-issues/ folder with numbered filenames.
```

## Compare Vercel vs Alternatives

```
Compare Vercel hosting to alternatives for my use case.

Current usage:
- [X] projects
- ~$[AMOUNT]/month bill
- [TYPE] of sites (static, SSR, API, etc.)
- Need: [REQUIREMENTS]

Please:
1. Explain my current Vercel costs
2. Estimate costs on:
   - Netlify
   - Cloudflare Pages
   - AWS Amplify
   - Google Cloud Run
   - DigitalOcean App Platform
3. Compare features vs Vercel
4. Estimate savings from switching
5. Recommend best alternative with reasoning
```

---

## Template Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `[VERCEL_TOKEN]` | API token | `vcp_xxx...` |
| `[TEAM_ID]` | Team ID | `team_xxx...` |
| `[AMOUNT]` | Bill amount | `545.69` |
| `[X]` | Generic number | `20` |

---

*Use these prompts as templates for Vercel CFO tasks*
