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

Each subcommand prints one JSON object. Talk to the user in their language;
`report.json`, notes and the PR comment are in English.

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
   `sandbox_lock`), `created` (true = it rebuilt the app; tell the user).
3. `preview <head_sha>` (full SHA from `target`) → `path`, `url_template`,
   `boot` (ordered command list), `boot_chdir`.
4. `theme --checkout <preview path>` → `report.json`'s `theme` as-is. Pass the
   checkout: without it the CLI reads the working tree, not the audited SHA.
5. Boot both servers, **each in its own Herdr pane** (see the `herdr` skill):
   - shadcn: `herdr pane split --current --direction right --cwd <sandbox path>`,
     then `herdr pane run <pane> "pnpm dev --port 5179 --strictPort"`, then
     `herdr pane wait-output --match "5179" --timeout 120000 <pane>`.
   - RubyUI: another split with `--cwd <boot_chdir>`; run the `boot` steps in
     order, joined with `&&` (the first adds the host platform to the throwaway
     lockfile; the last is the server on 3179). Then
     `herdr pane wait-output --regex "Listening on|3179" --timeout 600000 <pane>`.
   - Server fails → read the pane (`herdr pane read`), report it; the
     browser-fed lines become ⏸ "server didn't boot".

### 3. Per component: map, reference, divergences

For each folder in `components`:

- `map <folder>`:
  - `{"missing": true, "suggestion": …}` (every `unmapped` folder) → one
    `inconclusive` line ("not in audit/component_map.yml"), `shadcn_file: null`,
    and show the user the `suggestion` YAML to paste into the map. Native still
    applies (step 6).
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
  settles them), `missing: true` (no `.tsx` → no equivalent).
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
both URLs (`url_template`s; `{folder}` = folder, `{light|dark}` = theme), at
1280×800, with chrome-devtools MCP. Open by clicking `[data-audit-trigger]`.
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
               "source": "style-vega.css:467", "note": ""}],
    "screenshots": [{"state": "open (light)", "rubyui": "screens/dialog-open-rubyui-light.png",
                     "shadcn": "screens/dialog-open-shadcn-light.png"}]
  }]
}
```

- `dimension` ∈ Look, HTML, Props, ARIA, Behavior, Animation, Native, Spec.
  `status` ∈ pass, warn, fail, inconclusive. `basis` ∈ null, intentional,
  native, spec, and only on `pass`.
- Every `pass` needs a `source`; every Spec `fail`/`warn` needs an `http(s)`
  source with anchor. Each ❌/⚠️ names concrete values on both sides.
- Screenshot paths are relative to the run folder.

Then:

1. `render <report.json>` (always) → show `text` to the user. A `ReportError`
   means the JSON breaks the schema: fix it and re-run.
2. `render <report.json> --html` → `html` is the written path, or `null` when
   no component has screenshots plus a non-pass Look/Behavior/Animation line.
   If there's a path, `open` it.
3. Only when `target.kind` is `pr`: `comment <report.json>` →
   `{"posted": false, "body": …}`. Show the **exact body** and ask for an ok.
4. On an explicit "ok"/"pode mandar" for that body:
   `comment <report.json> --post` → `action` `created`/`updated` (give the
   `url`) or `refused`: the PR head moved since the audit pinned it (`reason`).
   Say so and offer a re-run. `posted: false` means nothing was sent.
   Without an ok, don't post.

### 9. Clean up

Close the browser pages you opened, then `herdr pane close <pane>` for both
server panes. Tell the user where the run folder is.

## References

- `references/grading.md`: statuses, bases, precedence, fixture-originated
  differences, the #572 lines as worked examples. Read before grading.
- `references/interactions.md`: per-`kind` browser sets (modal, menu, popover,
  disclosure, form_control, static), probes, screenshot naming.
- `references/spec-sources.md`: spec weights, base URLs, checked anchors,
  citation rule, React Aria as second opinion.
- `references/native-html.md`: hand-rolled JS → native feature table (MDN), and
  when native loses behavior shadcn provides.
