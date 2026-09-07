# The golden suite

Date: 2026-09-07
Status: in place

The charter names "visual/HTML parity with 1.6, verified by the golden suite"
as a success criterion for 2.0, and leaves the suite itself as a placeholder to
resolve. This is that resolution: what the suite is, what it covers, what it
deliberately does not, and what its normalization treats as an acceptable
difference.

It exists before any 2.0 architecture decision on purpose. It is the ruler every
review from here on measures against, and a ruler written after the thing it
measures is not a ruler.

## What it is

A Minitest suite in `gem/` that renders every component in the 1.6 catalog,
reduces each render to a canonical form, and compares it against a committed
snapshot.

```bash
cd gem
bundle exec rake golden          # verify
bundle exec rake golden:update   # re-record, then review the diff
```

`rake golden` is also reached by `rake test`, so CI runs it on Ruby 3.3 and 3.4
on every push and PR — no CI change was needed.

| Path | What it is |
| --- | --- |
| `gem/test/golden_test.rb` | The runner. One test per scenario, plus three coverage tests. |
| `gem/test/golden/scenarios.rb` | The catalog: what gets rendered. The file to read first. |
| `gem/test/golden/canonical_html.rb` | Parse, normalize, serialize. The executable definition of "acceptable difference". |
| `gem/test/golden/harness.rb` | Pins the two sources of randomness; records class coverage. |
| `gem/test/golden/catalog.rb` | The `component` / `scenario` DSL and the coverage queries. |
| `gem/test/golden/snapshots/**.html` | 186 recorded snapshots, one file per scenario. |

The only new dependency is `nokogiri`, added as a **development** dependency of
the gem. Nothing ships to consumers; `ruby_ui.gemspec` packages `lib/**` only.

### How the comparison works

The rendered fragment is parsed into a DOM by an HTML5-spec parser and
re-serialized in one canonical form. Two fragments are at parity when their
canonical forms are byte-identical.

Comparing raw output as strings would make the suite a test of the *renderer*
rather than of the *markup*. Neither Phlex nor ERB promises a stable attribute
order, and an ERB template cannot help emitting indentation where a Phlex `div`
call emits none — so a string comparison would fail on day one of 2.0 for
reasons that have nothing to do with what a browser builds.

The canonical form is a **fixed point** of the normalization: feeding a
snapshot back through the normalizer returns the snapshot unchanged. That
property is what makes the final byte comparison a structural comparison rather
than a string one, and `golden_test.rb` asserts it for all 186 snapshots on
every run. If the normalizer ever stopped being idempotent, every snapshot
would quietly revert to being a string test — so it is checked rather than
assumed.

Two other properties are asserted per scenario:

- **Determinism.** Every scenario is rendered twice and the two canonical forms
  must match, which catches any unpinned source of randomness wherever it lives
  before it can be baked into a snapshot.
- **Coverage.** Every directory under `lib/ruby_ui/` must have at least one
  scenario, every `RubyUI::Base` subclass must be reached by at least one
  scenario, and every snapshot file on disk must belong to a live scenario.
  A new component cannot be added without extending the ruler, and a deleted
  one cannot leave a stale snapshot behind.

### Parsing inside `<template>`

Every fragment is parsed as `<template>#{html}</template>` and the template's
children are taken. This is not cosmetic. In the HTML5 tree construction
algorithm a stray `<tr>`, `<td>`, `<option>` or `<li>` at the top level of an
"in body" fragment is foster-parented: the element is dropped and only its text
survives. RubyUI ships components whose root element is exactly one of those —
`TableRow`, `TableCell`, `NativeSelectOption`, `BreadcrumbItem`, `ToastItem` —
and a ruler that silently deletes them is worse than no ruler. "In template"
insertion mode has no foster parenting, so the tree survives as authored while
still going through the real spec parser. `table/detached_row` is recorded
specifically to keep this honest.

### Pinning randomness

Four call sites in 1.6 are non-deterministic: `TooltipContent`, `SelectContent`
and `DatePicker` mint DOM ids with `SecureRandom.hex(4)`, and
`SidebarMenuSkeleton` picks a width with `rand(50..89)`.

Both are replaced — only while a scenario renders, and only on `RubyUI::Base`,
so Minitest's own seeding is untouched — by counters that restart per scenario.

Scrubbing the generated ids out with a regexp afterwards was the alternative and
is worse: it would also erase the `id` → `for` / `aria-*` / Stimulus-outlet
references that point at them, and those references *are* part of parity.
Counters keep the values fixed and the cross-references checkable. Any other
shape of `rand` raises rather than silently returning a number a snapshot cannot
reproduce.

## What is covered

54 component directories, 251 `RubyUI::Base` subclasses, 188 scenarios, 186
recorded snapshots.

