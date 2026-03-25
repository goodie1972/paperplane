---
title: Setup Commands
summary: Onboard, run, doctor, and configure
---

Instance setup and diagnostics commands.

## `paperplaneai run`

One-command bootstrap and start:

```sh
pnpm paperplaneai run
```

Does:

1. Auto-onboards if config is missing
2. Runs `paperplaneai doctor` with repair enabled
3. Starts the server when checks pass

Choose a specific instance:

```sh
pnpm paperplaneai run --instance dev
```

## `paperplaneai onboard`

Interactive first-time setup:

```sh
pnpm paperplaneai onboard
```

First prompt:

1. `Quickstart` (recommended): local defaults (embedded database, no LLM provider, local disk storage, default secrets)
2. `Advanced setup`: full interactive configuration

Start immediately after onboarding:

```sh
pnpm paperplaneai onboard --run
```

Non-interactive defaults + immediate start (opens browser on server listen):

```sh
pnpm paperplaneai onboard --yes
```

## `paperplaneai doctor`

Health checks with optional auto-repair:

```sh
pnpm paperplaneai doctor
pnpm paperplaneai doctor --repair
```

Validates:

- Server configuration
- Database connectivity
- Secrets adapter configuration
- Storage configuration
- Missing key files

## `paperplaneai configure`

Update configuration sections:

```sh
pnpm paperplaneai configure --section server
pnpm paperplaneai configure --section secrets
pnpm paperplaneai configure --section storage
```

## `paperplaneai env`

Show resolved environment configuration:

```sh
pnpm paperplaneai env
```

## `paperplaneai allowed-hostname`

Allow a private hostname for authenticated/private mode:

```sh
pnpm paperplaneai allowed-hostname my-tailscale-host
```

## Local Storage Paths

| Data | Default Path |
|------|-------------|
| Config | `~/.paperplane/instances/default/config.json` |
| Database | `~/.paperplane/instances/default/db` |
| Logs | `~/.paperplane/instances/default/logs` |
| Storage | `~/.paperplane/instances/default/data/storage` |
| Secrets key | `~/.paperplane/instances/default/secrets/master.key` |

Override with:

```sh
PAPERPLANE_HOME=/custom/home PAPERPLANE_INSTANCE_ID=dev pnpm paperplaneai run
```

Or pass `--data-dir` directly on any command:

```sh
pnpm paperplaneai run --data-dir ./tmp/paperplane-dev
pnpm paperplaneai doctor --data-dir ./tmp/paperplane-dev
```
