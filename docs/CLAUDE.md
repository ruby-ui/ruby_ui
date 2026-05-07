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