Coverage is compositional where a component is composed (the scenario renders
the real nesting a user writes, not an isolated sub-component) and enumerative
where a component exposes a closed set of variants — Button's six variants and
four sizes in both plain and icon form, Link's six variants and four sizes,
Badge's 28 colours, Dialog's and Sheet's sizes and sides, Typography's nine text
sizes and four weights.

| Component | Base classes | Scenarios |
| --- | --- | --- |
| `accordion` | 7 | 2 |
| `alert` | 3 | 4 |
| `alert_dialog` | 9 | 2 |
| `aspect_ratio` | 1 | 2 |
| `avatar` | 3 | 5 |
| `badge` | 1 | 4 |
| `breadcrumb` | 7 | 1 |
| `bubble` | 4 | 4 |
| `button` | 1 | 15 |
| `calendar` | 8 | 3 |
| `card` | 6 | 1 |
| `carousel` | 5 | 3 |
| `chart` | 1 | 1 |
| `checkbox` | 2 | 3 |
| `clipboard` | 4 | 4 |
| `codeblock` | 1 | 2 |
| `collapsible` | 3 | 2 |
| `combobox` | 16 | 5 |
| `command` | 9 | 5 |
| `context_menu` | 6 | 4 (2 pending) |
| `data_table` | 14 | 7 |
| `date_picker` | 1 | 3 |
| `dialog` | 8 | 6 |
| `dropdown_menu` | 6 | 2 |
| `empty` | 6 | 2 |
| `form` | 5 | 1 |
| `hover_card` | 3 | 2 |
| `input` | 1 | 2 |
| `input_otp` | 4 | 2 |
| `link` | 1 | 11 |
| `masked_input` | 1 | 1 |
| `message` | 6 | 1 |
| `message_scroller` | 6 | 3 |
| `native_select` | 4 | 3 |
| `pagination` | 4 | 1 |
| `popover` | 3 | 2 |
| `progress` | 1 | 3 |
| `radio_button` | 1 | 2 |
| `select` | 8 | 2 |
| `separator` | 1 | 4 |
| `sheet` | 8 | 6 |
| `shortcut_key` | 1 | 1 |
| `sidebar` | 26 | 4 |
| `skeleton` | 1 | 1 |
| `switch` | 1 | 2 |
| `table` | 8 | 2 |
| `tabs` | 4 | 1 |
| `textarea` | 1 | 2 |
| `theme_toggle` | 1 | 1 |
| `toast` | 8 | 3 |
| `toggle` | 1 | 3 |
| `toggle_group` | 2 | 3 |
| `tooltip` | 3 | 2 |
| `typography` | 5 | 25 |

## What is deliberately not covered

Stating this precisely matters more than the coverage table. Everything below is
a place where a 2.0 implementation can pass the golden suite and still be wrong.

1. **Behaviour.** The suite measures markup at render time. Open/close state,
   focus trap, exit animation, keyboard navigation, the portal escape a Dialog
   needs — none of it. The 37 Stimulus controllers are not exercised at all;
   only the `data-controller` / `data-action` / `data-*-target` attributes that
   wire them are. The charter's Dialog / Select / Data Table gate cannot be
   answered by this suite.

2. **Pixels.** Tailwind class *strings* are compared; the CSS they resolve to is
   not. A class that is present but no longer compiled by Tailwind — or one that
   changed meaning across a Tailwind major — looks identical to this suite. A
   visual/screenshot check is separate work and is not proposed here.

3. **Whitespace between a text node and a sibling element.** `<p>foo <b>bar</b></p>`
   and `<p>foo<b>bar</b></p>` canonicalize the same. This is the direct cost of
   the whitespace-insensitivity the suite is required to have: there is no way
   to tell a meaningful space from template indentation without reintroducing
   the string comparison. Scenario text is kept free of leading and trailing
   spaces so the suite is never relied on for something it cannot see.

4. **The Rails-integrated render path.** Scenarios render with no Rails, no
   request and no view context, exactly like the existing component tests. Two
   consequences: `RubyUI::Base#before_template`'s development-only HTML comment
   never fires, and `DataTableForm#csrf_token` falls back to the literal
   `"csrf-token-placeholder"` instead of a real token. The snapshots are the
   no-Rails render, and a 2.0 that behaves differently *inside* Rails would not
   be caught here.

5. **Non-`RubyUI::Base` classes.** `DataTableKaminariAdapter`,
   `DataTableManualAdapter`, `DataTablePagyAdapter` and the `RubyUI::Toast`
   module emit no HTML. They are covered by the existing unit tests in
   `gem/test/ruby_ui/`, and the coverage check filters them out by ancestry
   rather than by an ignore list, so a new adapter cannot be mistaken for an
   uncovered component.

6. **`lib/ruby_ui/docs/`.** Documentation views that ship with the gem, not
   components.

7. **Distribution.** The generators in `lib/generators/ruby_ui/` — the
   copy-into-`app/` model, `dependencies.yml`, the Stimulus manifest update —
   are untouched by this suite. The charter flags distribution as the
   highest-risk product question for 2.0; it needs its own verification.

