# frozen_string_literal: true

module RubyUI
  class ToggleGroup < Base
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
      raise ArgumentError, "type must be :single or :multiple" unless [:single, :multiple].include?(@type)
      @name = name
      @value = value
      @variant = variant.to_sym
      @size = size.to_sym
      @disabled = disabled
      @spacing = spacing
      raise ArgumentError, "spacing must be an Integer 0..4" unless @spacing.is_a?(Integer) && (0..4).cover?(@spacing)
      @orientation = orientation.to_sym
      raise ArgumentError, "orientation must be :horizontal or :vertical" unless [:horizontal, :vertical].include?(@orientation)
      super(**attrs)
    end

    def view_template(&block)
      @first_item_emitted = false
      div(**attrs) do
        yield_content(&block)
        render_hidden_inputs
      end
    end

    # Called by ToggleGroupItem during rendering — items use this to fetch
    # group context (avoids global state / view-context hackery).
    def item_context
      {
        type: @type,
        variant: @variant,
        size: @size,
        disabled: @disabled,
        selected_values: selected_values,
        roving_first: !@first_item_emitted,
        spacing: @spacing,
        orientation: @orientation
      }
    end

    def mark_first_item_emitted!
      @first_item_emitted = true
    end

    private

    def yield_content(&block)
      yield(self)
    end

    def selected_values
      case @type
      when :single
        @value.nil? ? [] : [@value.to_s]
      when :multiple
        Array(@value).map(&:to_s)
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
      base_class = if @orientation == :vertical
        "flex w-fit flex-col items-stretch rounded-md"
      else
        "flex w-fit items-center rounded-md"
      end

      gap_class = case @spacing
      when 0 then nil
      when 1 then "gap-1"
      when 2 then "gap-2"
      when 3 then "gap-3"
      when 4 then "gap-4"
      end

      shadow_class = (@spacing == 0 && @variant == :outline) ? "shadow-xs" : nil

      classes = [base_class, gap_class, shadow_class].compact.join(" ")

      {
        role: (@type == :single) ? "radiogroup" : "group",
        data: {
          controller: "ruby-ui--toggle-group",
          "ruby-ui--toggle-group-type-value": @type.to_s,
          "ruby-ui--toggle-group-name-value": @name.to_s,
          orientation: @orientation.to_s,
          spacing: @spacing.to_s
        },
        class: classes
      }
    end

    public

    # Phlex Kit invocation pattern: items call this via the block argument
    def ToggleGroupItem(**kwargs, &block)
      ctx = item_context
      mark_first_item_emitted!
      render RubyUI::ToggleGroupItem.new(group_context: ctx, **kwargs), &block
    end
  end
end
