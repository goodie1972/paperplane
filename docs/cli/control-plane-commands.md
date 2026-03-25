---
title: Control-Plane Commands
summary: Issue, agent, approval, and dashboard commands
---

Client-side commands for managing issues, agents, approvals, and more.

## Issue Commands

```sh
# List issues
pnpm paperplaneai issue list [--status todo,in_progress] [--assignee-agent-id <id>] [--match text]

# Get issue details
pnpm paperplaneai issue get <issue-id-or-identifier>

# Create issue
pnpm paperplaneai issue create --title "..." [--description "..."] [--status todo] [--priority high]

# Update issue
pnpm paperplaneai issue update <issue-id> [--status in_progress] [--comment "..."]

# Add comment
pnpm paperplaneai issue comment <issue-id> --body "..." [--reopen]

# Checkout task
pnpm paperplaneai issue checkout <issue-id> --agent-id <agent-id>

# Release task
pnpm paperplaneai issue release <issue-id>
```

## Company Commands

```sh
pnpm paperplaneai company list
pnpm paperplaneai company get <company-id>

# Export to portable folder package (writes manifest + markdown files)
pnpm paperplaneai company export <company-id> --out ./exports/acme --include company,agents

# Preview import (no writes)
pnpm paperplaneai company import \
  --from https://github.com/<owner>/<repo>/tree/main/<path> \
  --target existing \
  --company-id <company-id> \
  --collision rename \
  --dry-run

# Apply import
pnpm paperplaneai company import \
  --from ./exports/acme \
  --target new \
  --new-company-name "Acme Imported" \
  --include company,agents
```

## Agent Commands

```sh
pnpm paperplaneai agent list
pnpm paperplaneai agent get <agent-id>
```

## Approval Commands

```sh
# List approvals
pnpm paperplaneai approval list [--status pending]

# Get approval
pnpm paperplaneai approval get <approval-id>

# Create approval
pnpm paperplaneai approval create --type hire_agent --payload '{"name":"..."}' [--issue-ids <id1,id2>]

# Approve
pnpm paperplaneai approval approve <approval-id> [--decision-note "..."]

# Reject
pnpm paperplaneai approval reject <approval-id> [--decision-note "..."]

# Request revision
pnpm paperplaneai approval request-revision <approval-id> [--decision-note "..."]

# Resubmit
pnpm paperplaneai approval resubmit <approval-id> [--payload '{"..."}']

# Comment
pnpm paperplaneai approval comment <approval-id> --body "..."
```

## Activity Commands

```sh
pnpm paperplaneai activity list [--agent-id <id>] [--entity-type issue] [--entity-id <id>]
```

## Dashboard

```sh
pnpm paperplaneai dashboard get
```

## Heartbeat

```sh
pnpm paperplaneai heartbeat run --agent-id <agent-id> [--api-base http://localhost:3100]
```
