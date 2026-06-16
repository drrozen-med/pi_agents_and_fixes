---
description: CFO Bookkeeping service (Service 31) — invoice management, Drive ingestion, LLM extraction, GCP billing, BigCapital sync, and tax report workflow. Use when working on invoices, vendor expenses, tax reports, PDF ingestion from Drive, or accounting data.
---

# CFO Bookkeeping Service (Service 31)

Full-stack bookkeeping: Google Drive PDF ingestion → LLM extraction → quality gates → accounting sync.

## When to Use

- Working on invoices, vendor expenses, or cost tracking
- Tax report preparation (2024/2025)
- Ingesting PDFs from Google Drive into the CFO database
- Downloading vendor invoices from email portals
- Running LLM extraction on pending invoices
- Importing GCP billing data from BigQuery
- Syncing to BigCapital accounting system
- Building vendor expense reports or dashboards

## Master Plan

**Full 5-phase plan:** `tax_report_2024/PROGRESS.md`
**Drive hub:** `https://drive.google.com/drive/folders/1IaOUHH2Bq0OrYDbomwk3wrN_yYdtJeYe` (business Drive)

Phase 1: Fix ORM models → Phase 2: Collect docs (Drive + email + portals) → Phase 3: Ingest → Phase 4: LLM extract → Phase 5: Tax report assembly

### Document Sources (all flow into Drive, then into CFO DB)
1. **Google Drive** — existing PDFs (SonarCloud, Upwork zips, private expenses)
2. **Business email** (`dr.rozen@concise-med.com`) — 23 invoice notifications → download from vendor portals → upload to Drive
3. **Personal email** (`rozen.uri@gmail.com`) — pay slips, insurance, pension, receipts → download → upload to Drive
4. **Personal Drive** — scan for tax-relevant docs
5. **Form 106** — Dr. Rozen requests from 4 employers (Maccabi, Meuhedet, Miariet TA, Meditratrix)
6. **GCP billing** — import via BigQuery API

## Service Access

```
URL:     https://bookkeeping-cfo-972463294798.us-central1.run.app
Auth:    X-Admin-Service-Token: <BOOKKEEPING_CFO_SERVICE_TOKEN>
Token:   gcloud secrets versions access latest --secret=BOOKKEEPING_CFO_SERVICE_TOKEN --project=nursebridge-prep
Local:   uvicorn app.main:app --port 8018 (from services/31-bookkeeping_cfo/)
Swagger: http://localhost:8018/docs
```

## Database Tables (4 tables + 2 views)

### `vendors`
Provider registry. Seeded with: GCP, Vercel, OpenRouter, AWS, Upwork, Concise Nursing.
Key columns: `vendor_id`, `vendor_name` (UNIQUE), `vendor_code`, `category`, `gcp_account_id`, `bigcapital_id`.

### `cost_invoices`
Main invoice storage (230 records as of Apr 2026).
Key columns: `invoice_id`, `file_id` (Drive ID), `file_name`, `folder_path`, `folder_year`, `vendor_id` FK, `vendor_name`, `invoice_number`, `invoice_date`, `due_date`, `amount` (NOT `total_amount`), `tax_amount`, `subtotal`, `currency`, `extracted_text`, `gdrive_link`, `quality_score`, `validation_status`, `status`, `bigcapital_journal_id`, `synced_at`.

Statuses: `pending` → `ready` (passed) / `flagged` (failed) → `synced` (BigCapital)

### `gcp_billing_data`
GCP cost line items. Imported from BigQuery via `POST /api/v1/gcp/import`.
View: `gcp_monthly_costs` — monthly cost by service.

### `extraction_log`
Audit trail for every LLM extraction attempt. Loud failure tracking.
View: `extraction_quality_summary` — daily stats.

## API Endpoints

### Core Invoice CRUD
```
GET    /api/v1/invoices              List (filters: status, vendor_id, year, limit, offset)
GET    /api/v1/invoices/{id}         Single invoice
POST   /api/v1/invoices              Create manually
PATCH  /api/v1/invoices/{id}         Update
DELETE /api/v1/invoices/{id}         Delete
GET    /api/v1/invoices/stats/summary  Stats (total, passed, flagged, pending, amounts)
```

### LLM Extraction
```
POST   /api/v1/invoices/{id}/extract  Run Qwen Flash extraction + quality gate
```
Extracts: amount, date, vendor, invoice_number. Quality gate: score ≥ 0.70 + critical fields.

### Drive Ingestion
```
POST   /api/v1/ingest                 Ingest PDFs from Drive folder
GET    /api/v1/ingest/folder/{id}/preview  Preview PDFs without ingesting
```
Body: `{"folder_url": "<drive-url-or-id>", "vendor_id": null, "dry_run": false}`

### GCP Billing
```
POST   /api/v1/gcp/summary           Monthly cost by service
GET    /api/v1/gcp/anomalies         Billing anomalies
POST   /api/v1/gcp/import            Import from BigQuery
```

### Vendors & Sync
```
GET    /api/vendors                   List vendors
POST   /api/v1/sync/bigcapital        Sync invoices to BigCapital
```

### Health
```
GET    /health                        {status, db_connected, total_invoices, tables}
```

## Invoice Processing Flow

