# CLAUDE.md

Guidance for AI agents working inside the `docs/` Rails app.

## LLM and Sitemap Files

The docs app publishes these root files from `public/`:

- `/llms.txt`
- `/llms-full.txt`
- `/sitemap.xml`

Their source of truth is `app/lib/site_files.rb`.

Whenever you add, remove, or rename a public route, controller action, or view, check whether it creates or changes a public URL. If it does, update `SiteFiles` and run:

```bash
bin/rails site_files:generate
```

Before finishing, review the diff for `public/llms.txt`, `public/llms-full.txt`, and `public/sitemap.xml`. These generated files should be committed with the route/controller/view change so deployed apps expose the updated root files without a manual step.

## Stimulus Controllers

`app/javascript/controllers/ruby_ui/*_controller.js` are symlinks into `gem/lib/ruby_ui/<component>/`, not copies — there is no independent docs version to keep in sync.

Adding a brand-new component's controller:

```bash
bin/rails ruby_ui:sync_controller_symlinks   # creates the missing symlink(s)
bin/rails stimulus:manifest:update           # registers it in controllers/index.js
```

`sync_controller_symlinks` (in `lib/tasks/ruby_ui.rake`) is idempotent — safe to re-run any time. It only creates/repairs symlinks; it does not touch the manifest, so `stimulus:manifest:update` is still a separate required step for a controller the manifest hasn't seen yet.

### Why `--preserve-symlinks` and `.npmrc` exist

`pnpm build` passes `--preserve-symlinks` to esbuild. Without it, esbuild resolves a symlinked controller's imports relative to its *real* path under `gem/`, which has no reachable `node_modules` for `@hotwired/stimulus`, `motion`, `maska`, `chart.js`, and friends — every symlinked controller with an external import fails to resolve.

That flag then collides with pnpm's default symlinked `node_modules`: package-internal requires (`@hotwired/turbo-rails` → `@hotwired/turbo`, `motion` → `framer-motion/dom`) stop resolving too, because esbuild no longer follows the symlink into `.pnpm/<pkg>/node_modules`. `.npmrc` sets `node-linker=hoisted` so `node_modules` is a flat tree of real directories — the only symlinks left are the intentional controller ones, and both halves resolve. Changing either the flag or `.npmrc` without the other breaks `pnpm build`.
