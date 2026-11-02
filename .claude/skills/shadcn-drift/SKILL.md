---
name: shadcn-drift
description: >-
  Use for the weekly check of what changed in shadcn/ui (Base UI base + vega
  style + neutral theme) under the RubyUI components already matched to it:
  runs the `drift` CLI, sorts every change into covered by a divergence,
  possibly stale divergence, or new drift, and returns a pt-BR Slack message
  that ends by asking which components should get the full audit. It never
  posts. Triggers on /shadcn-drift, "o que mudou no shadcn", "drift do
  shadcn", "roda o check semanal do shadcn", "o shadcn mudou algo que afeta a
  RubyUI?". Do NOT use to audit a PR, branch or component side by side (use
  shadcn-audit), or for general code review.
---

# shadcn drift

Weekly upstream watch. Every component mapped in `audit/component_map/` has
a baseline (`shadcn_sha`): the shadcn commit it was last matched against.
`drift` compares that baseline with shadcn `main` and reports per component.
Your job is judging those changes against `audit/divergences/` and writing
the message. Whoever called you (a person, or the lknos agent) posts it.

Run every CLI call from `audit/`:

```bash
cd audit && mise exec -- bundle exec exe/shadcn-audit <subcommand> …
```

(Without mise, drop `mise exec --` and use a Ruby 3.4 on PATH.) Each call
prints one JSON object; `{"error": …}` with exit 1 is a failure. Report it,
never treat it as "nothing changed".

## Prerequisites

Ruby 3.4 with `cd audit && bundle install`, `git`, and `gh` authenticated
(read is enough; the commit list comes from the GitHub API). No browser, no
Node.

## Hard rules

- **Never post** to Slack, GitHub or anywhere else. Return the message.
- **Never edit `audit/divergences/`.** Suggest entries in the message.
- **Full audit only after a yes**, per component, through the
  `shadcn-audit` skill (target = component name).
- **Baselines move only after an explicit ok** (see "Advancing baselines").
- Nothing unverified is "sem impacto": if you can't tell, say so.

## Steps

### 1. Run

`drift` (all mapped components). For a subset: `drift --components a,b`.
Keep the JSON; `head_sha` is the shadcn commit you're reporting against.

### 2. Judge each `changed` component

Read `reference` (class changes per `data-slot` part, parts added/removed,
variant changes), `dependencies` (the same diff for shadcn components a part
is rendered through, e.g. carousel's buttons through `button`: a change there
reaches this component at runtime), `source_diff` (the component's own `.tsx`: ARIA, props,
parts, Base UI usage, which `reference` doesn't capture), `commits`, and
`related_divergences`. For each change decide one of:

- **coberta**: a related divergence explains it and its `shadcn:` text still
  describes shadcn after the change.
- **divergência possivelmente obsoleta**: the change touches what a
  divergence's `shadcn:` side says (e.g. shadcn now applies the
  `disabled:opacity-50` that `checkbox.yml` says never applies). The
  divergence may no longer be needed.
- **drift novo**: nothing registered explains it. Say which dimension
  (Look, HTML, Props, ARIA, Behavior, Animation) and what RubyUI likely
  needs to change.

Class churn with no visual effect (a token renamed with the same output,
reordering) is coberta-free noise: call it "sem impacto visual" and say why.
`warnings_added` not empty → say the class scanner may have missed
something for that component. `commits_error` → link the `.tsx` history
instead of commits.

Look at the RubyUI side when it helps decide:
`gem/lib/ruby_ui/<folder>/` and the map's `parts`.

### 3. Global checks

- `theme.status == "fail"`: neutral theme tokens differ from RubyUI's CSS.
  Always reported, with the tokens. `theme.status == "inconclusive"`: report
  its `reason` (the theme couldn't be read, so it is not "clean").
- `base_ui.head` differs from any `base_ui.baselines` value: `@base-ui/react`
  was bumped. Always reported: behavior can change with no shadcn diff.

### 4. Message (pt-BR, Slack mrkdwn)

Fixed shape. Short `head_sha` (7 chars) links to
`https://github.com/shadcn-ui/ui/commit/<head_sha>`.

```
*shadcn drift — semana de <dd/mm>* (shadcn <sha7>)

*Drift novo*
• *<Componente>* (<dimensão>): <o que mudou no shadcn, em uma frase>. <por que importa pra RubyUI>. <links dos commits>
*Divergência possivelmente obsoleta*
• *<Componente>*: <divergência> — <o que mudou>. <links>
*Removido ou renomeado no shadcn*
• *<Componente>*: o `<shadcn>.tsx` não existe mais no shadcn. <commit, se achar>
*Global*
• Tema neutral: <tokens ou motivo de inconclusivo> | Base UI <de> → <para>

Só mudanças cobertas ou sem impacto visual: <componentes>.
Sem baseline: <componentes> (nunca auditados contra o shadcn).
Inconclusivo: <componente> (<motivo>).

Quer que eu rode o audit completo em: <componentes com drift novo, obsoleta, removidos/renomeados ou sem baseline>?
```

Omit empty sections. `no_counterpart` components (no shadcn equivalent)
never appear. `missing_upstream` is the biggest event `drift` can report:
the component's file is gone (often a rename); find where it went in
`commits` or the shadcn history before writing the line. When every
component is `unchanged`, `no_counterpart` or `no_baseline`, and the global
checks are clean (`theme.status == "pass"`, no Base UI bump), the message
is one line:
`*shadcn drift — semana de <dd/mm>*: nada mudou no shadcn que afete a RubyUI (shadcn <sha7>).`
If any component is `no_baseline`, add the "Sem baseline" line and the final
question for those components: they still need their first audit.

Write it like a teammate, not a report: plain sentences, no filler.

## Advancing baselines

A component judged "coberta" or "sem impacto visual" keeps showing up every
week until its baseline moves. When the user (or the caller relaying the
channel's answer) explicitly oks it for specific components:

1. Branch from an up-to-date `main`.
2. `baseline <folder> <head_sha>` for each of those components.
3. Run `mise exec -- bundle exec rake` in `audit/`.
4. Open a PR `[Chore] shadcn-audit: advance baselines` listing each
   component and why it has no impact. Pushing and opening the PR are
   external actions: only after that ok.

A component that goes through the full audit gets its baseline from the
audit PR itself (shadcn-audit, step 8), not from here.
