# InputOtp — design spec

Date: 2026-06-30
Status: approved (pending final review)

## Problem

RubyUI has no OTP / PIN-code input. Reference: [shadcn/ui InputOTP](https://ui.shadcn.com/docs/components/radix/input-otp), built on [`input-otp`](https://github.com/guilhermerodz/input-otp) (React-only). We port the behavior to Phlex + Stimulus — no React dependency available, so this is a from-scratch reimplementation, not a wrapped npm package.

## Architecture

Single real `<input>`, not N per-slot inputs. The input is visually transparent (`color: transparent`, `caret-color: transparent`), absolutely positioned over the slot row, but **not** `display:none` — it stays in the accessibility tree as the one real control (matches the upstream lib's approach and keeps screen readers/autofill working). Visible slots are plain decorative `<div>`s (`aria-hidden="true"`) that mirror the input's value, one character each, painted by the Stimulus controller.

Trade-off vs. upstream lib: upstream maps native click x/y to a caret column via a monospace + negative-letter-spacing CSS hack. We skip that — each slot has a click handler that calls `input.focus()` + `setSelectionRange(i, i)` directly. Less fragile (no font-metrics dependency), at the cost of one mechanism the original lib doesn't need.

Confirmed behavior requirements (these must all work, not just be "supported in theory"):
- Typing a digit appends it and auto-advances to the next slot.
- Backspace deletes the current slot's char and moves back.
- ArrowLeft/ArrowRight move the active slot.
- ArrowUp/ArrowDown also move the active slot (non-native — a single-line `<input>` doesn't react to vertical arrows by default, so the controller intercepts `keydown` for all four arrow keys and calls `setSelectionRange` explicitly rather than relying on the browser's native caret movement). This keeps behavior deterministic instead of depending on browser-specific selection-collapse quirks.
- Paste distributes characters across slots from the caret position, filtered by `pattern`.

## File layout

```
gem/lib/ruby_ui/input_otp/
  input_otp.rb            # root: container div + the real input
  input_otp_group.rb       # div, visual grouping of slots (e.g. 3+3)
  input_otp_slot.rb        # div, index:, renders mirrored char + fake caret
  input_otp_separator.rb   # div role="separator", inline minus-icon svg
  input_otp_controller.js
  input_otp_docs.rb
```

Naming: `InputOtp`, not `InputOTP`. No acronym casing — matches existing precedent (`NativeSelect`, `DataTable`) and avoids a Zeitwerk inflector override in `docs/config/initializers/ruby_ui.rb`.

No new JS package dependency. `input-otp` (the JS package) is React-only, so it can't be wrapped — Stimulus controller reimplements the behavior directly. `animate-caret-blink` is already available via `tw-animate-css`, already a baseline install (other components use `animate-in`/`fade-in-0` etc. the same way), so no new entry in `dependencies.yml`.

## Component API (compound, mirrors shadcn 1:1)

```ruby
InputOtp(length: 6, name: "otp", value: nil, pattern: nil, disabled: false) do
  InputOtpGroup do
    InputOtpSlot(index: 0)
    InputOtpSlot(index: 1)
    InputOtpSlot(index: 2)
  end
  InputOtpSeparator()
  InputOtpGroup do
    InputOtpSlot(index: 3)
    InputOtpSlot(index: 4)
    InputOtpSlot(index: 5)
  end
end
```

- `length:` (required) — number of characters, drives `maxlength` on the real input and the Stimulus `length` value.
- `pattern:` (optional regex string) — default is digits-only (`inputmode="numeric"`). Passed to the controller as a value, validated on input/paste.
- `name:`, `value:`, `disabled:` — forwarded to the real input for normal Rails form semantics (no separate hidden field needed, unlike `MaskedInput`).
- `InputOtpSlot(index:)` — explicit index, same as shadcn's `InputOTPSlot index={n}`. No implicit ordering/context magic.
- First/last rounded corners are handled per-group automatically via `first:`/`last:` Tailwind pseudo-classes — works because each `InputOtpGroup` is its own flex container.

## Stimulus controller (`ruby-ui--input-otp`)

Targets: `input` (the real input), `slot` (each `InputOtpSlot`).
Values: `length` (Number), `pattern` (String).

- `input` event → filter out characters not matching `pattern`, truncate to `length`, repaint all slots from the new value.
- `document` `selectionchange` listener (only while this controller's input is focused) → recompute which slot is "active" from `selectionStart`/`selectionEnd`, toggle `data-active` on the corresponding slot, show the blinking fake caret (`animate-caret-blink`) only on an active *empty* slot.
- `keydown` → intercept `ArrowLeft`/`ArrowRight`/`ArrowUp`/`ArrowDown`, `preventDefault`, move the selection to the adjacent slot explicitly.
- `paste` → read `clipboardData`, filter by `pattern`, truncate to `length`, set value, move caret to the end of the pasted content (or to the first empty slot).
- `focus`/`blur` → toggle a focused state on the container (for ring/outline styling).
- Dispatches a custom event `ruby-ui--input-otp:complete` (bubbles, `detail: { value }`) when the value reaches `length` characters — this is the Hotwire integration point (e.g. a Stimulus action elsewhere can do `data-action="ruby-ui--input-otp:complete->form#requestSubmit"` to auto-submit). Also dispatches `ruby-ui--input-otp:input` on every change for consumers that want live validation feedback.

Out of scope for v1 (flagged in the GH issue as possible follow-up, not blocking): password-manager badge width-push hack, `<noscript>` CSS fallback, iOS letter-spacing/font hacks from the upstream lib. These are polish from the original React lib's edge-case handling, not core OTP behavior.

## Accessibility

- The real `<input>` is the only element in the accessibility tree carrying the value — label it normally (`aria-label` or wrapping `<label for>`), no different from any other text input.
- Slots are `aria-hidden="true"` — purely decorative, prevents double-announcing characters to screen readers.
- `autocomplete="one-time-code"` on the real input for SMS autofill.
- `inputmode="numeric"` by default (digits-only pattern); becomes `inputmode="text"` if a custom `pattern` is supplied that isn't digit-only.

## Tests (`gem/test/ruby_ui/input_otp_test.rb`)

- Renders the real input with `name`, `value`, `maxlength` matching `length`.
- Renders the correct number of `InputOtpSlot`s with `aria-hidden`.
- `pattern:` shows up as the controller's pattern value / input `pattern` attribute.
- `InputOtpGroup`/`InputOtpSeparator` render with expected structure/classes.
- (JS behavior — auto-advance, arrow nav, paste, complete event — is not covered by Minitest; documented as manually verified in the docs page demo, consistent with how other Stimulus-heavy components in this gem are tested.)

## Docs page (`docs/app/views/docs/input_otp.rb`)

Two examples mirroring the shadcn demo: single group of 6 slots, and a 3+3 grouped example with `InputOtpSeparator`. Wiring: `docs_input_otp` route, `docs#input_otp` controller action, entry in `components_list.rb` and `site_files.rb`, controller import/registration in `docs/app/javascript/controllers/index.js`.

## GitHub issue

Filed in `ruby-ui/ruby_ui`, referencing the shadcn docs page and demo file, summarizing this design and the confirmed keyboard-behavior requirements.
