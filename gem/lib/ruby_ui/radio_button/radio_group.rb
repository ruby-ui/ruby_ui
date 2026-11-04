# frozen_string_literal: true

module RubyUI
  # Wraps RadioButtons in role="radiogroup", like shadcn's RadioGroup (Base UI
  # + vega). Give it a name with aria: {labelledby:} or aria: {label:}.
  # Group-level options (name, disabled, required) stay on each RadioButton,
  # as native radios take them.
  class RadioGroup < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        role: "radiogroup",
        data: {slot: "radio-group"},
        class: "grid w-full gap-3"
      }
    end
  end
end
