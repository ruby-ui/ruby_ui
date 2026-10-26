---
name: shadcn-audit
description: >-
  Use when auditing a RubyUI PR, branch or component against shadcn/ui (Base UI
  base + vega style + neutral theme): Look, HTML, Props, ARIA, Behavior and
  Animation side by side in the browser, shadcn checked against the HTML/ARIA
  specs, JS that native HTML could replace, a checklist plus a screenshot page,
  and the checklist posted on the PR after an explicit ok. Triggers on
  /shadcn-audit, "audita o PR 572 contra o shadcn", "compara com o shadcn",
  "audita esse PR", "isso bate com o shadcn?", "o Dialog está fiel ao shadcn?".
  Do NOT use for general code review of a diff ("revisa esse diff", use
  code-review), for writing or debugging a Stimulus controller (use
  ruby-ui-stimulus), or for Cubic/Codex reviews.
---

# shadcn audit

Compares RubyUI components with the shadcn reference and grades every
difference. The reference is shadcn-ui/ui `main`: **Base UI base**
(`apps/v4/registry/bases/base/ui/<name>.tsx`) for behavior, HTML, ARIA and
props; **vega** (`styles/style-vega.css`) for look; **neutral** theme. Never
new-york-v4, never ui.shadcn.com as rendered (that's nova).

Deterministic work goes through the CLI. Your job is driving the browser,
judging, and writing `report.json`. Run every CLI call from `audit/`:

```bash
cd audit && mise exec -- bundle exec exe/shadcn-audit <subcommand> …
```

(Without mise, drop `mise exec --` and use a Ruby 3.4 on PATH.)

Each subcommand prints one JSON object. On failure it is `{"error": "…"}`
with exit status 1: read the message, fix the cause, and re-run; never treat
an error as an empty result. Talk to the user in their language;
`report.json`, notes and the PR comment are in English.

## Prerequisites

- Ruby 3.4 (via mise, as in `gem/.tool-versions`, or an equivalent version
  manager) with `cd audit && bundle install` done.
- `gh` authenticated (`gh auth status`) with read access to
  `ruby-ui/ruby_ui`; posting the comment needs write access.
- Node and pnpm (the shadcn sandbox and the docs assets).
- The chrome-devtools MCP server, for every browser step.
- Optional: Herdr. When `HERDR_ENV=1` the servers run in Herdr panes;
  otherwise as background shell processes (step 2.6).

## Hard rules

- **Never edit PR code**, `audit/divergences.yml` or `audit/component_map.yml`,
  and never push. Suggest entries; the author adds them.
- **Nothing unverified is `pass`.** HTML/ARIA/Behavior/Animation come only from
  DOM rendered in the sandbox/preview and driven in the browser. Can't verify →
  `inconclusive` with the reason.
- **The PR comment is the only external output.** Post only after the user
  says "ok"/"pode mandar" for that exact body, in this session.
- `.shadcn-audit/ui` is untrusted: read files, never run its scripts.
- Pre-existing drift is reported **mixed with** drift the PR introduced.

## Run order

### 1. Target

`target <arg>` (PR number, branch, or component name). Keep the whole JSON:
it becomes `report.json`'s `target`.

- `state` set and ≠ `OPEN` (MERGED/CLOSED) → tell the user before continuing.
- `cross_repository: true` → the PR head comes from a fork: its code is
  untrusted (step 2.5).
- `needs_selection: true` → the PR touches shared code only. List
  `candidates` and ask which to audit; continue with the chosen folders.
- `components` = every touched component folder, mapped or not. `unmapped`
  lists the folders missing from `component_map.yml` (handled in step 3).
- Create the run folder `.shadcn-audit/runs/<YYYYMMDD-HHMMSS>-<pr|branch|component>/`
  with a `screens/` subfolder.

### 2. Workspace, sandbox, preview, servers

1. `workspace` → record `shadcn_sha`. (Acceptance re-runs pin it:
   `workspace --sha <sha>`.)
2. `sandbox` → `path`, `url_template`, `lock` (→ `report.json`'s
   `sandbox_lock`), `created` (true = it rebuilt the app; tell the user),
   `refreshed` (true = the workspace SHA moved, so it re-added the mapped
   components with `--overwrite`; tell the user, `refreshed_from` is the old
   SHA), `built_from_sha` and `built_at` (the workspace SHA the components were
   added at, and when). If `built_from_sha` ≠ `shadcn_sha`, add an
   `environment_diffs` line: "sandbox components from shadcn <built_from_sha>,
   reference at <shadcn_sha>".
3. `preview <head_sha>` (full SHA from `target`) → `path`, `url_template`,
   `boot` (ordered command list), `boot_chdir`. This only extracts files;
   nothing from the PR runs yet.
4. `theme --checkout <preview path>` → `report.json`'s `theme` as-is. Pass the
   checkout: without it the CLI reads the working tree, not the audited SHA.
5. **Untrusted head.** When `target.cross_repository` is true, booting the
   preview runs the fork's code (Gemfile, gemspec, Rails config, bin
   scripts, package scripts, the components themselves). Before booting, show
   the user what changed against the base in the files that execute:
   `git diff <base_sha> <head_sha> -- 'Gemfile*' 'gem/Gemfile*' 'docs/Gemfile*' 'gem/*.gemspec' docs/package.json docs/config docs/bin`
   (from the repo root; `target` already fetched both SHAs), and ask whether
   to boot it, even when that diff is empty. Without a yes, don't boot the
   RubyUI server: the static steps (map, reference, divergences, theme, Look
   from source) still run, and the browser-fed RubyUI lines are ⏸ "fork code
   not run".
