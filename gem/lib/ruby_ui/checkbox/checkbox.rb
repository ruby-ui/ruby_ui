# frozen_string_literal: true

module RubyUI
  # A checkbox, styled after shadcn's Checkbox (Base UI + vega). Renders a
  # native <input type="checkbox"> instead of Base UI's span[role=checkbox]
  # plus hidden input. The check mark is the input's ::before (a mask of
  # lucide's CheckIcon in text-primary-foreground) and ::after widens the hit
  # area, so there is no wrapper and peer-* classes on a following label keep
  # working.
  #
  # indeterminate: true shows the mixed state (minus icon); the browser clears
  # it on the first click. readonly: true keeps the value but blocks toggling
  # (aria-readonly; the readonly attribute does nothing on checkboxes).
  # unchecked_value: renders a hidden input with the same name before the
  # checkbox, so the form sends that value when the box is unchecked (Rails'
  # check_box pattern).
  class Checkbox < Base
    BASE = [
      "peer relative size-4 shrink-0 appearance-none rounded-[4px] border border-input bg-transparent p-0",
      # High contrast: give the drawing back to the browser (as @tailwindcss/forms does).
      "forced-colors:appearance-auto forced-colors:checked:before:hidden forced-colors:indeterminate:before:hidden",
      "text-inherit shadow-xs transition-shadow outline-none dark:bg-input/30",
      "after:absolute after:-inset-x-3 after:-inset-y-2",
      "before:pointer-events-none before:absolute before:inset-0 before:m-auto before:hidden before:size-3.5",
      "before:bg-current before:[mask-position:center] before:[mask-repeat:no-repeat] before:[mask-size:100%]",
      "focus:ring-0 focus:ring-offset-0 focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50",
      "disabled:cursor-not-allowed disabled:opacity-50 group-has-disabled/field:opacity-50",
      "aria-disabled:cursor-not-allowed aria-disabled:opacity-50 aria-disabled:pointer-events-none",
      "aria-invalid:border-destructive aria-invalid:ring-3 aria-invalid:ring-destructive/20",
      "dark:aria-invalid:border-destructive/50 dark:aria-invalid:ring-destructive/40",
      # Checked: lucide CheckIcon.
      "checked:border-primary checked:bg-primary checked:bg-none checked:text-primary-foreground",
      "dark:checked:bg-primary aria-invalid:checked:border-primary checked:before:block",
      "checked:before:[mask-image:url(data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%2024%2024%22%20fill%3D%22none%22%20stroke%3D%22black%22%20stroke-width%3D%222%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%3E%3Cpath%20d%3D%22M20%206%209%2017l-5-5%22%2F%3E%3C%2Fsvg%3E)]",
      # Indeterminate: lucide MinusIcon (the indeterminate variant comes after checked, so it wins).
      "indeterminate:border-primary indeterminate:bg-primary indeterminate:bg-none indeterminate:text-primary-foreground",
      "dark:indeterminate:bg-primary indeterminate:before:block",
      "indeterminate:before:[mask-image:url(data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%2024%2024%22%20fill%3D%22none%22%20stroke%3D%22black%22%20stroke-width%3D%222%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%3E%3Cpath%20d%3D%22M5%2012h14%22%2F%3E%3C%2Fsvg%3E)]"
    ].freeze

    ACTIONS = "change->ruby-ui--checkbox-group#onChange change->ruby-ui--form-field#onInput invalid->ruby-ui--form-field#onInvalid ruby-ui--checkbox-group:change->ruby-ui--form-field#onChange"

    def initialize(indeterminate: false, readonly: false, unchecked_value: nil, **attrs)
      @indeterminate = indeterminate
      @readonly = readonly
      @unchecked_value = unchecked_value
      super(**attrs)
      raise ArgumentError, "unchecked_value: needs name:" if @unchecked_value && !attrs[:name]
    end

    def view_template
      if @unchecked_value
        input(type: "hidden", name: attrs[:name], value: @unchecked_value, disabled: attrs[:disabled], form: attrs[:form], autocomplete: "off")
      end
      input(**attrs)
    end

    private

    def default_attrs
      {
        type: "checkbox",
        aria: (@readonly ? {readonly: "true"} : {}),
        data: {
          slot: "checkbox",
          ruby_ui__form_field_target: "input",
          ruby_ui__checkbox_group_target: "checkbox",
          **controller_data
        },
        class: BASE
      }
    end

    # The checkbox controller is only needed for indeterminate (a JS-only
    # property) and readonly (blocking the toggle).
    def controller_data
      return {action: ACTIONS} unless @indeterminate || @readonly

      {
        controller: "ruby-ui--checkbox",
        ruby_ui__checkbox_indeterminate_value: @indeterminate.to_s,
        ruby_ui__checkbox_readonly_value: @readonly.to_s,
        action: "click->ruby-ui--checkbox#guard change->ruby-ui--checkbox#sync #{ACTIONS}"
      }
    end
  end
end
