---
title: Environment Variables
summary: Full environment variable reference
---

All environment variables that Paperplane uses for server configuration.

## Server Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `3100` | Server port |
| `HOST` | `127.0.0.1` | Server host binding |
| `DATABASE_URL` | (embedded) | PostgreSQL connection string |
| `PAPERPLANE_HOME` | `~/.paperplane` | Base directory for all Paperplane data |
| `PAPERPLANE_INSTANCE_ID` | `default` | Instance identifier (for multiple local instances) |
| `PAPERPLANE_DEPLOYMENT_MODE` | `local_trusted` | Runtime mode override |

## Secrets

| Variable | Default | Description |
|----------|---------|-------------|
| `PAPERPLANE_SECRETS_MASTER_KEY` | (from file) | 32-byte encryption key (base64/hex/raw) |
| `PAPERPLANE_SECRETS_MASTER_KEY_FILE` | `~/.paperplane/.../secrets/master.key` | Path to key file |
| `PAPERPLANE_SECRETS_STRICT_MODE` | `false` | Require secret refs for sensitive env vars |

## Agent Runtime (Injected into agent processes)

These are set automatically by the server when invoking agents:

| Variable | Description |
|----------|-------------|
| `PAPERPLANE_AGENT_ID` | Agent's unique ID |
| `PAPERPLANE_COMPANY_ID` | Company ID |
| `PAPERPLANE_API_URL` | Paperplane API base URL |
| `PAPERPLANE_API_KEY` | Short-lived JWT for API auth |
| `PAPERPLANE_RUN_ID` | Current heartbeat run ID |
| `PAPERPLANE_TASK_ID` | Issue that triggered this wake |
| `PAPERPLANE_WAKE_REASON` | Wake trigger reason |
| `PAPERPLANE_WAKE_COMMENT_ID` | Comment that triggered this wake |
| `PAPERPLANE_APPROVAL_ID` | Resolved approval ID |
| `PAPERPLANE_APPROVAL_STATUS` | Approval decision |
| `PAPERPLANE_LINKED_ISSUE_IDS` | Comma-separated linked issue IDs |

## LLM Provider Keys (for adapters)

| Variable | Description |
|----------|-------------|
| `ANTHROPIC_API_KEY` | Anthropic API key (for Claude Local adapter) |
| `OPENAI_API_KEY` | OpenAI API key (for Codex Local adapter) |
