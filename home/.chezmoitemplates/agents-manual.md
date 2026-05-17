# AGENTS.md — Programming Rules

Agnostic coding conventions. Enforced across all languages.

## Languages

TypeScript, Go, Vue, React, Java, Python, Rust.

## Naming

- Short + descriptive.
- Verbs for functions: `fetchUsers`, `calculateTotal`, `parseConfig`.
- Nouns for variables: `users`, `totalCount`, `activeItems`.
- Booleans prefixed with `is`, `has`, `should`: `isActive`, `hasPermission`.

## Types

- Strict. No `any`, no `unknown` shortcuts.
- Explicit return types on all exported/public functions.
- Every interface/type fully defined. No shortcuts.

## Error Handling

- Early return. Minimal nesting.
- Handle the error, move on. No wrapping blocks.
- Plain errors: `throw new Error('message')`, `fmt.Errorf`, `errors.New`.
- No custom error hierarchy. No error classes.
- Wrap when re-raising: `fmt.Errorf("getUser %s: %w", id, err)`.

## Comments

- Sparse. Trust naming and code to explain.
- No JSDoc/godoc unless truly ambiguous.
- If code needs a comment, rename first.

## File Structure

- Feature-colocation by default: all related files in one flat directory.
- No subdirectories inside a feature module (no `components/`, `__tests__/`, `types/`). Tests sit next to implementation.
- Split to by-layer only when the project explicitly demands it.
- Every feature module has an `index.ts` / `index.go` that re-exports only the public API.
- One module per directory.

## Function Size

- Aim for 20–50 lines. Shorter is fine if the logic is complete and reads top-to-bottom.
- Trivial accessors (getters, finders, one-line returns) are always fine.
- No minimum line count. If a function does real work cleanly in 8 lines, that's good.
- Extract only when reused. No forced splits.
- No padding to hit a target.

## State Management (UI)

- Local state first. Composables (Vue) / hooks (React).
- Centralized store (Pinia / Zustand) only for genuinely global state.
- No store library for component-local state.

## Testing

- Integration-focused. Test behavior, not implementation.
- Prefer real dependencies. Avoid mocks.
- No mock frameworks. Use real DB, real API, real services when possible.
- Test critical paths and edge cases.

## Async

- Sequential by default.
- Parallel (`Promise.all`, goroutines) only when perf matters or ops are naturally independent.
- No premature parallelization.

## Dependencies

- Module-level imports. Dependencies come from imports.
- Pass as function arguments only when unavoidable.
- No DI frameworks. No constructor injection.

## Mutability

- Mutate freely. Simplicity over purity.
- No unnecessary spread/copy if in-place is clearer.

## Exports

- Private by default.
- Export only what consumers need.
- Minimal public surface.

## Concurrency

- Sequential unless forced.
- Concurrency only when no other option.
- No channels, mutexes, or goroutines unless the problem demands it.

## Logging

- **Boundary** (middleware/handler): structured error log on every failure.
- **Domain logic**: `logger.error` / `logger.warn` only. No info/debug.
- **Info**: only at real business events (created, completed, deleted). Not every step.
- Structured fields, not interpolated strings: `logger.info('order created', { orderId, total })`.

## Git Commits

- Conventional commits. Short imperative.
- `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`, `test:`.
- No long bodies unless context is truly needed.

## Imports

- Grouped and separated by blank lines:
  1. Standard library
  2. Third-party packages
  3. Local/project imports
- Within each group: sort by the imported identifier name, not the source path.

```typescript
import { readFile } from "fs";
import { writeFile } from "fs";

import express from "express";
import { z } from "zod";

import { auth } from "./middleware/auth";
import { config } from "./config";
import { db } from "./db";
```

```go
import (
    "context"
    "fmt"

    "github.com/gin-gonic/gin"

    "myapp/internal/store"
    "myapp/internal/user"
)
```

## General Principles

- Simple > clever.
- Less code > more code.
- Readable > clever.
- Real > mocked.
- Sequential > concurrent.
- Mutate > copy when simpler.
- Explicit > implicit.

