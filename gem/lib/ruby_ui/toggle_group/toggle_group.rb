# frozen_string_literal: true

module RubyUI
  class ToggleGroup < Component
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
      @variant = enum(variant, Toggle::VARIANT_CLASSES, default: :default)
      @size = enum(size, Toggle::SIZE_CLASSES, default: :default)
      @disabled = disabled
      @spacing = spacing
      super(**attrs)
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

    # Called on the block argument — `render ToggleGroup.new do |group| … group.ToggleGroupItem(…) { "L" } end` —
    # from inside the block render_in is capturing, so the view context is there.
    def ToggleGroupItem(**kwargs, &block)
      helpers.render(RubyUI::ToggleGroupItem.new(group_context: item_context, **kwargs), &block)
    end

    # [name, value] for each hidden input; none without a name. The single
    # name is passed as given — a Symbol dasherizes in Attributes.flat, as it
    # did in Phlex; the multiple names are interpolated Strings, as in 1.6.
    def hidden_inputs
      return [] unless @name

      if @type == :single
        [[@name, selected_values.first.to_s]]
      else
        selected_values.map { |v| ["#{@name}[]", v] }
      end
    end

    def hidden_input_attrs(name, value)
      Attributes.flat(type: "hidden", name: name, value: value, data: {"ruby-ui--toggle-group-target": "input"})
    end

    private

    def selected_values
      case @type
      when :single then @value.nil? ? [] : [@value.to_s]
      when :multiple then Array(@value).map(&:to_s)
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
