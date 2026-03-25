# CLI Reference

Paperplane CLI now supports both:

- instance setup/diagnostics (`onboard`, `doctor`, `configure`, `env`, `allowed-hostname`)
- control-plane client operations (issues, approvals, agents, activity, dashboard)

## Base Usage

Use repo script in development:

```sh
pnpm paperplaneai --help
```

First-time local bootstrap + run:

```sh
pnpm paperplaneai run
```

Choose local instance:

```sh
pnpm paperplaneai run --instance dev
```

## Deployment Modes

Mode taxonomy and design intent are documented in `doc/DEPLOYMENT-MODES.md`.

Current CLI behavior:

- `paperplaneai onboard` and `paperplaneai configure --section server` set deployment mode in config
- runtime can override mode with `PAPERPLANE_DEPLOYMENT_MODE`
- `paperplaneai run` and `paperplaneai doctor` do not yet expose a direct `--mode` flag

Target behavior (planned) is documented in `doc/DEPLOYMENT-MODES.md` section 5.

Allow an authenticated/private hostname (for example custom Tailscale DNS):

```sh
pnpm paperplaneai allowed-hostname dotta-macbook-pro
```

All client commands support:

- `--data-dir <path>`
- `--api-base <url>`
- `--api-key <token>`
- `--context <path>`
- `--profile <name>`
- `--json`

Company-scoped commands also support `--company-id <id>`.

Use `--data-dir` on any CLI command to isolate all default local state (config/context/db/logs/storage/secrets) away from `~/.paperplane`:

```sh
pnpm paperplaneai run --data-dir ./tmp/paperplane-dev
pnpm paperplaneai issue list --data-dir ./tmp/paperplane-dev
```

## Context Profiles

Store local defaults in `~/.paperplane/context.json`:

```sh
pnpm paperplaneai context set --api-base http://localhost:3100 --company-id <company-id>
pnpm paperplaneai context show
pnpm paperplaneai context list
pnpm paperplaneai context use default
```

To avoid storing secrets in context, set `apiKeyEnvVarName` and keep the key in env:

```sh
pnpm paperplaneai context set --api-key-env-var-name PAPERPLANE_API_KEY
export PAPERPLANE_API_KEY=...
```

## Company Commands

```sh
pnpm paperplaneai company list
pnpm paperplaneai company get <company-id>
pnpm paperplaneai company delete <company-id-or-prefix> --yes --confirm <same-id-or-prefix>
```

Examples:

```sh
pnpm paperplaneai company delete PAP --yes --confirm PAP
pnpm paperplaneai company delete 5cbe79ee-acb3-4597-896e-7662742593cd --yes --confirm 5cbe79ee-acb3-4597-896e-7662742593cd
```

Notes:

- Deletion is server-gated by `PAPERPLANE_ENABLE_COMPANY_DELETION`.
- With agent authentication, company deletion is company-scoped. Use the current company ID/prefix (for example via `--company-id` or `PAPERPLANE_COMPANY_ID`), not another company.

## Issue Commands

```sh
pnpm paperplaneai issue list --company-id <company-id> [--status todo,in_progress] [--assignee-agent-id <agent-id>] [--match text]
pnpm paperplaneai issue get <issue-id-or-identifier>
pnpm paperplaneai issue create --company-id <company-id> --title "..." [--description "..."] [--status todo] [--priority high]
pnpm paperplaneai issue update <issue-id> [--status in_progress] [--comment "..."]
pnpm paperplaneai issue comment <issue-id> --body "..." [--reopen]
pnpm paperplaneai issue checkout <issue-id> --agent-id <agent-id> [--expected-statuses todo,backlog,blocked]
pnpm paperplaneai issue release <issue-id>
```

## Agent Commands

```sh
pnpm paperplaneai agent list --company-id <company-id>
pnpm paperplaneai agent get <agent-id>
pnpm paperplaneai agent local-cli <agent-id-or-shortname> --company-id <company-id>
```

`agent local-cli` is the quickest way to run local Claude/Codex manually as a Paperplane agent:

- creates a new long-lived agent API key
- installs missing Paperplane skills into `~/.codex/skills` and `~/.claude/skills`
- prints `export ...` lines for `PAPERPLANE_API_URL`, `PAPERPLANE_COMPANY_ID`, `PAPERPLANE_AGENT_ID`, and `PAPERPLANE_API_KEY`

Example for shortname-based local setup:

```sh
pnpm paperplaneai agent local-cli codexcoder --company-id <company-id>
pnpm paperplaneai agent local-cli claudecoder --company-id <company-id>
```

## Approval Commands

```sh
pnpm paperplaneai approval list --company-id <company-id> [--status pending]
pnpm paperplaneai approval get <approval-id>
pnpm paperplaneai approval create --company-id <company-id> --type hire_agent --payload '{"name":"..."}' [--issue-ids <id1,id2>]
pnpm paperplaneai approval approve <approval-id> [--decision-note "..."]
pnpm paperplaneai approval reject <approval-id> [--decision-note "..."]
pnpm paperplaneai approval request-revision <approval-id> [--decision-note "..."]
pnpm paperplaneai approval resubmit <approval-id> [--payload '{"...":"..."}']
pnpm paperplaneai approval comment <approval-id> --body "..."
```

## Activity Commands

```sh
pnpm paperplaneai activity list --company-id <company-id> [--agent-id <agent-id>] [--entity-type issue] [--entity-id <id>]
```

## Dashboard Commands

```sh
pnpm paperplaneai dashboard get --company-id <company-id>
```

## Heartbeat Command

`heartbeat run` now also supports context/api-key options and uses the shared client stack:

```sh
pnpm paperplaneai heartbeat run --agent-id <agent-id> [--api-base http://localhost:3100] [--api-key <token>]
```

## Local Storage Defaults

Default local instance root is `~/.paperplane/instances/default`:

- config: `~/.paperplane/instances/default/config.json`
- embedded db: `~/.paperplane/instances/default/db`
- logs: `~/.paperplane/instances/default/logs`
- storage: `~/.paperplane/instances/default/data/storage`
- secrets key: `~/.paperplane/instances/default/secrets/master.key`

Override base home or instance with env vars:

```sh
PAPERPLANE_HOME=/custom/home PAPERPLANE_INSTANCE_ID=dev pnpm paperplaneai run
```

## Storage Configuration

Configure storage provider and settings:

```sh
pnpm paperplaneai configure --section storage
```

Supported providers:

- `local_disk` (default; local single-user installs)
- `s3` (S3-compatible object storage)
