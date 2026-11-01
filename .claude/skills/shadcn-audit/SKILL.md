---
name: shadcn-audit
description: >-
  Use when auditing a RubyUI PR, branch or component against shadcn/ui (Base UI
  base + vega style + neutral theme): Look, HTML, Props, ARIA, Behavior and
  Animation side by side in the browser, shadcn checked against the HTML/ARIA
  specs, JS that native HTML could replace, a checklist plus a screenshot page,
  a finding-by-finding walkthrough with a recommendation and a question each,
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
- Playwright for `collect`: `cd audit && pnpm install` in every checkout or
  worktree (it installs `audit/node_modules`), then `pnpm exec playwright
  install chromium` (the browser download is shared by every checkout on the
  machine).
- The chrome-devtools MCP server, for the browser steps `collect` doesn't
  cover (the kind-specific behavior sequences, animation, exploration).
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
  with a `screens/` subfolder. `.shadcn-audit/` is git-ignored and lives in
  this checkout: removing the worktree deletes the runs, the sandbox and the
  shadcn clone. Copy the run folder elsewhere first if it must outlive the
  worktree.

### 2. Workspace, sandbox, preview, servers

1. `workspace` → record `shadcn_sha`. (Acceptance re-runs pin it:
   `workspace --sha <sha>`.)
2. `sandbox` → `path`, `url_template`, `lock` (→ `report.json`'s
   `sandbox_lock`), `created` (true = it rebuilt the app; tell the user),
   `refreshed` (true = the workspace moved, or `component_map.yml` now needs
   other shadcn components (`shadcn` plus `fixture_shadcn`) than the last pull
   installed, so it re-added them all with `--overwrite`; tell the user), `registry` and
   `built_at`. `registry: "live"` means the components come from the
   published shadcn registry as of `built_at`, not from the workspace clone:
   the sandbox tracks `main` loosely, and `shadcn_sha` pins only the files the
   CLI reads (reference, theme).
3. `preview <head_sha>` (full SHA from `target`) → `path`, `url_template`,
   `boot` (ordered command list), `boot_chdir`. This only extracts files;
   nothing from the PR runs yet.
4. `theme --checkout <preview path>` → `report.json`'s `theme` as-is. Pass the
   checkout: without it the CLI reads the working tree, not the audited SHA.
5. **Untrusted head.** When `target.cross_repository` is true, booting the
   preview runs the fork's code (Gemfile, gemspec, Rails config, bin
   scripts, package scripts, the components themselves, and anything they
   load). Before booting, show the user the **whole** PR diff against the
   base, not a subset of files: from the repo root (`target` already fetched
   both SHAs), `git diff --stat <base_sha>...<head_sha>` for the file list,
   then `git diff <base_sha>...<head_sha>` for the full diff of every changed
   file. Ask whether to boot it. Without an explicit yes, don't boot the
   RubyUI server: the static steps (map, reference, divergences, theme, Look
   from source) still run, and the browser-fed RubyUI lines are ⏸ "fork code
   not run". Same-repository heads come from collaborators with write access
   and skip this step.
6. **Ports.** The defaults are 5179 (shadcn) and 3179 (RubyUI). Another
   audit running in parallel (another worktree) already holds them: check
   with `lsof -nP -iTCP:<port> -sTCP:LISTEN` and pick a free pair (5180/3180,
   5181/3181…). Use it in the commands below and in both `url_template`s.
   Boot both servers. When `HERDR_ENV=1`, **each in its own Herdr pane**
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
  Entries with a structured `match` are applied by `collect` on its own;
  prose-only entries you apply by hand.
