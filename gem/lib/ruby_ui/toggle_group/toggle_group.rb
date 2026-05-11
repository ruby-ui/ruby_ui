# frozen_string_literal: true

module RubyUI
  class ToggleGroup < Base
    SPACING_GAP = {0 => nil, 1 => "gap-1", 2 => "gap-2", 3 => "gap-3", 4 => "gap-4"}.freeze
    VALID_TYPES = [:single, :multiple].freeze
    VALID_ORIENTATIONS = [:horizontal, :vertical].freeze

    def initialize(
      type: :single,
      name: nil,
      value: nil,
      variant: :default,
      size: :default,
      disabled: false,
      spacing: 0,
      orientation: :horizontal,
      **attrs
    )
      @type = type.to_sym
      raise ArgumentError, "type must be :single or :multiple" unless VALID_TYPES.include?(@type)

      @orientation = orientation.to_sym
      raise ArgumentError, "orientation must be :horizontal or :vertical" unless VALID_ORIENTATIONS.include?(@orientation)

      raise ArgumentError, "spacing must be an Integer 0..4" unless spacing.is_a?(Integer) && (0..4).cover?(spacing)

      @name = name
      @value = value
      @variant = variant.to_sym
      @size = size.to_sym
      @disabled = disabled
      @spacing = spacing
      super(**attrs)
    end

    def view_template(&block)
      div(**attrs) do
        yield(self)
        render_hidden_inputs
      end
    end

    def item_context
      {
        type: @type,
        variant: @variant,
        size: @size,
        disabled: @disabled,
        selected_values: selected_values,
        spacing: @spacing,
        orientation: @orientation
      }
    end

    def ToggleGroupItem(**kwargs, &block)
      render RubyUI::ToggleGroupItem.new(group_context: item_context, **kwargs), &block
    end

    private

    def selected_values
      case @type
      when :single then @value.nil? ? [] : [@value.to_s]
      when :multiple then Array(@value).map(&:to_s)
      end
    end

    def render_hidden_inputs
      return unless @name

      if @type == :single
        input(
          type: "hidden",
          name: @name,
          value: selected_values.first.to_s,
          data: {"ruby-ui--toggle-group-target": "input"}
        )
      else
        selected_values.each do |v|
          input(
            type: "hidden",
            name: "#{@name}[]",
            value: v,
            data: {"ruby-ui--toggle-group-target": "input"}
          )
        end
      end
    end

    def default_attrs
      {
        role: (@type == :single) ? "radiogroup" : "group",
        data: {
          controller: "ruby-ui--toggle-group",
          "ruby-ui--toggle-group-type-value": @type.to_s,
          "ruby-ui--toggle-group-name-value": @name.to_s,
          orientation: @orientation.to_s,
          spacing: @spacing.to_s
        },
        class: container_classes
      }
    end

    def container_classes
      base = if @orientation == :vertical
        "flex w-fit flex-col items-stretch rounded-md"
      else
        "flex w-fit items-center rounded-md"
      end

      [
        base,
        SPACING_GAP[@spacing],
        (@spacing == 0 && @variant == :outline) ? "shadow-xs" : nil
      ].compact
    end
  end
end
