# frozen_string_literal: true

module RubyUI
  # A radio, styled after shadcn's RadioGroupItem (Base UI + vega). Renders a
  # native <input type="radio"> instead of Base UI's span[role=radio] plus
  # hidden input, so arrow keys, roving focus, required and form submission
  # come from the browser. The dot is the input's ::before (size-2 in
  # text-primary-foreground) and ::after widens the hit area, so there is no
  # wrapper and peer-* classes on a following label keep working.
  #
  # Radios group by name:. Wrap them in RadioGroup for role="radiogroup".
  class RadioButton < Base
    BASE = [
      "peer relative aspect-square size-4 shrink-0 appearance-none rounded-full border border-input bg-transparent p-0",
      # High contrast: give the drawing back to the browser (as @tailwindcss/forms does).
      "forced-colors:appearance-auto forced-colors:checked:before:hidden",
      "text-inherit outline-none dark:bg-input/30",
      "after:absolute after:-inset-x-3 after:-inset-y-2",
      "before:pointer-events-none before:absolute before:top-1/2 before:left-1/2 before:hidden before:size-2",
      "before:-translate-x-1/2 before:-translate-y-1/2 before:rounded-full before:bg-current",
      "focus:ring-0 focus:ring-offset-0 focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50",
      "disabled:cursor-not-allowed disabled:opacity-50",
      "aria-disabled:cursor-not-allowed aria-disabled:opacity-50 aria-disabled:pointer-events-none",
      "aria-invalid:border-destructive aria-invalid:ring-3 aria-invalid:ring-destructive/20",
      "dark:aria-invalid:border-destructive/50 dark:aria-invalid:ring-destructive/40",
      "group-has-[:focus-visible]/field-label:ring-0 group-has-[:focus-visible]/field-label:not-checked:border-input",
      # Checked: the dot.
      "checked:border-primary checked:bg-primary checked:bg-none checked:text-primary-foreground",
      "dark:checked:bg-primary aria-invalid:checked:border-primary checked:before:block",
      "group-has-[:focus-visible]/field-label:checked:border-primary"
    ].freeze

    def view_template
      input(**attrs)
    end

    private

    def default_attrs
      {
        type: "radio",
        data: {
          slot: "radio-group-item",
          ruby_ui__form_field_target: "input",
          action: "change->ruby-ui--form-field#onInput invalid->ruby-ui--form-field#onInvalid"
        },
        class: BASE
      }
    end
  end
end
