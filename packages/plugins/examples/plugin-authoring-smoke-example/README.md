# Plugin Authoring Smoke Example

A Paperplane plugin

## Development

```bash
pnpm install
pnpm dev            # watch builds
pnpm dev:ui         # local dev server with hot-reload events
pnpm test
```

## Install Into Paperplane

```bash
pnpm paperplaneai plugin install ./
```

## Build Options

- `pnpm build` uses esbuild presets from `@paperplaneai/plugin-sdk/bundlers`.
- `pnpm build:rollup` uses rollup presets from the same SDK.