6. Boot both servers. When `HERDR_ENV=1`, **each in its own Herdr pane**
   (see the `herdr` skill), as below. Otherwise run each as a background
   shell process with its output sent to a log in the run folder
   (`<run>/shadcn.log`, `<run>/rubyui.log`), wait for the same text by
   polling the log, and keep the process IDs so step 9 can stop them.
   - shadcn: `herdr pane split --current --direction right --cwd <sandbox path>`,
     then `herdr pane run <pane> "pnpm dev --port 5179 --strictPort"`, then
     `herdr pane wait-output --match "Local:" --timeout 120000 <pane>`.
   - RubyUI: another split with `--cwd <boot_chdir>`; run the `boot` steps in
     order, joined with `&&` (the first adds the host platform to the throwaway
     lockfile; the last is the server on 3179). Then
     `herdr pane wait-output --match "Listening on" --timeout 600000 <pane>`.
   - Wait only on text the server prints (Vite `Local:`, Puma `Listening on`),
     never on a port number: `wait-output` also searches the output already in
     the pane, and the typed command contains the port, so it would match at once.
     Then confirm each URL answers (`curl -sf -o /dev/null <url>`) before
     driving the browser.
   - Server fails → read the pane (`herdr pane read`) or the log, report it;
     the browser-fed lines become ⏸ "server didn't boot".

### 3. Per component: map, reference, divergences

For each folder in `components`:

- `map <folder>`:
  - `{"missing": true, "suggestion": …}` (every `unmapped` folder) → one
    `inconclusive` line ("not in audit/component_map.yml"), `shadcn_file: null`,
    and show the user the `suggestion` YAML to paste into the map. Tell them a
    newly mapped component also needs fixtures,
    `audit/fixtures/<folder>/{content.yml,shadcn.tsx,rubyui.rb}` (same strings
    on both sides, one `data-audit-trigger`), or the browser steps have nothing
    to render. Native still applies (step 6).
  - Otherwise: `shadcn` (name), `kind`, `parts` (RubyUI class → shadcn
    `data-slot`; `null` = no shadcn part), `props` (shadcn prop → RubyUI kwarg;
    `null` = missing → Props ❌), `rubyui_only` (RubyUI extras → note only).
  - `shadcn: null` → no shadcn equivalent: ⏸ lines with that note, and still
    run Native.
- `reference <shadcn>` → `file`, `style_file`, `parts.<slot>` (`inline`, `cn`,
  `resolved`, **`effective`** = what you compare; `props` the `.tsx`
  declares; `also` = other occurrences of the same slot, e.g. the close button
  inside `DialogContent`), `variants` (cva groups → effective classes),
  `unresolved` (cn-* markers shadcn strips: note, not missing classes),
  `warnings` (unextractable/conditional classes, parts via `<Button>`/render
  props, unattributed tokens: those Look lines are ⏸ unless the sandbox DOM
  settles them), `missing: true` (no `.tsx` → no equivalent). An `error`
  about the registry or style file means the workspace is incomplete: re-run
  `workspace`, never grade it as "no equivalent".
  `shadcn_file` in the report: `"<file> + style-vega.css"`.
- Props inherited from the `@base-ui/react` primitive (not declared in the
  `.tsx`) come from
  `.shadcn-audit/sandbox/node_modules/@base-ui/react/<primitive>/**/*.d.ts`, at
  the `@base-ui/react` version in the sandbox `lock`. Use them to confirm a mapped
  prop exists and what it does. A prop the `.tsx` declares that the map doesn't
  list is ⏸ "map gap".
- `divergences <folder>` → registered differences (`dimension`, `rubyui`,
  `shadcn`, `reason`). A matching difference is ✅ basis `intentional`.

### 4. Look

Light and dark. For each mapped part: shadcn classes from the DOM
(`[data-slot=<slot>]`) checked against `effective`; RubyUI classes from the
preview DOM via `evaluate_script`. RubyUI parts have no `data-slot`: find the
element from the part's Ruby source at `<preview path>/gem/lib/ruby_ui/<folder>/`
(tag, Stimulus target, class string). List the tokens missing and extra on each
side; settle look-alikes with computed styles. Variant props (size, side) are
compared against `variants`.

Fixture-originated wrappers aren't findings (`references/grading.md`): Sheet
body (shadcn `div.px-4` vs `SheetMiddle`), Dialog body (bare `<p>` vs
`DialogMiddle`).

