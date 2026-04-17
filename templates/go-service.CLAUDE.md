# Go Service Project — Claude Instructions

## Stack
- Go 1.22+. Modules, not GOPATH.
- stdlib-first. `net/http` + `chi` router only when needed.
- DB: `database/sql` + pgx; migrations via `goose` or `migrate`.
- Logs: `log/slog` (stdlib). Errors: `errors.Join` + `%w`.
- Deploy: Docker → Fly.io, Railway, or Cloud Run.

## Non-negotiables
- Test: `go test -race ./...`. Table-driven tests; integration tests hit real Postgres in CI.
- Lint: `go vet ./...` + `golangci-lint run`. Format: `gofmt -s -w`.
- Coverage floor: 80% on new packages. `go test -coverprofile=...`.
- Binary size budget: < 30 MB for a single service.

## File conventions
- `cmd/<binary>/main.go` — only `main()` and flag parsing. No business logic.
- `internal/<package>/` — business logic. `internal/` enforces boundary.
- `pkg/<package>/` — public libraries (rare; prefer `internal/`).
- No package-level mutable state except metrics and structured logger.

## Workflow hooks
- `/investigate` before coding any bug fix in Go — race conditions look like logic bugs and vice versa.
- `/review` required before any PR.

## Known gotchas
- `time.Now().UTC()` vs `time.Now()`: never mix. Pick one at the DB boundary.
- `sync.Pool` is easy to misuse; benchmark before adding one.
- Goroutine leaks: every `go func()` must have a cancel path via `context.Context`.
- `interface{}` at API boundaries is a smell; use generics (1.18+).

## Reuse
- Agents: `golang-pro`, `backend-architect`, `database-architect`.
- Skills: `/office-hours`, `/autoplan`, `/plan-eng-review`, `/investigate`, `/review`, `/ship`.
