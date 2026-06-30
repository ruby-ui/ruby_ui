# InputOtp Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Phlex/Stimulus `InputOtp` compound component (root + `InputOtpGroup`/`InputOtpSlot`/`InputOtpSeparator`) to the `ruby_ui` gem, ported behaviorally from shadcn's InputOTP, and wire it into the `docs/` Rails app.

**Architecture:** One real `<input>` (transparent, absolutely positioned, stays in the a11y tree) drives state; decorative `aria-hidden` slot `<div>`s mirror its value/selection via a Stimulus controller. No new JS package — `input-otp` (the upstream JS lib) is React-only and can't be wrapped, so the controller reimplements the behavior directly.

**Tech Stack:** Phlex (Ruby views), Tailwind v4 (`tw-animate-css` already provides `animate-caret-blink`), Stimulus, Minitest.

## Global Constraints

- Component class names: `InputOtp`, `InputOtpGroup`, `InputOtpSlot`, `InputOtpSeparator` — no `OTP` acronym casing (matches `NativeSelect`/`DataTable` precedent; the gem's test loader derives class names by capitalizing each underscore-separated segment of the filename, so `input_otp.rb` → `InputOtp` automatically).
- No new entry in `gem/lib/generators/ruby_ui/dependencies.yml` — no new gem, no new JS package, no new component dependency.
- Every Ruby component file ends with a matching update to its test file and, where applicable, the docs wiring — per `gem/AGENTS.md` and root `CLAUDE.md` ("Don't edit a component without updating its docs page in the same PR").
- Run `cd gem && bundle exec rake` (tests + standardrb) after every Ruby task; it must stay green throughout.
- Use `mise exec -- <command>` (or ensure the `mise`-managed Ruby 3.4.7 / Node from `gem/.tool-versions` is on `PATH`) for every Ruby/bundle/pnpm command — the system Ruby (2.6) cannot run this gem's bundler lockfile.
- Work happens in the git worktree at `.claude/worktrees/input-otp` (branch `worktree-input-otp`), already set up with `bundle install` run and a clean baseline (`252 runs, 0 failures` before this work started).

---

### Task 1: `InputOtp` root component

**Files:**
- Create: `gem/lib/ruby_ui/input_otp/input_otp.rb`
- Test: `gem/test/ruby_ui/input_otp_test.rb`

**Interfaces:**
- Produces: `RubyUI::InputOtp.new(length:, pattern: nil, **attrs)` / Phlex::Kit call `InputOtp(length:, pattern: nil, **attrs, &block)`. Renders a wrapper `div` containing the yielded block (groups/slots) and a real `input` carrying `**attrs` (so `name:`, `value:`, `disabled:` etc. land on the real input, same convention as `RubyUI::Switch`).
- The real input carries `data-controller="ruby-ui--input-otp"`, Stimulus values `length` (Number) and `char-class` (String, defaults to `"[0-9]"` when no `pattern:` given), and target name `input`. Task 4's Stimulus controller and Task 3's `InputOtpSlot` both depend on this exact target/value naming — do not rename.

- [ ] **Step 1: Write the failing test**

Create `gem/test/ruby_ui/input_otp_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class RubyUI::InputOtpTest < ComponentTest
  def test_render_wires_stimulus_controller_and_values
    output = phlex { RubyUI.InputOtp(length: 6, name: "otp") }

    assert_match(/data-controller="ruby-ui--input-otp"/, output)
    assert_match(/data-ruby-ui--input-otp-length-value="6"/, output)
    assert_match(/data-ruby-ui--input-otp-char-class-value="\[0-9\]"/, output)
  end

  def test_render_forwards_form_attrs_to_real_input
    output = phlex { RubyUI.InputOtp(length: 6, name: "otp", value: "123") }

    assert_match(/name="otp"/, output)
    assert_match(/value="123"/, output)
    assert_match(/maxlength="6"/, output)
    assert_match(/autocomplete="one-time-code"/, output)
  end

  def test_render_defaults_to_numeric_inputmode_and_digit_pattern
    output = phlex { RubyUI.InputOtp(length: 4, name: "otp") }

    assert_match(/inputmode="numeric"/, output)
    assert_match(/pattern="\^\(\?:\[0-9\]\)\{4\}\$"/, output)
  end

  def test_render_with_custom_pattern_uses_text_inputmode
    output = phlex { RubyUI.InputOtp(length: 4, name: "otp", pattern: "[0-9A-Za-z]") }

    assert_match(/inputmode="text"/, output)
    assert_match(/data-ruby-ui--input-otp-char-class-value="\[0-9A-Za-z\]"/, output)
    assert_match(/pattern="\^\(\?:\[0-9A-Za-z\]\)\{4\}\$"/, output)
  end

  def test_render_yields_block_content
    output = phlex { RubyUI.InputOtp(length: 1, name: "otp") { div(id: "marker") } }

    assert_match(/id="marker"/, output)
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd gem && mise exec -- bundle exec rake test TEST=test/ruby_ui/input_otp_test.rb`
Expected: FAIL — `NameError` / `uninitialized constant RubyUI::InputOtp` (or similar autoload failure), since the component doesn't exist yet.

- [ ] **Step 3: Write the implementation**

Create `gem/lib/ruby_ui/input_otp/input_otp.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class InputOtp < Base
    def initialize(length:, pattern: nil, **attrs)
      @length = length
      @char_class = pattern || "[0-9]"
      super(**attrs)
    end

    def view_template(&block)
      div(class: "relative inline-flex items-center has-disabled:opacity-50") do
        div(class: "flex items-center gap-2", &block)
        input(**attrs)
      end
    end

    private

    def default_attrs
      {
        type: "text",
        inputmode: (@char_class == "[0-9]") ? "numeric" : "text",
        pattern: "^(?:#{@char_class}){#{@length}}$",
        maxlength: @length,
        autocomplete: "one-time-code",
        data: {
          controller: "ruby-ui--input-otp",
          ruby_ui__input_otp_length_value: @length,
          ruby_ui__input_otp_char_class_value: @char_class,
          ruby_ui__input_otp_target: "input",
          action: "input->ruby-ui--input-otp#onInput keydown->ruby-ui--input-otp#onKeydown paste->ruby-ui--input-otp#onPaste focus->ruby-ui--input-otp#onFocus blur->ruby-ui--input-otp#onBlur"
        },
        class: "absolute inset-0 h-full w-full cursor-text border-0 bg-transparent p-0 text-transparent caret-transparent outline-none selection:bg-transparent disabled:cursor-not-allowed"
      }
    end
  end
end
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd gem && mise exec -- bundle exec rake test TEST=test/ruby_ui/input_otp_test.rb`
Expected: `5 runs, ... 0 failures, 0 errors`

- [ ] **Step 5: Commit**

```bash
git add gem/lib/ruby_ui/input_otp/input_otp.rb gem/test/ruby_ui/input_otp_test.rb
git commit -m "[Feature] Add InputOtp root component"
```

---

### Task 2: `InputOtpGroup` and `InputOtpSeparator`

**Files:**
- Create: `gem/lib/ruby_ui/input_otp/input_otp_group.rb`
- Create: `gem/lib/ruby_ui/input_otp/input_otp_separator.rb`
- Modify (append to): `gem/test/ruby_ui/input_otp_test.rb`

**Interfaces:**
- Produces: `InputOtpGroup(**attrs, &block)` — plain flex wrapper `div`, no Stimulus involvement.
- Produces: `InputOtpSeparator(**attrs, &block)` — `div[role=separator]` rendering an inline minus-icon SVG by default, or the given block instead.
- Consumes nothing from Task 1; purely visual siblings inside `InputOtp`'s yielded block.

- [ ] **Step 1: Write the failing tests**

Append to `gem/test/ruby_ui/input_otp_test.rb` (inside the existing `RubyUI::InputOtpTest` class, before the final `end`):

```ruby

  def test_group_renders_flex_wrapper
    output = phlex { RubyUI.InputOtpGroup { div(id: "marker") } }

    assert_match(/class="flex items-center"/, output)
    assert_match(/id="marker"/, output)
  end

  def test_separator_renders_role_with_default_icon
    output = phlex { RubyUI.InputOtpSeparator() }

    assert_match(/role="separator"/, output)
    assert_match(/<svg/, output)
  end

  def test_separator_renders_custom_block_instead_of_icon
    output = phlex { RubyUI.InputOtpSeparator { plain "-" } }

    assert_match(/role="separator"/, output)
    refute_match(/<svg/, output)
    assert_match(/-/, output)
  end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd gem && mise exec -- bundle exec rake test TEST=test/ruby_ui/input_otp_test.rb`
Expected: FAIL — `uninitialized constant RubyUI::InputOtpGroup` (and `InputOtpSeparator`).

- [ ] **Step 3: Write the implementation**

Create `gem/lib/ruby_ui/input_otp/input_otp_group.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class InputOtpGroup < Base
    def view_template(&block)
      div(**attrs, &block)
    end

    private

    def default_attrs
      {class: "flex items-center"}
    end
  end
end
```

Create `gem/lib/ruby_ui/input_otp/input_otp_separator.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class InputOtpSeparator < Base
    def view_template(&block)
      div(**attrs) do
        if block
          block.call
        else
          icon
        end
      end
    end

    def icon
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        viewbox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        stroke_width: "2",
        stroke_linecap: "round",
        stroke_linejoin: "round",
        class: "h-4 w-4"
      ) do |s|
        s.path(d: "M5 12h14")
      end
    end

    private

    def default_attrs
      {
        role: "separator",
        class: "text-muted-foreground"
      }
    end
  end
end
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd gem && mise exec -- bundle exec rake test TEST=test/ruby_ui/input_otp_test.rb`
Expected: `8 runs, ... 0 failures, 0 errors`

- [ ] **Step 5: Commit**

```bash
git add gem/lib/ruby_ui/input_otp/input_otp_group.rb gem/lib/ruby_ui/input_otp/input_otp_separator.rb gem/test/ruby_ui/input_otp_test.rb
git commit -m "[Feature] Add InputOtpGroup and InputOtpSeparator"
```

---

### Task 3: `InputOtpSlot`

**Files:**
- Create: `gem/lib/ruby_ui/input_otp/input_otp_slot.rb`
- Modify (append to): `gem/test/ruby_ui/input_otp_test.rb`

**Interfaces:**
- Produces: `InputOtpSlot(index:, **attrs)` — `div` with `aria-hidden="true"`, `data-ruby-ui--input-otp-target="slot"`, `data-index="<index>"`. No block/content — Task 4's Stimulus controller sets `textContent` and toggles `data-active`/`data-caret` on it at runtime.
- Consumes: the `ruby-ui--input-otp` controller scope from Task 1 (must be rendered inside an `InputOtp` block to be wired up — this component renders standalone for testing purposes, but is only functional nested inside `InputOtp`).

- [ ] **Step 1: Write the failing tests**

Append to `gem/test/ruby_ui/input_otp_test.rb`:

```ruby

  def test_slot_renders_aria_hidden_with_index_and_target
    output = phlex { RubyUI.InputOtpSlot(index: 3) }

    assert_match(/aria-hidden="true"/, output)
    assert_match(/data-index="3"/, output)
    assert_match(/data-ruby-ui--input-otp-target="slot"/, output)
  end

  def test_slot_renders_first_last_rounding_classes
    output = phlex { RubyUI.InputOtpSlot(index: 0) }

    assert_match(/first:rounded-l-md/, output)
    assert_match(/last:rounded-r-md/, output)
  end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd gem && mise exec -- bundle exec rake test TEST=test/ruby_ui/input_otp_test.rb`
Expected: FAIL — `uninitialized constant RubyUI::InputOtpSlot`.

- [ ] **Step 3: Write the implementation**

Create `gem/lib/ruby_ui/input_otp/input_otp_slot.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class InputOtpSlot < Base
    def initialize(index:, **attrs)
      @index = index
      super(**attrs)
    end

    def view_template
      div(**attrs)
    end

    private

    def default_attrs
      {
        aria_hidden: "true",
        data: {
          ruby_ui__input_otp_target: "slot",
          index: @index
        },
        class: [
          "relative flex h-9 w-9 items-center justify-center border-y border-r border-input text-sm shadow-xs transition-all",
          "first:rounded-l-md first:border-l last:rounded-r-md",
          "data-[active=true]:z-10 data-[active=true]:border-ring data-[active=true]:ring-2 data-[active=true]:ring-ring/50",
          "data-[caret=true]:after:content-[''] data-[caret=true]:after:absolute data-[caret=true]:after:h-4 data-[caret=true]:after:w-px data-[caret=true]:after:animate-caret-blink data-[caret=true]:after:bg-foreground"
        ]
      }
    end
  end
end
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd gem && mise exec -- bundle exec rake test TEST=test/ruby_ui/input_otp_test.rb`
Expected: `10 runs, ... 0 failures, 0 errors`

- [ ] **Step 5: Run full gem suite + lint, then commit**

Run: `cd gem && mise exec -- bundle exec rake`
Expected: all existing tests still pass (`262 runs` — 252 baseline + 10 new — `0 failures, 0 errors`), `no offenses detected`.

```bash
git add gem/lib/ruby_ui/input_otp/input_otp_slot.rb gem/test/ruby_ui/input_otp_test.rb
git commit -m "[Feature] Add InputOtpSlot"
```

---

### Task 4: Stimulus controller (`ruby-ui--input-otp`)

**Files:**
- Create: `gem/lib/ruby_ui/input_otp/input_otp_controller.js`

**Interfaces:**
- Consumes: target `input` (Task 1's real `<input>`), target array `slot` (Task 3's `InputOtpSlot` divs, each carrying `data-index`), Stimulus values `lengthValue` (Number), `charClassValue` (String).
- Produces: custom events `ruby-ui--input-otp:input` and `ruby-ui--input-otp:complete`, both with `detail: { value }`, dispatched on the controller's element (bubbles by default via Stimulus `dispatch`) — this is the integration point for Hotwire/Turbo consumers (e.g. auto-submitting a form on complete).
- No Minitest coverage — this codebase has no JS test runner (verified: no `package.json` test script, no `.test.js`/`.spec.js` files anywhere in the repo). Behavior is verified manually in Task 6's browser check, consistent with how every other Stimulus controller in this gem is validated.

- [ ] **Step 1: Write the implementation**

Create `gem/lib/ruby_ui/input_otp/input_otp_controller.js`:

```js
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ruby-ui--input-otp"
export default class extends Controller {
  static targets = ["input", "slot"]
  static values = { length: Number, charClass: String }

  connect() {
    this.paint()
    this.boundOnSelectionChange = this.onSelectionChange.bind(this)
    document.addEventListener("selectionchange", this.boundOnSelectionChange)
  }

  disconnect() {
    document.removeEventListener("selectionchange", this.boundOnSelectionChange)
  }

  onInput() {
    const filtered = this.filter(this.inputTarget.value).slice(0, this.lengthValue)
    if (filtered !== this.inputTarget.value) this.inputTarget.value = filtered

    this.paint()
    this.dispatch("input", { detail: { value: filtered } })
    if (filtered.length === this.lengthValue) {
      this.dispatch("complete", { detail: { value: filtered } })
    }
  }

  onFocus() {
    const end = this.inputTarget.value.length
    const start = Math.min(end, this.lengthValue - 1)
    this.inputTarget.setSelectionRange(start, end)
    this.paint()
  }

  onBlur() {
    this.paint()
  }

  onKeydown(event) {
    const moves = { ArrowLeft: -1, ArrowUp: -1, ArrowRight: 1, ArrowDown: 1 }
    if (!(event.key in moves)) return

    event.preventDefault()
    const current = this.inputTarget.selectionStart ?? 0
    const next = Math.min(Math.max(current + moves[event.key], 0), this.lengthValue - 1)
    this.inputTarget.setSelectionRange(next, next)
    this.paint()
  }

  onPaste(event) {
    event.preventDefault()
    const pasted = this.filter(event.clipboardData.getData("text/plain"))
    if (!pasted) return

    const start = this.inputTarget.selectionStart ?? 0
    const end = this.inputTarget.selectionEnd ?? start
    const current = this.inputTarget.value
    const merged = (current.slice(0, start) + pasted + current.slice(end)).slice(0, this.lengthValue)

    this.inputTarget.value = merged
    const caret = Math.min(merged.length, this.lengthValue - 1)
    this.inputTarget.setSelectionRange(caret, merged.length)

    this.paint()
    this.dispatch("input", { detail: { value: merged } })
    if (merged.length === this.lengthValue) this.dispatch("complete", { detail: { value: merged } })
  }

  onSelectionChange() {
    if (document.activeElement !== this.inputTarget) return
    this.paint()
  }

  filter(raw) {
    const re = new RegExp(this.charClassValue)
    return raw.split("").filter((char) => re.test(char)).join("")
  }

  paint() {
    const value = this.inputTarget.value
    const isFocused = document.activeElement === this.inputTarget
    const start = this.inputTarget.selectionStart ?? value.length
    const end = this.inputTarget.selectionEnd ?? value.length
    const activeIndex = Math.min(start, this.lengthValue - 1)

    this.slotTargets.forEach((slot) => {
      const index = Number(slot.dataset.index)
      const char = value[index] ?? ""
      const isActive = isFocused && ((start === end && index === activeIndex) || (index >= start && index < end))

      slot.textContent = char
      slot.dataset.active = isActive ? "true" : "false"
      slot.dataset.caret = isActive && char === "" ? "true" : "false"
    })
  }
}
```

- [ ] **Step 2: Run the full gem suite to confirm nothing broke**

Run: `cd gem && mise exec -- bundle exec rake`
Expected: unchanged — `262 runs, ... 0 failures, 0 errors`, `no offenses detected` (this file isn't Ruby, so `rake` won't execute it, but it must not break file discovery — `gem/test/test_helper.rb`'s `Dir.glob("lib/ruby_ui/**/*.rb")` only globs `.rb` files, so the `.js` file is inert here by design).

- [ ] **Step 3: Commit**

```bash
git add gem/lib/ruby_ui/input_otp/input_otp_controller.js
git commit -m "[Feature] Add InputOtp Stimulus controller"
```

---

### Task 5: Gem docs template (`input_otp_docs.rb`)

**Files:**
- Create: `gem/lib/ruby_ui/input_otp/input_otp_docs.rb`

**Interfaces:**
- Produces: `Views::Docs::InputOtp`, a Phlex view class. Excluded from the test loader (`gem/test/test_helper.rb` rejects `_docs.rb` files) and excluded from the consumer-app generator by default (`gem/lib/generators/ruby_ui/component_generator.rb` filters `_docs.rb` files unless `--with-docs` is passed) — this file is documentation-as-installable-template, not exercised by `rake test`.
- This file's content must be byte-identical to `docs/app/views/docs/input_otp.rb` created in Task 6 (matches the established `masked_input` precedent, verified via `diff` — both copies are intentionally kept in sync).

- [ ] **Step 1: Write the file**

Create `gem/lib/ruby_ui/input_otp/input_otp_docs.rb`:

```ruby
# frozen_string_literal: true

class Views::Docs::InputOtp < Views::Base
  def view_template
    component = "InputOtp"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Input OTP", description: "Accessible one-time-password input with keyboard navigation and paste support.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          InputOtp(length: 6, name: "otp") do
            InputOtpGroup do
              InputOtpSlot(index: 0)
              InputOtpSlot(index: 1)
              InputOtpSlot(index: 2)
              InputOtpSlot(index: 3)
              InputOtpSlot(index: 4)
              InputOtpSlot(index: 5)
            end
          end
        RUBY
      end

      Heading(level: 2) { "Grouped with separator" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          InputOtp(length: 6, name: "otp") do
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
        RUBY
      end

      Heading(level: 2) { "Custom pattern" }

      Text { "Pass pattern: with a single-character regex class (default is \"[0-9]\") to accept other characters, e.g. letters and digits." }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          InputOtp(length: 6, name: "otp", pattern: "[0-9A-Za-z]") do
            InputOtpGroup do
              InputOtpSlot(index: 0)
              InputOtpSlot(index: 1)
              InputOtpSlot(index: 2)
              InputOtpSlot(index: 3)
              InputOtpSlot(index: 4)
              InputOtpSlot(index: 5)
            end
          end
        RUBY
      end

      Heading(level: 2) { "Reacting to completion" }

      Text { "The controller dispatches a ruby-ui--input-otp:complete custom event (detail: { value }) once the value reaches length characters, and a ruby-ui--input-otp:input event on every change. Wire a Stimulus action on a parent element to react — for example, to auto-submit a form:" }

      Codeblock(<<~JS, syntax: :javascript)
        // app/javascript/controllers/otp_form_controller.js
        import { Controller } from "@hotwired/stimulus"

        export default class extends Controller {
          submit() {
            this.element.requestSubmit()
          }
        }
      JS

      Codeblock(<<~HTML, syntax: :html)
        <form data-controller="otp-form" data-action="ruby-ui--input-otp:complete->otp-form#submit">
          <!-- InputOtp(...) here -->
        </form>
      HTML

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
```

- [ ] **Step 2: Run the full gem suite**

Run: `cd gem && mise exec -- bundle exec rake`
Expected: still `262 runs, ... 0 failures, 0 errors`, `no offenses detected` — `_docs.rb` files are excluded from both the autoload-as-class-under-test path and standardrb's component checks are still subject to standard Ruby lint, so confirm no offenses were introduced.

- [ ] **Step 3: Commit**

```bash
git add gem/lib/ruby_ui/input_otp/input_otp_docs.rb
git commit -m "[Documentation] Add InputOtp docs template"
```

---

### Task 6: Wire into the `docs/` Rails app

**Files:**
- Create: `docs/app/views/docs/input_otp.rb` (identical copy of Task 5's file, just confirm it stays byte-identical)
- Create: `docs/app/javascript/controllers/ruby_ui/input_otp_controller.js` (identical copy of Task 4's file)
- Modify: `docs/app/javascript/controllers/index.js`
- Modify: `docs/app/controllers/docs_controller.rb`
- Modify: `docs/config/routes.rb`
- Modify: `docs/app/components/shared/components_list.rb`
- Modify: `docs/app/lib/site_files.rb`

**Interfaces:**
- Consumes: `Views::Docs::InputOtp` (Task 5), `ruby-ui--input-otp` controller (Task 4).
- Produces: route `docs_input_otp_path` → `GET /docs/input_otp` → `DocsController#input_otp` → renders `Views::Docs::InputOtp.new`; sidebar entry "Input OTP"; registered Stimulus controller so the JS actually runs in the docs app (the gem's autoloader only loads `.rb` files directly from the gem path — `.js` controllers must be physically present under `docs/app/javascript/controllers/`, confirmed by the existing `masked_input_controller.js` being duplicated there).

- [ ] **Step 1: Copy the docs view**

```bash
cp gem/lib/ruby_ui/input_otp/input_otp_docs.rb docs/app/views/docs/input_otp.rb
diff gem/lib/ruby_ui/input_otp/input_otp_docs.rb docs/app/views/docs/input_otp.rb
```
Expected: `diff` prints nothing (files identical).

- [ ] **Step 2: Copy the Stimulus controller**

```bash
mkdir -p docs/app/javascript/controllers/ruby_ui
cp gem/lib/ruby_ui/input_otp/input_otp_controller.js docs/app/javascript/controllers/ruby_ui/input_otp_controller.js
diff gem/lib/ruby_ui/input_otp/input_otp_controller.js docs/app/javascript/controllers/ruby_ui/input_otp_controller.js
```
Expected: `diff` prints nothing.

- [ ] **Step 3: Register the controller**

In `docs/app/javascript/controllers/index.js`, insert between the existing `HoverCard` block and the `MaskedInput` block (alphabetical placement, matches surrounding convention):

```js
import RubyUi__HoverCardController from "./ruby_ui/hover_card_controller"
application.register("ruby-ui--hover-card", RubyUi__HoverCardController)

import RubyUi__InputOtpController from "./ruby_ui/input_otp_controller"
application.register("ruby-ui--input-otp", RubyUi__InputOtpController)

import RubyUi__MaskedInputController from "./ruby_ui/masked_input_controller"
application.register("ruby-ui--masked-input", RubyUi__MaskedInputController)
```

- [ ] **Step 4: Add the controller action**

In `docs/app/controllers/docs_controller.rb`, insert between the existing `input` action and `link` action:

```ruby
  def input
    render Views::Docs::Input.new
  end

  def input_otp
    render Views::Docs::InputOtp.new
  end

  def link
    render Views::Docs::Link.new
  end
```

- [ ] **Step 5: Add the route**

In `docs/config/routes.rb`, insert between the existing `input` and `link` routes (line 52/53 before this change):

```ruby
    get "input", to: "docs#input", as: :docs_input
    get "input_otp", to: "docs#input_otp", as: :docs_input_otp
    get "link", to: "docs#link", as: :docs_link
```

- [ ] **Step 6: Add the sidebar/components-list entry**

In `docs/app/components/shared/components_list.rb`, insert between `Input` and `Link`:

```ruby
          {name: "Input", path: docs_input_path},
          {name: "Input OTP", path: docs_input_otp_path},
          {name: "Link", path: docs_link_path},
```

- [ ] **Step 7: Add the site_files entry**

In `docs/app/lib/site_files.rb`, insert between `Input` and `Link`:

```ruby
    {title: "Input", path: "/docs/input", description: "Styled input field primitive."},
    {title: "Input OTP", path: "/docs/input_otp", description: "One-time-password input with keyboard navigation and paste support."},
    {title: "Link", path: "/docs/link", description: "Link component with button-like and underline variants."},
```

- [ ] **Step 8: Verify routes resolve**

Run: `cd docs && mise exec -- bin/rails routes -g input_otp`
Expected: prints the new `docs_input_otp GET /docs/input_otp docs#input_otp` line, no errors.

- [ ] **Step 9: Commit**

```bash
git add docs/app/views/docs/input_otp.rb docs/app/javascript/controllers/ruby_ui/input_otp_controller.js docs/app/javascript/controllers/index.js docs/app/controllers/docs_controller.rb docs/config/routes.rb docs/app/components/shared/components_list.rb docs/app/lib/site_files.rb
git commit -m "[Feature] Wire InputOtp into the docs site"
```

---

### Task 7: Manual browser verification + final check

**Files:** none (verification only).

**Interfaces:** none — this task exercises Tasks 1–6 end-to-end through a running server. There is no automated coverage for keyboard navigation, paste, or the `complete` event (see Task 4) — this is the only verification they get, so it is not optional.

- [ ] **Step 1: Build docs assets and boot the server**

```bash
cd docs
mise exec -- bundle install
mise exec -- pnpm install
mise exec -- pnpm build && mise exec -- pnpm build:css
mise exec -- bin/rails db:prepare
mise exec -- bin/rails server -b 0.0.0.0 -p 3001 &
```
Expected: server starts without errors, listening on port 3001 (use 3001 if 3000 is occupied locally, per root `CLAUDE.local.md` convention — `gem` is consumed via the monorepo's `path: "../gem"` Gemfile entry, so no extra Gemfile edits are needed).

- [ ] **Step 2: Open the docs page in a browser and check rendering**

Navigate to `http://localhost:3001/docs/input_otp`. Confirm:
- The "Usage" example renders 6 visible slot boxes in a single row.
- The "Grouped with separator" example renders two groups of 3 with a minus-icon separator between them.
- No console errors on load.

- [ ] **Step 3: Exercise keyboard behavior**

Click the first slot, then:
- Type 6 digits — confirm each keystroke advances to the next slot and all 6 render.
- Press Backspace twice — confirm the last two slots clear and the active slot moves back.
- Press ArrowLeft/ArrowRight — confirm the active-slot highlight (ring) moves accordingly.
- Press ArrowUp/ArrowDown — confirm these also move the active-slot highlight (this does not happen natively on a single-line input — if it doesn't move, Task 4's `onKeydown` arrow handling is broken).
- Select all (Cmd/Ctrl+A) and type a replacement digit — confirm it overwrites from the start.

- [ ] **Step 4: Exercise paste**

Copy a 6-digit string (e.g. from a text editor), click slot 1, paste. Confirm all 6 slots fill and the caret highlight lands after the last filled slot (or on the last slot if the pasted string is exactly 6 chars).

- [ ] **Step 5: Exercise the custom event**

Open the browser devtools console on the docs page and run:
```js
document.querySelector('[data-controller="ruby-ui--input-otp"]')
  .addEventListener('ruby-ui--input-otp:complete', (e) => console.log('complete', e.detail))
```
Then type a full 6-digit code into the first example's slots. Confirm `complete {value: "..."}` is logged exactly once when the 6th digit lands.

- [ ] **Step 6: Run the full gem suite one last time**

Run: `cd gem && mise exec -- bundle exec rake`
Expected: `262 runs, 1106+N assertions, 0 failures, 0 errors, 0 skips`, `no offenses detected`.

- [ ] **Step 7: Stop the dev server**

```bash
kill %1
```
(or whatever job/PID the Task 7 Step 1 server is running as).

No commit for this task — it's verification only. If any check in Steps 2–5 fails, fix the relevant Task (1–6) file, re-run that task's tests, then re-run this task's checks from Step 2.
