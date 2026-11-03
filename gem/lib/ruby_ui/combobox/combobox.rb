# frozen_string_literal: true

require "securerandom"

module RubyUI
  # Root of a combobox. Like Base UI's Combobox.Root it has no look of its own:
  # it holds the Stimulus controller and shares name/multiple with the parts
  # through the Phlex context, so each ComboboxItem renders the native
  # radio/checkbox that carries its value in the form.
  class Combobox < Base
    def initialize(name: nil, multiple: false, term: nil, disabled: false, required: false, id: nil, **)
      # Unnamed radios are separate groups, so a required one could never pass.
      raise ArgumentError, "name: is required when required: is true" if required && name.to_s.empty?

      @name = name
      @multiple = multiple
      @term = term
      @disabled = disabled
      @required = required
      @id = id || "combobox-#{SecureRandom.hex(4)}"
      super(**)
    end

    def view_template(&)
      previous = context[:ruby_ui_combobox]
      context[:ruby_ui_combobox] = {
        id: @id, name: @name, multiple: @multiple, disabled: @disabled, required: @required,
        content_id: "#{@id}-content", list_id: "#{@id}-list"
      }
      div(**attrs, &)
    ensure
      context[:ruby_ui_combobox] = previous
    end

    private

    def default_attrs
      {
        id: @id,
        data: {
          slot: "combobox",
          # A required multiple: combobox needs "at least one checked", which
          # checkboxes don't do natively: CheckboxGroup's controller adds it.
          controller: (@multiple && @required) ? "ruby-ui--combobox ruby-ui--checkbox-group" : "ruby-ui--combobox",
          required: ((@multiple && @required) ? "" : nil),
          ruby_ui__combobox_multiple_value: @multiple.to_s,
          ruby_ui__combobox_term_value: @term,
          disabled: (@disabled ? "true" : nil),
          action: "turbo:morph@window->ruby-ui--combobox#refresh"
        }
      }
    end
  end
end