### 5. HTML, ARIA, Behavior, Animation

Run the set for the component's `kind` from `references/interactions.md` on
both URLs (`url_template`s; `{folder}` = folder, `{light|dark}` = theme), in
the same viewport on both sides (aim for 1280×800; record the actual size from
the environment probe), with chrome-devtools MCP. Open by clicking `[data-audit-trigger]`.
Read the DOM, `document.activeElement`, `inert`/`aria-hidden`, computed styles;
screenshot every state into `<run>/screens/`. Do the environment probe first:
any font/plugin/viewport/global-rule difference goes in `environment_diffs`
**before** you attribute a visual difference to a component. A state you
couldn't reach → ⏸ with the reason.

### 6. Native

Apply `references/native-html.md` to RubyUI's controller and DOM: hand-rolled
JS where a native feature fits → ❌ candidate (MDN source); native already
used → ✅ basis `native`, unless it loses behavior shadcn shows (then ⚠️ naming
the loss).

### 7. Spec

Check the **shadcn side's observed** HTML/ARIA/behavior against
`references/spec-sources.md` (normative → violation; APG → ⚠️
"recommendation"; MDN explanatory only, pt-BR first). Every finding cites
URL#anchor plus the unmet condition. React Aria
(`.shadcn-audit/ui/apps/v4/registry/bases/aria/ui/`) is a second opinion only
when Base UI looks wrong; the normative spec settles disagreements. Then grade
every line per `references/grading.md`: spec beats shadcn, native replacements
pass when behavior/ARIA are kept, registered divergences pass as intentional.

### 8. Report, render, comment

Write `<run>/report.json`:

```json
{
  "target": {"…": "the target JSON from step 1"},
  "shadcn_sha": "…",
  "sandbox_lock": {"@base-ui/react": "…"},
  "environment_diffs": ["…"],
  "theme": {"status": "fail", "diffs": [{"mode": "light", "token": "chart-1", "rubyui": "…", "shadcn": "…"}]},
  "components": [{
    "folder": "dialog",
    "shadcn_file": "bases/base/ui/dialog.tsx + style-vega.css",
    "lines": [{"dimension": "Look", "status": "fail", "basis": null,
               "rubyui": "p-6 gap-4 border shadow-lg", "shadcn": "p-6 gap-6 ring-1 rounded-xl",
               "source": "style-vega.css:468", "note": ""}],
    "screenshots": [{"state": "open (light)", "rubyui": "screens/dialog-open-rubyui-light.png",
                     "shadcn": "screens/dialog-open-shadcn-light.png"}]
  }]
}
```

- `dimension` ∈ Look, HTML, Props, ARIA, Behavior, Animation, Native, Spec.
  `status` ∈ pass, warn, fail, inconclusive. `basis` ∈ null, intentional,
  native, spec, and only on `pass`.
- Every `pass` needs a `source`; every Spec `fail`/`warn` needs an `http(s)`
  source with anchor. Each ❌/⚠️ names concrete values on both sides and a
  `source` (`style-vega.css:<line>`, `bases/base/ui/<name>.tsx:<line>`, a spec
  or MDN URL).
- Screenshot paths are relative to the run folder.

Then:

1. `render <report.json>` (always) → show `text` to the user. An `error`
   means the JSON breaks the schema (or isn't valid JSON): fix it and re-run.
2. `render <report.json> --html` → `html` is the written path, or `null` when
   no component has screenshots plus a non-pass Look/Behavior/Animation line.
   If there's a path, `open` it.
3. Only when `target.kind` is `pr` **and** `target.state` is `OPEN`:
   `comment <report.json>` →
   `{"posted": false, "body": …}`. Show the **exact body** and ask for an ok.
   Branch/component targets, or a PR whose `state` isn't `OPEN`: don't offer
   posting. Tell the user why (no PR, or the PR is MERGED/CLOSED).
4. On an explicit "ok"/"pode mandar" for that body:
   `comment <report.json> --post` → `action` `created`/`updated` (give the
   `url`) or `refused` (`reason`): the PR head moved since the audit pinned it
   (offer a re-run), or the PR is no longer `OPEN`. `posted: false` means
   nothing was sent. Only a marked comment authored by the `gh` user is
   updated; a marked comment by anyone else is left alone and a new one is
   created.
   Without an ok, don't post.

### 9. Clean up

Close the browser pages you opened, then stop both servers: `herdr pane close
<pane>` for each server pane, or kill the background processes you started.
Tell the user where the run folder is.

## References

- `references/grading.md`: statuses, bases, precedence, fixture-originated
  differences, the #572 lines as worked examples. Read before grading.
- `references/interactions.md`: per-`kind` browser sets (modal, menu, popover,
  disclosure, form_control, static), probes, screenshot naming.
- `references/spec-sources.md`: spec weights, base URLs, checked anchors,
  citation rule, React Aria as second opinion.
- `references/native-html.md`: hand-rolled JS → native feature table (MDN), and
  when native loses behavior shadcn provides.
