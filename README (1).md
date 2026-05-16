# GCA Cybersecurity Risk Scoring — SQL Project

A relational database redesign of the data pipeline powering the [GCA Cybersecurity Training Effectiveness Chatbot](https://github.com/stevo9494/Chatbot) — a local AI assistant built for the Global Cyber Alliance capstone project.

The original system reads two Excel files at runtime and exposes them through a Python Data Access Layer (DAL). This project replaces that Excel backend with a normalized PostgreSQL schema, implements the same four DAL queries as SQL, and adds six additional analytical queries covering validation, window functions, and intervention impact analysis.

---

## Why this project exists

The chatbot's DAL was deliberately designed behind an abstract interface so the data backend could be swapped without touching the rest of the system. This repo is that swap — a PostgreSQL implementation that could replace the Excel backend with a one-line change to `.env`.

It also demonstrates the SQL skills directly relevant to data validation roles: population checks, integrity validation, month-over-month trend analysis, and ranked reporting.

---

## Repository structure

```
gca-sql-project/
├── schema/
│   ├── 01_schema.sql       — table definitions, constraints, indexes
│   └── 02_seed_data.sql    — synthetic data (72 rows × 2 tables, matching original Excel)
├── queries/
│   └── analytical_queries.sql  — 10 queries covering the full analytical surface
└── README.md
```

---

## Schema overview

```
organizations
    └── role_groups  (6 groups: Engineer, Finance, HR, Managers, Sales, Technical)
            ├── risk_scores               (one row per group per month)
            ├── training_effectiveness    (one row per group per month)
            └── interventions             (actions deployed + target metrics)
```

Both fact tables share the join key `(org_id, role_group_id, month)` — the same grain as the original Excel files.

---

## Queries at a glance

| # | Query | Skills |
|---|-------|--------|
| 1 | Headcount-weighted org risk profile (most recent month) | JOIN, subquery, aggregation |
| 2 | Training effectiveness summary (most recent month) | JOIN, subquery, aggregation |
| 3 | Full monthly history for a given role group | 3-table JOIN, ORDER BY |
| 4 | Risk tier distribution over time | GROUP BY, COUNT |
| 5 | Month-over-month risk score change | `LAG()` window function, CTE |
| 6 | Intervention impact: risk score before vs. 3 months after | CTE, self-JOIN, date arithmetic |
| 7 | Role groups in High tier for 3+ consecutive months | Subquery, HAVING |
| 8 | Click rate vs. reporting rate awareness gap | Computed columns, CASE |
| 9 | Data validation: orphan rows across both fact tables | LEFT JOIN, UNION ALL, IS NULL |
| 10 | End-of-year ranked summary with incident rate | CTE, `RANK()` window function |

---

## Running locally

### Prerequisites

- PostgreSQL 14+
- `psql` CLI

### Setup

```bash
# Create the database
createdb gca_risk_db

# Load schema
psql -d gca_risk_db -f schema/01_schema.sql

# Load seed data
psql -d gca_risk_db -f schema/02_seed_data.sql

# Run queries
psql -d gca_risk_db -f queries/analytical_queries.sql
```

### Run a single query

```bash
psql -d gca_risk_db -c "\i queries/analytical_queries.sql"
```

Or open `analytical_queries.sql` in any SQL client (DBeaver, DataGrip, pgAdmin) connected to `gca_risk_db`.

---

## Data notes

- Synthetic data modeled after real GCA Excel files (`risk_scoring.xlsx`, `training_effectiveness_monthly.xlsx`)
- 6 role groups × 12 months = 72 rows per fact table
- Risk scores trend downward (improving) across the year, with Finance and Sales starting High and recovering to Medium/Low following interventions deployed in Q1–Q2
- Query 9 (data validation) is expected to return 0 rows — all records are complete across both tables

---

## Connection to the chatbot project

The DAL methods this schema replaces:

| DAL method | Equivalent query |
|---|---|
| `get_org_profile(org_id)` | Query 1 |
| `get_metric_summary(org_id)` | Query 2 |
| `get_user_history(role_group)` | Query 3 |
| *(not in original DAL)* | Queries 4–10 |

The `DataBackend` ABC in `src/data/base.py` means a `PostgreSQLBackend` class implementing these queries could replace `ExcelBackend` with no changes to the router, session builder, or tests.

---

## Skills demonstrated

- Schema design: normalization, foreign keys, check constraints, unique constraints, indexes
- Joins: two- and three-table joins, self-joins, left joins for validation
- Aggregations: `SUM`, `AVG`, `COUNT`, `ROUND`, `HAVING`
- Window functions: `LAG()`, `RANK()`, `PARTITION BY`
- CTEs: multi-step query decomposition
- Data validation: orphan row detection with `UNION ALL` and `IS NULL` checks
- Date arithmetic: interval-based before/after comparisons
