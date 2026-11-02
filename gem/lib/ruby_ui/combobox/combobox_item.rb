# frozen_string_literal: true

module RubyUI
  # An option. Its value travels in a native radio (or checkbox, when the root
  # is multiple:) named after the root's name:, kept visually hidden so forms,
  # required and FormField work without JavaScript glue. input: adds attributes
  # to that input (e.g. data: {value_missing: "..."}).
  class ComboboxItem < Base
    include ComboboxContext

    ITEM = [
      "group/combobox-item relative flex w-full cursor-default items-center gap-2 rounded-sm py-1.5 pr-8 pl-2",
      "text-sm outline-hidden select-none",
      "data-highlighted:bg-accent data-highlighted:text-accent-foreground",
      "not-data-[variant=destructive]:data-highlighted:**:text-accent-foreground",
      "data-disabled:pointer-events-none data-disabled:opacity-50",
      "[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
    ].freeze

    def initialize(value:, selected: false, disabled: false, text: nil, input: {}, **)
      @value = value
      @selected = selected
      @disabled = disabled
      @text = text
      @input_attrs = input
      super(**)
    end

    def view_template(&)
      div(**attrs) do
        native_input
        yield if block_given?
        indicator
      end
    end

    private

    def multiple? = !!combobox[:multiple]

    def native_input
      data = if multiple?
        {
          ruby_ui__checkbox_group_target: "checkbox",
          action: "change->ruby-ui--checkbox-group#onChange change->ruby-ui--form-field#onInput invalid->ruby-ui--form-field#onInvalid"
        }
      else
        {action: "change->ruby-ui--form-field#onInput invalid->ruby-ui--form-field#onInvalid"}
      end
      data[:ruby_ui__form_field_target] = "input"

      input(**mix({
        type: multiple? ? "checkbox" : "radio",
        name: combobox[:name],
        value: @value,
        checked: @selected,
        disabled: @disabled || combobox[:disabled],
        required: !multiple? && combobox[:required],
        tabindex: -1,
        aria: {hidden: "true"},
        class: "sr-only",
        data: data
      }, @input_attrs))
    end

    def indicator
      span(class: "pointer-events-none absolute right-2 hidden size-4 items-center justify-center group-aria-selected/combobox-item:flex", aria: {hidden: "true"}) do
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          viewbox: "0 0 24 24",
          fill: "none",
          stroke: "currentColor",
          stroke_width: "2",
          stroke_linecap: "round",
          stroke_linejoin: "round",
          aria_hidden: "true",
          class: "pointer-events-none size-4"
        ) { |s| s.path(d: "M20 6 9 17l-5-5") }
      end
    end

    def default_attrs
      {
        role: "option",
        aria: {selected: @selected.to_s, disabled: (@disabled ? "true" : nil)},
        data: {
          slot: "combobox-item",
          ruby_ui__combobox_target: "item",
          value: @value,
          text: @text,
          disabled: (@disabled ? "" : nil),
          action: "click->ruby-ui--combobox#select pointermove->ruby-ui--combobox#hover"
        },
        class: ITEM
      }
    end
  end
end