- `collect <folder> --run <run> --preview <preview path>` (add
  `--shadcn-url`/`--rubyui-url` with the `url_template`s when step 2.6 picked
  other ports). It drives both fixtures in headless Chromium at 1280×800,
  light and dark, through the states the `kind` has (closed, open, focus,
  after-esc; `form_control`: closed, focus; `static`: closed), and grades the
  objective lines: computed styles per part (Look ❌ / ✅ grouped), the
  accessibility snapshot plus `aria-expanded`/`aria-controls`/`aria-haspopup`/
  `aria-describedby` per part (ARIA ⚠️ / ✅ grouped), structured divergences
  (✅ intentional), differences explained by a theme token or an environment
  diff (⏸), unreachable states and selector count mismatches (⏸). It writes
  `<run>/collect.json` and `<run>/screens/`, with a pixel diff per state as
  evidence only, and only for states reached on both sides. Append its `lines` and `screenshots` to the component and
  copy its `environment_diffs` into the report. Running it twice on the same
  SHAs gives the same `collect.json`.
  - `{"error": "… has no selectors …"}` → the component has no `selectors`
    in `component_map.yml`: tell the user to add them (RubyUI part → CSS
    selector in the rendered fixture; `null` = shadcn renders no element for
    that part). Until they exist, collect that component by hand with the
    chrome-devtools MCP: for each mapped part, the shadcn classes from
    `[data-slot=<slot>]` against `effective`, the RubyUI element found from
    its Ruby source at `<preview path>/gem/lib/ruby_ui/<folder>/` (tag,
    Stimulus target, class string), look-alikes settled with
    `getComputedStyle`; then the whole set for its `kind` in
    `references/interactions.md`, including the Setup, the states and the
    screenshots.
  - `{"error": "playwright not found …"}` / `"chromium failed to launch"` →
    install as in Prerequisites and re-run.

### 4. Look

`collect` already graded Look from computed styles. Review its lines instead
of re-collecting: explain each ❌ with the class tokens behind it (shadcn
`effective` from `reference` vs the RubyUI class string) in the `note`, and
settle the ⏸ it left (count mismatches, theme/environment explanations,
reference `warnings`) when the DOM lets you. Variant props (size, side) are
compared against `variants`.

**Overrides.** Change a `collect` grade only with a verified reason that the
rules in `references/grading.md` allow, written in that line's `note` (e.g.
`text-align: left` vs `start` in LTR renders the same → ✅ with the note). A ✅
with a basis still needs its usual route: a registered divergence, a native
replacement or the spec. Never drop a `collect` line.

Fixture-originated wrappers aren't findings (`references/grading.md`): Sheet
body (shadcn `div.px-4` vs `SheetMiddle`), Dialog body (bare `<p>` vs
`DialogMiddle`).

### 5. HTML, ARIA, Behavior, Animation

`collect` already covered the setup, the environment probe, the states
closed/open/focus/after-esc, the ARIA snapshot and attributes per part, and
the screenshots. Run the rest of the `kind`'s set from
`references/interactions.md` (focus trap order, Esc and focus return, outside
click, scroll lock, arrow keys, typeahead, Enter/Space, animation) on
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

### 8. Report, render, walk through, comment

Write `<run>/report.json`:

