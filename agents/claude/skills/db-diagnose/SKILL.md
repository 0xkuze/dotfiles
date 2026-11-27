---
name: db-diagnose
description: Read-only performance or data diagnosis against a Postgres database (production or staging) — slow queries, EXPLAIN ANALYZE, missing indexes, bloat/vacuum, investigating a specific failing record. Use when the user asks to "diagnosticar en prod", "por qué tarda", "revisa en prod este registro", or analyze the queries behind a slow view.
---

# DB diagnose (read-only)

Find the database from the project (`AGENTS.md`, env var names, drizzle/prisma config, wrangler bindings). For Neon, use the Neon MCP (`list_projects`, `run_sql`, `explain_sql_statement`, `list_slow_queries`) or `neonctl`; otherwise `psql` with a connection string from env. Confirm with the user which environment (prod/staging) before querying.

Rules:
- **Read-only.** Only `SELECT`, `EXPLAIN`, `EXPLAIN (ANALYZE, BUFFERS)` on SELECTs, and `pg_stat_*` / catalog views. Never `INSERT/UPDATE/DELETE`, DDL, `VACUUM` or `CREATE INDEX` — write those as SQL for the user to run (`CREATE INDEX CONCURRENTLY` for production), ready to paste.
- `LIMIT` on exploratory queries. Don't paste PII (emails, tokens) into the chat — aggregate or mask.

Flow:
1. Find the exact query from the code path behind the slow view or failing record.
2. Measure: `EXPLAIN (ANALYZE, BUFFERS)`, table sizes, `pg_stat_user_tables` (seq scans, dead tuples, last vacuum/analyze), `pg_stat_statements` if enabled.
3. Identify the root cause (missing/unused index, N+1, bloat, bad plan, cold compute).
4. Reply in the user's language: cause, evidence (numbers), proposed fix (code and/or SQL), expected impact, deploy order and risks. Wait for the user's decision before any change.
