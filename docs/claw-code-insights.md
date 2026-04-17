# What We Actually Took From claw-code

**Setting expectations first**: `github.com/ultraworkers/claw-code` is **not** leaked Claude source code. It's a community-maintained Rust CLI agent harness (9 crates, ~20K LOC, defaults to `claude-opus-4-6`) and a philosophy document demonstrating one way to do "autonomous software development". There are no internal prompts, tool definitions, or proprietary Claude mechanisms to mine from it.

What we borrowed are *architectural patterns*, not code.

## Patterns that mapped cleanly

### 1. Notification routing outside the agent context window

claw-code's `clawhip` component watches git + GitHub + agent lifecycle events and pushes status to Discord. The point: status does not clutter the agent's context.

**Our translation**: the Stop hook at `~/.claude/scripts/handoff-on-stop.sh` appends session boundaries to `~/.claude/handoffs/YYYY-MM-DD.md`. You read the file between sessions; Claude never sees the log unless explicitly instructed to.

### 2. Architect / Executor / Reviewer roles

claw-code's `OmO` splits work across three specialized agents.

**Our translation**: the existing 10 domain agents + the gstack `/review` skill already do this. Specifically: `frontend-architect` (architect) → implementation in main context (executor) → `code-reviewer` or `/review` (reviewer). No new infra needed.

### 3. Human sets direction, agents execute

claw-code's tagline: "humans set direction; claws perform the labor."

**Our translation**: `/office-hours` → `/autoplan` is the direction-setting gate. Everything after is execution. `User Sovereignty` in the global `CLAUDE.md` reinforces the rule.

### 4. Long-running work without micromanagement

claw-code uses Discord so the human can check in async from mobile.

**Our translation**: background `Agent` invocations + periodic check-ins via the handoff file. No Discord dependency; the file is enough.

## Patterns that do NOT map

- **Discord as the primary interface.** Overkill for a solo builder working in a terminal. Adopt only if you want async mobile triage later.
- **The Rust binary itself.** No benefit — Claude Code already has the tools claw-code implements.
- **`clawhip`'s git/GitHub event plumbing.** GitHub notifications + `gh` CLI already cover this.

## When to revisit

If you start running 10+ parallel long-running agents and you can't keep track, re-read `PHILOSOPHY.md` and consider building a minimal `clawhip`-equivalent webhook receiver. Until then, the handoff-file pattern is enough.
