# frozen_string_literal: true

module RubyUI
  class ToggleGroupItem < Toggle
    JOIN_BASE = "shrink-0 focus:z-10 focus-visible:z-10 data-[state=on]:bg-muted"
    # Joined groups (spacing 0): vega's cn-toggle-group-item padding and corners.
    JOINED = "rounded-none shadow-none px-2 has-data-[icon=inline-end]:pr-1.5 has-data-[icon=inline-start]:pl-1.5"

    def initialize(value:, group_context:, variant: nil, size: nil, **attrs)
      @item_value = value.to_s
      @group_context = group_context

      pressed = group_context[:selected_values].include?(@item_value)
      super(
        pressed: pressed,
        name: nil,
        value: @item_value,
        variant: variant || group_context[:variant],
        size: size || group_context[:size],
        disabled: group_context[:disabled],
        **attrs
      )
    end

    def view_template(&block)
      button(**attrs, &block)
    end

    private

    def default_attrs
      attrs = {type: "button", aria: {pressed: @pressed.to_s}, tabindex: initial_tabindex}
      attrs[:disabled] = true if @disabled

      data = {
        slot: "toggle-group-item",
        variant: @variant.to_s,
        size: @size.to_s,
        spacing: @group_context[:spacing].to_s,
        state: @pressed ? "on" : "off",
        value: @item_value,
        "ruby-ui--toggle-group-target": "item",
        action: "click->ruby-ui--toggle-group#select keydown->ruby-ui--toggle-group#navigate"
      }
      data[:pressed] = "" if @pressed
      data[:disabled] = "" if @disabled
      attrs[:data] = data
      attrs[:class] = [Toggle.classes_for(variant: @variant, size: @size), join_classes]
      attrs
    end

    # One tab stop per group: a pressed item when there is a selection, every
    # item until the controller connects otherwise (it then keeps only one).
    def initial_tabindex
      return "0" if @group_context[:selected_values].empty?

      @pressed ? "0" : "-1"
    end

    def join_classes
      classes = [JOIN_BASE]
      return classes unless @group_context[:spacing] == 0

      classes << JOINED
      if @group_context[:orientation] == :vertical
        classes << "first-of-type:rounded-t-md last-of-type:rounded-b-md"
        classes << "border-t-0 first-of-type:border-t" if @variant == :outline
      else
        classes << "first-of-type:rounded-l-md last-of-type:rounded-r-md"
        classes << "border-l-0 first-of-type:border-l" if @variant == :outline
      end
      classes
    end
  end
end