8. **The attribute cross-product.** One to a handful of scenarios per component,
   not every combination of every option. Arbitrary attribute pass-through and
   the `tailwind_merge` override path are exercised (scenarios pass `class:`,
   `data:`, `disabled:`, `colspan:` and friends through) but not exhaustively.

9. **Caller-supplied markup.** Scenarios pass short, plain text into blocks. A
   component that mangles rich caller content would not be caught.

10. **`ContextMenuLabel`** — two scenarios are declared but not pinned. See
    below.

## What the normalization treats as an acceptable difference

The list below is the prose copy of the constants in
`gem/test/golden/canonical_html.rb`. Anything not on it is significant and will
fail the suite.

1. **Whitespace between nodes, and indentation.** Collapsed and re-emitted one
   node per line — except inside `pre`, `textarea`, `script` and `style`, where
   content is emitted verbatim with no added character.
2. **Attribute order.** Sorted by attribute name.
3. **Boolean attribute spelling.** `hidden`, `hidden=""` and `hidden="hidden"`
   all collapse to the bare name, for the HTML5 boolean attribute set. Phlex,
   ERB and Rails tag helpers disagree about which to emit and a browser does
   not care.
4. **Void element closing.** `<input>`, `<input/>` and `<input></input>` are the
   same to the parser and never reach the serializer as a difference.
5. **Character reference spelling.** `&amp;`, `&#38;` and a bare `&` where legal
   all decode to the same text before comparison. This is the clearest thing a
   string comparison gets wrong and a parse gets right.
6. **HTML comments.** Dropped. They produce no rendered output.
7. **Whitespace *inside* `class` and `data-action` values.** Tokens are split
   and rejoined with single spaces. The tokens themselves, **and their order**,
   are significant — Tailwind resolves two conflicting utilities by source
   order and `tailwind_merge` does not remove every conflict (arbitrary variants
   and `!important` survive it), and Stimulus invokes actions in the order they
   are listed. Sorting either list would let a real regression through.
8. **Element and attribute name case, including the SVG adjustment table.** The
   parser rewrites the gem's `viewbox:` to `viewBox`, which is what a browser
   builds. The suite compares the DOM, not the source string.
9. **Empty versus whitespace-only element bodies.** `<div></div>` and
   `<div>\n</div>` canonicalize identically.

Everything else is significant, and three cases are worth naming because they
are easy to assume away:

- **Attribute presence.** Phlex omits an attribute whose value is `false` or
  `nil`. An implementation that renders `data-open-value="false"` instead of
  omitting it will fail, and should.
- **`style` attribute values.** Compared verbatim. `height: 0px;` and
  `height:0px` are a failure, not a normalization. Normalizing CSS is a rabbit
  hole and the difference is worth a conversation when it appears.
- **Generated ids.** Pinned to counters, not erased, so `id` and everything
  pointing at it are compared as a pair.

## Findings from the first run

Two came out of writing the ruler. Neither is fixed here — this session was
scoped to the ruler, not to the components — and both are recorded because they
are exactly what it is for.

1. **`ContextMenuLabel` renders a Ruby `Hash#inspect` into its class attribute.**
   `default_attrs` reads

   ```ruby
   class: ["px-2 py-1.5 text-sm font-semibold text-foreground", inset?: "pl-8"]
   ```

   The trailing pair is a `Hash` in the class list, not a condition, so the
   literal inspect output lands in the class attribute for every value of
   `inset:`. Ruby 3.4 changed that inspect format (`{inset?: "pl-8"}` vs
   `{:inset?=>"pl-8"}`), so the rendered HTML differs between the two Rubies CI
   runs and cannot be pinned by a single snapshot. `context_menu/label_inset`
   and `context_menu/label_flush` are declared with a `pending:` reason: they
   are still rendered and still count for class coverage, but their markup is
   not recorded. Removing `pending:` and running `rake golden:update` is the
   last step of the fix.

2. **`TooltipTrigger#default_attrs` carries a stray `variant: :outline`**, which
   renders as a bogus `variant="outline"` attribute on the trigger `div`. It is
   in the snapshots as recorded 1.6 behaviour.

Both are 1.6 bugs and should be fixed on `main` before 2.0 takes 1.6 as its
reference, otherwise 2.0 inherits a snapshot it has to reproduce bug-for-bug.

## Using it against 2.0

The suite compares a render against a recorded canonical form; it does not care
which renderer produced the render. A 2.0 implementation reaches parity for a
component when its scenario, run through the same normalizer, matches the
committed 1.6 snapshot byte for byte.

The mechanics of pointing the runner at an ERB implementation are 2.0's problem,
not this session's. What matters is that the snapshots are recorded now, from
1.6, and that the definition of "the same HTML" is written down and executable
rather than argued case by case.
