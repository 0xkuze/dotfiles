---
name: dev-up
description: Start the current project's services locally (backend, frontend, desktop app, demos) in the background and verify each one responds. Use when the user says "levanta en local", "lanza la app", "launch the app", "abre la app de nuevo".
---

# Dev up

1. Discover how to run the project: `AGENTS.md`/`CLAUDE.md`, `README`, `package.json` scripts (`dev`, `start`), `docker-compose`, `Makefile`. For multi-repo setups, also check sibling repos the task involves. Start only what the task needs.
2. Check for already-running instances (`lsof -nP -iTCP -sTCP:LISTEN`) and reuse them instead of starting duplicates. To restart, kill only that process by port/PID — no broad `pkill`.
3. Start each service in the background (Claude Code: Bash `run_in_background`; Codex: a background terminal session); wait for readiness on its output ("Ready", "Local:", a URL) — Monitor in Claude Code, never `sleep` loops.
4. Verify: `curl -sf` the backend and frontend URLs; for desktop apps, confirm the window process is up.
5. Point services at local or preview backends as the user asks; read the needed env var names from the repo and ask for missing values.
6. Reply with the URLs and the background task IDs so they can be stopped later.
