# frozen_string_literal: true

module RubyUI
  class ToggleGroupItem < Toggle
    JOIN_BASE = "w-auto min-w-0 shrink-0 px-3 focus:z-10 focus-visible:z-10"

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
      attrs = {type: "button"}
      attrs[:disabled] = true if @disabled
      attrs[:data] = {
        state: @pressed ? "on" : "off",
        value: @item_value,
        "ruby-ui--toggle-group-target": "item",
        action: "click->ruby-ui--toggle-group#select keydown->ruby-ui--toggle-group#navigate"
      }
      attrs[:class] = [Toggle.classes_for(variant: @variant, size: @size), join_classes]

      if @group_context[:type] == :single
        attrs[:role] = "radio"
        attrs[:aria] = {checked: @pressed.to_s}
        attrs[:tabindex] = @pressed ? "0" : "-1"
      else
        attrs[:aria] = {pressed: @pressed.to_s}
        attrs[:tabindex] = "0"
      end

      attrs
    end

    def join_classes
      classes = [JOIN_BASE]
      return classes unless @group_context[:spacing] == 0

      classes << "rounded-none shadow-none"
      if @group_context[:orientation] == :vertical
        classes << "first-of-type:rounded-t-md last-of-type:rounded-b-md"
        classes << "border-t-0 first-of-type:border-t" if @group_context[:variant] == :outline
      else
        classes << "first-of-type:rounded-l-md last-of-type:rounded-r-md"
        classes << "border-l-0 first-of-type:border-l" if @group_context[:variant] == :outline
      end
      classes
    end
  end
end