```json
{
  "target": {"repo": "ruby-ui/ruby_ui", "base_sha": "…", "head_sha": "…", "…": "the rest of the target JSON from step 1"},
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
- `target` keeps `repo`, `base_sha` and `head_sha`; `sandbox_lock` is
  required (an object, `{}` only if the sandbox never built).
- Every `pass`, `warn` and `fail` needs a `source` (`inconclusive` may leave
  it empty); every Spec `fail`/`warn` and every `pass` with basis `spec` needs
  an `http(s)` source with anchor. Each ❌/⚠️ names concrete values on both sides and a
  `source` (`style-vega.css:<line>`, `bases/base/ui/<name>.tsx:<line>`, a spec
  or MDN URL).
- Screenshot paths are relative to the run folder.

Then:

1. `render <report.json>` (always) → show `text` to the user. An `error`
   means the JSON breaks the schema (or isn't valid JSON): fix it and re-run.
2. `render <report.json> --html` → `html` is the written path, or `null` when
   no component has screenshots plus a non-pass Look/Behavior/Animation line.
   If there's a path, `open` it.
3. **Walk through the findings, one item at a time.** Cover every `fail`,
   `warn` and `inconclusive` line, in report order (component, then
   dimension); `pass` lines aren't discussed. Lines with one root cause (e.g.
   several Look lines one class token explains) form a single item. For each
   item, in the user's language:
   - **What it is**: dimension, the concrete values on both sides and the
     source, in plain words, plus what someone using the component would
     notice.
   - **Recommendation**: one action and why: fix it in RubyUI (what and
     where), suggest a divergence entry (show the YAML), fix the map or
     fixtures, settle it by hand (inconclusive), or leave it. Say so when the
     spec beats shadcn.
   - **Ask** with AskUserQuestion: the recommended option first, labeled
     "(Recommended)", then the realistic alternatives. Wait for the answer
     before the next item.

   Keep a list of the decisions (item, choice, user's note) and act on none
   of them during the walk. After the last item, show the list and ask
   whether to go ahead. The hard rules still hold: on someone else's PR, "fix"
   becomes a request in the PR comment and divergence entries stay
   suggestions for the author; on the user's own branch, fixes follow
   "Before/after images for a fix PR". A decision never changes a grade by
   itself: grades change only through an override (see "4. Look") or a registered
   divergence, followed by a new `render`.
4. Only when `target.kind` is `pr` **and** `target.state` is `OPEN`:
   `comment <report.json>` →
   `{"posted": false, "body": …}`. Show the **exact body** and ask for an ok.
   Branch/component targets, or a PR whose `state` isn't `OPEN`: don't offer
   posting. Tell the user why (no PR, or the PR is MERGED/CLOSED).
5. On an explicit "ok"/"pode mandar" for that body:
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

## Before/after images for a fix PR

When the user asks you to fix what the audit found and open a PR, the PR
shows the fix side by side with `main` and shadcn. The hard rules above still
hold for auditing someone else's PR; this section is for the user's own fix.

1. **Keep the "before".** Before fixing anything, copy `report.json` to
   `report-main.json` and run `render report-main.json --html` while a Look,
   Behavior or Animation line with screenshots still fails: `--html` returns
   `null` otherwise.
2. **Shoot the "after"** of the same states, same clips and themes, into
   `screens/` with a `-now` suffix, plus the fixture on both sides.
3. **Compose one image per state**: three columns, `RubyUI · main`,
   `RubyUI · this PR`, `shadcn · Base UI + vega`. A small HTML page with the
   three screenshots, captured with the browser, is enough. Save them to
   `<run>/pr-assets/`.
4. **Publish to `pr-assets`** (only after the user's ok for the PR). GitHub
   has no API to attach files to a PR, so images go to the orphan branch
   `pr-assets`, one folder per PR, committed with plumbing so the working
   tree and index stay untouched:

   ```bash
   git fetch origin pr-assets 2>/dev/null || true       # absent on the first PR
   export GIT_INDEX_FILE=$(mktemp -u)
   git read-tree origin/pr-assets 2>/dev/null || true   # keep earlier PRs' folders
   for f in <run>/pr-assets/*.png; do
     git update-index --add --cacheinfo 100644,$(git hash-object -w "$f"),<pr-folder>/$(basename "$f")
   done
   tree=$(git write-tree)
   if parent=$(git rev-parse -q --verify origin/pr-assets); then
     sha=$(git commit-tree "$tree" -p "$parent" -m "Add images for <pr-folder>")
   else
     sha=$(git commit-tree "$tree" -m "Add images for <pr-folder>")
   fi
   rm -f "$GIT_INDEX_FILE"; unset GIT_INDEX_FILE
   git push origin "$sha:refs/heads/pr-assets"
   ```

   Link each image by commit SHA so the link never moves:
   `![State](https://github.com/ruby-ui/ruby_ui/blob/<sha>/<pr-folder>/<file>.png?raw=true)`.
   Check one URL answers `200 image/png` before opening the PR. Never delete
   the branch: old PRs lose their images.
5. **Description**: the images, then both checklists (`render` text of
   `report-main.json` and of the fixed `report.json`) inside `<details>`
   blocks, and test steps. Show it to the user before opening the PR.

## References

- `references/grading.md`: statuses, bases, precedence, fixture-originated
  differences, the #572 lines as worked examples. Read before grading.
- `references/interactions.md`: per-`kind` browser sets (modal, menu, popover,
  disclosure, form_control, static), probes, screenshot naming.
- `references/spec-sources.md`: spec weights, base URLs, checked anchors,
  citation rule, React Aria as second opinion.
- `references/native-html.md`: hand-rolled JS → native feature table (MDN), and
  when native loses behavior shadcn provides.
