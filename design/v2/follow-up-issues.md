# Follow-up issues surfaced by the golden suite

Date: 2026-09-19
Status: to be opened as GitHub issues; not yet opened

The golden suite pins what 1.6 renders today, defects included — that is
what makes it a ruler. These are the defects the recording made visible
(most were raised by the automated review of PR #536). Each is fixed in its
own PR against `main`, with `bundle exec rake golden:update` re-recording the
affected snapshots and the diff reviewed in that PR. None is fixed in the
suite's own PR, and the snapshots that pin them are correct until then.

Ordered by user impact.

## 1. DataTable nests `<form>` inside `<form>`

- **Where:** `DataTableForm` wraps the table; `DataTableSearch` and
  `DataTablePerPageSelect` each render their own `<form>` inside it.
  Snapshot `data_table/full_frame` holds three `<form` elements.
- **Effect:** nested forms are invalid HTML. A browser ignores the inner
  `<form>` start tags when a form is in scope, so the search input and the
  per-page select become children of the outer bulk form, and
  `this.form.requestSubmit()` in `data_table_search_controller.js` submits
  the wrong form.
- **Fix:** render the search and per-page forms outside the bulk form, or
  make their controls reference it with the `form=` attribute; re-record
  `data_table/*`.
- **2.0 note:** Herb's `NestingValidator` will likely reject this at compile
  time, which makes it a template adjustment in the DataTable migration.
  Fixing it on 1.6 first keeps the migration a pure port.

## 2. `aria-*` boolean attributes serialize as the empty string

- **Where:** every `aria: {hidden: true}`, `aria_disabled: true`,
  `aria_expanded: true` in the catalog — breadcrumb separators and ellipsis,
  `CommandInput`, and every decorative `<svg aria-hidden>`. Snapshots carry
  `aria-hidden=""`, `aria-disabled=""`, `aria-expanded=""`.
- **Effect:** the ARIA value grammar accepts `true`/`false`/`undefined`; an
  empty string is invalid and browsers resolve it as *not set*. Decorative
  icons are therefore exposed to assistive technology, "current" breadcrumb
  items are not announced as disabled, and the command input's expanded
  state is unset. This is Phlex's serialization of `true` (a bare
  attribute), so it is library-wide, not one component.
- **Fix:** pass `"true"` (a String) for `aria-*` attributes, or add a
  serialization rule in `Base` that stringifies booleans under the `aria`
  key; re-record everything that changes and review the diff.
- **2.0 note:** spec §4.3 currently preserves this behaviour for parity
  (`true` → `""`). The right 2.0 behaviour is `aria-x="true"`; decide it
  explicitly and let the re-record show the blast radius.

## 3. `TableFooter` ships a corrupted class string

- **Where:** `gem/lib/ruby_ui/table/table_footer.rb:13`:
  `"border-t bg-muted/50 font-medium[& amp;>tr]:last:border-b-0"`. The
  ` amp;` is HTML-decoded text pasted into Ruby source; a space before `[`
  is also missing.
- **Effect:** every `TableFooter` emits the tokens `font-medium[&` and
  `amp;>tr]:last:border-b-0` — neither is a Tailwind class, so `font-medium`
  and the last-row border rule are both lost.
- **Fix:** `"border-t bg-muted/50 font-medium [&>tr]:last:border-b-0"`;
  re-record `table/*`.

## 4. Carousel buttons have the wrong or missing screen-reader label

- **Where:** `carousel_previous.rb` renders `span.sr-only "Next slide"`;
  `carousel_next.rb` renders no `sr-only` span at all. Snapshot
  `carousel/vertical` line 17.
- **Effect:** a screen reader announces the previous button as "Next slide"
  and the next button as unlabeled.
- **Fix:** "Previous slide" on the previous button, add "Next slide" to the
  next button; re-record `carousel/*`.

## 5. `Input` defaults to `type="string"`

- **Where:** `Input`'s default `type:` in `input.rb`, and `date_picker.rb`'s
  `input_attrs` (`type: "string"`). Snapshot `date_picker/without_label`.
- **Effect:** `string` is not an HTML input type; browsers fall back to
  `text`, so nothing breaks, but the attribute is invalid and will be
  flagged by any validator, including Herb's.
- **Fix:** `type: "text"` in both places; re-record `input/*`,
  `date_picker/*` and whatever else changes.

## 6. `TooltipTrigger` emits a dead `variant="outline"` attribute

- **Where:** `tooltip_trigger.rb` default attrs. Snapshot `tooltip/default`.
  Already listed in `design/v2/01-research/golden-suite.md`.
- **Effect:** `variant` is not an HTML attribute and nothing in the CSS
  matches it (the `data-[variant=…]` selectors match `data-variant`); the
  outline look comes from the `Button` inside.
- **Fix:** remove it; re-record `tooltip/*`.

## 7. `CommandInput` sets `aria-expanded` to a boolean

- **Where:** `command_input.rb`, `aria_expanded: true`. Snapshot
  `command/dialog` line 18.
- **Effect:** same root cause as item 2; listed separately because the fix
  is a real state string (`"false"` at rest, toggled by the controller),
  not just `"true"`.
- **Fix:** `aria_expanded: "false"` and have `command_controller.js` set it;
  re-record `command/*`.

## Rejected review findings, for the record

Two findings from the same review were checked and are wrong; they are
recorded here so nobody re-investigates them.

- *"`toggle/pressed_outline_with_name` is stale — missing
  `hover:bg-muted hover:text-muted-foreground`."* The `outline` variant adds
  `hover:bg-accent hover:text-accent-foreground`; `tailwind_merge` resolves
  the `hover:bg-*` conflict by keeping the last, so the base tokens are
  correctly absent. `rake golden` is green on Ruby 3.3 and 3.4.
- *"`bundle exec rake test N=/button/` does not filter."* `Minitest::TestTask`
  honours `N=`; `N=/context_menu_label/` runs 2 tests.