```
1. POST /api/v1/ingest (Drive folder)
   → Downloads PDFs, extracts text via pypdf
   → Creates cost_invoices rows with status='pending'

2. POST /api/v1/invoices/{id}/extract
   → Sends extracted_text to Qwen Flash LLM
   → LLM returns: amount, date, vendor, invoice_number
   → Quality gate validates (score ≥ 0.70)
   → Records attempt in extraction_log (LOUD FAILURE)
   → Updates: status='ready' (pass) or 'flagged' (fail)

3. POST /api/v1/sync/bigcapital
   → Syncs ready invoices to BigCapital accounting
   → Updates: status='synced'
```

## Known Bug: ORM ↔ DB Mismatch

The SQLAlchemy ORM models don't match the actual DB schema from migrations. This causes 500 errors on writes.

| Model File | Bug | Fix |
|------------|-----|-----|
| `models/vendor.py` | `__tablename__ = "cost_vendors"` | Change to `"vendors"` |
| `models/vendor.py` | FK in invoice points to `cost_vendors` | Change to `"vendors"` |
| `models/invoice.py` | Column `document_path` | Rename to `folder_path` |
| `models/invoice.py` | Column `total_amount` | Rename to `amount` |
| `models/invoice.py` | Column `payment_date` | Remove (doesn't exist) |
| `models/invoice.py` | Column `bigcapital_bill_id` | Rename to `bigcapital_journal_id` |
| `models/invoice.py` | Column `bigcapital_payment_id` | Remove, add `synced_at` |
| `models/invoice.py` | Missing columns | Add: `vendor_name`, `folder_year`, `file_path` |

After fixing ORM, redeploy: `gcloud run deploy bookkeeping-cfo --source . ...`

## Tax Report Workflow

### 2024 Tax Report for Accountant Ratzy Kontzki

1. **Gather documents** from personal Drive + business Drive
2. **Ingest vendor invoices** from Drive via CFO API
3. **Run LLM extraction** on all pending invoices
4. **Export data** for accountant (CSV or vendor×month table)
5. **Accountant files** the tax return

### Key Drive Locations
- 2024 accounting folder: `1IaOUHH2Bq0OrYDbomwk3wrN_yYdtJeYe`
- SonarCloud invoices: `1p-amv_hz7VeikgqadcHI_Xe3KCHcyswZ`
- Business email: `dr.rozen@concise-med.com` (notification-only, no PDF attachments)

### Quick Query: 2025 Invoices
```sql
SELECT c.invoice_date, v.vendor_name, c.invoice_number,
       c.amount, c.tax_amount, c.currency, c.validation_status
FROM cost_invoices c
LEFT JOIN vendors v ON c.vendor_id = v.vendor_id
WHERE c.invoice_date >= '2025-01-01' AND c.invoice_date <= '2025-12-31'
ORDER BY c.invoice_date;
```

## Module Map

```
services/31-bookkeeping_cfo/
├── app/
│   ├── models/
│   │   ├── vendor.py         ⚠️ tablename bug
│   │   ├── invoice.py        ⚠️ column mismatches
│   │   ├── gcp_billing.py    ✓ matches DB
│   │   └── extraction_log.py ✓ matches DB
│   ├── routers/
│   │   ├── invoices.py       CRUD + LLM extraction endpoint
│   │   ├── ingestion.py      Drive folder → PDF → DB
│   │   ├── vendors.py        Vendor CRUD
│   │   ├── gcp_billing.py    BigQuery import + analysis
│   │   └── bigcapital.py     BigCapital sync
│   ├── services/
│   │   ├── ingestion.py      Drive API, PDF text extraction (pypdf)
│   │   ├── llm_extractor.py  Qwen Flash extraction
│   │   ├── quality_gate.py   Score calculation + validation
│   │   ├── gcp_billing.py    BigQuery queries
│   │   └── bigcapital_sync.py BigCapital API client
│   └── schemas.py            Pydantic models
├── migrations/                Raw SQL (001-004) — source of truth for schema
├── README.md                  Full documentation
└── requirements.txt
```

## Secrets (all in GCP Secret Manager)

| Secret | Purpose |
|--------|---------|
| `DATABASE_URL` | PostgreSQL connection string |
| `OPENROUTER_API_KEY` | LLM extraction (Qwen Flash) |
| `BIGCAPITAL_API_KEY` | BigCapital accounting sync |
| `GOOGLE_SERVICE_ACCOUNT_JSON` | Drive API access (business Drive) |
| `BOOKKEEPING_CFO_SERVICE_TOKEN` | Service auth token |

## Deployment

```bash
cd services/31-bookkeeping_cfo
gcloud run deploy bookkeeping-cfo \
  --project nursebridge-prep --region us-central1 \
  --source . --allow-unauthenticated \
  --service-account gcp-super-admin@nursebridge-prep.iam.gserviceaccount.com \
  --set-env-vars "ENVIRONMENT=production" \
  --update-secrets "DATABASE_URL=DATABASE_URL:latest" \
  --update-secrets "OPENROUTER_API_KEY=OPENROUTER_API_KEY:latest" \
  --update-secrets "BIGCAPITAL_API_KEY=BIGCAPITAL_API_KEY:latest" \
  --update-secrets "GOOGLE_SERVICE_ACCOUNT_JSON=GOOGLE_SERVICE_ACCOUNT_JSON:latest"
```
