---
name: release
description: Release a new version of the current project (app, package or service) — version bump, build, publish and verify. Use when the user says "lanza la x.y.z", "saca un hotfix", "lanza una nueva versión", "publica el paquete" or asks for a built installer.
---

# Release

Releasing is a deploy: proceed only if the user asked for this release in this task (that request is the authorization; don't ask again).

1. Discover how this project releases before running anything: `AGENTS.md`/`CLAUDE.md`, `README`, `package.json` scripts (`release`, `publish`, `dist`), release scripts under `scripts/`, CI workflows (`.github/workflows`), changesets/semantic-release config. Follow what it defines; if nothing defines it, propose the steps and ask.
2. `git fetch origin`, detect the default branch (`gh repo view --json defaultBranchRef`), confirm a clean tree on it. Hotfixes branch from the updated remote default.
3. Show what ships: `git log --oneline <last-tag>..HEAD`.
4. Version: patch by default unless the user names a version or it's a feature release. Never reuse an existing tag.
5. Missing secrets: tell the user the key name and where it goes (e.g. their secret manager); never print secret values.
6. Run the build/release in the background and wait on its output (Monitor in Claude Code), not `sleep`.
7. Verify the result exists where users get it (GitHub release and artifacts, registry version, update feed, deployed version) — show the evidence.
8. Reply in the user's language: version, links, what was verified, anything pending.
