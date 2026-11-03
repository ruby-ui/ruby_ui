# Component map

One file per RubyUI component: `<folder>.yml`, where `<folder>` is the
component's folder under `gem/lib/ruby_ui/`. A new component adds its own
file, so parallel PRs don't touch the same lines.

Keys in each file:

- `shadcn`: the counterpart, `apps/v4/registry/bases/base/ui/<shadcn>.tsx` (`null` = no equivalent).
- `kind`: one of `modal`, `menu`, `popover`, `disclosure`, `form_control`, `static`.
- `docs_view`: `docs/app/views/docs/<docs_view>.rb`.
- `parts`: RubyUI class => shadcn `data-slot` (`null` = no shadcn part).
- `props`: RubyUI class => {shadcn prop => RubyUI kwarg (`null` = none)}; shadcn props only.
- `rubyui_only`: RubyUI class => [kwargs with no shadcn counterpart]. `className` is never listed (all parts take class via attrs).
- `selectors`: RubyUI class => CSS selector of that part in the rendered fixture (fixed, so collect is deterministic);
  `null` = not compared (shadcn renders no element for it, e.g. a Base UI root).
- `shadcn_sha` (optional): shadcn commit the component was last matched against; `drift` diffs from here.
  Set with `exe/shadcn-audit baseline <folder> <sha>`.
- `fixture_shadcn`: other shadcn components the fixture renders (added to the sandbox, not audited here).
