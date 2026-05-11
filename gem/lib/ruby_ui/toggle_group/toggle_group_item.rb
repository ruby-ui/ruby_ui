# frozen_string_literal: true

module RubyUI
  class ToggleGroupItem < Toggle
    def initialize(value:, group_context:, variant: nil, size: nil, **attrs)
      @item_value = value.to_s
      @group_context = group_context

      effective_variant = variant || group_context[:variant]
      effective_size = size || group_context[:size]
      pressed = group_context[:selected_values].include?(@item_value)
      disabled = group_context[:disabled]

      super(
        pressed: pressed,
        name: nil, # group owns form serialization
        value: @item_value,
        variant: effective_variant,
        size: effective_size,
        disabled: disabled,
        **attrs
      )
    end

    def view_template(&block)
      button(**attrs, &block)
    end

    private

    def default_attrs
      type = @group_context[:type]
      pressed = @pressed
      base_classes_attrs = super

      role_attrs =
        if type == :single
          {
            role: "radio",
            aria: {checked: pressed.to_s},
            tabindex: (pressed || @group_context[:roving_first]) ? "0" : "-1"
          }
        else
          {
            aria: {pressed: pressed.to_s},
            tabindex: "0"
          }
        end

      base_classes_attrs.merge(role_attrs).merge(
        data: {
          state: pressed ? "on" : "off",
          value: @item_value,
          "ruby-ui--toggle-group-target": "item",
          action: "click->ruby-ui--toggle-group#select keydown->ruby-ui--toggle-group#navigate"
        }
      ).tap do |h|
        # Strip Toggle-primitive's standalone controller wiring — group owns state
        h.delete(:controller) if h[:controller]
        if h[:data].is_a?(Hash)
          h[:data].delete(:controller) if h[:data][:controller]
          h[:data].delete(:"ruby-ui--toggle-pressed-value")
          h[:data].delete(:"ruby-ui--toggle-value-value")
          h[:data].delete(:"ruby-ui--toggle-unpressed-value-value")
        end
        # For :single, replace aria-pressed (set by parent default_attrs) with aria-checked semantics
        if type == :single && h[:aria].is_a?(Hash)
          h[:aria].delete(:pressed)
        end

        # Append item-level classes for shadcn joined/spaced look
        extra = ["w-auto min-w-0 shrink-0 px-3 focus:z-10 focus-visible:z-10"]
        spacing = @group_context[:spacing]
        orientation = @group_context[:orientation]
        variant = @group_context[:variant]
        if spacing == 0
          extra << "rounded-none shadow-none"
          if orientation == :vertical
            extra << "first-of-type:rounded-t-md last-of-type:rounded-b-md"
            extra << "border-t-0 first-of-type:border-t" if variant == :outline
          else
            extra << "first-of-type:rounded-l-md last-of-type:rounded-r-md"
            extra << "border-l-0 first-of-type:border-l" if variant == :outline
          end
        end
        h[:class] = [h[:class], *extra].flatten.compact
      end
    end
  end
end
