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
      **attrs
    )
      @type = type.to_sym
      raise ArgumentError, "type must be :single or :multiple" unless [:single, :multiple].include?(@type)
      @name = name
      @value = value
      @variant = variant.to_sym
      @size = size.to_sym
      @disabled = disabled
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
        roving_first: !@first_item_emitted
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
      {
        role: (@type == :single) ? "radiogroup" : "group",
        data: {
          controller: "ruby-ui--toggle-group",
          "ruby-ui--toggle-group-type-value": @type.to_s,
          "ruby-ui--toggle-group-name-value": @name.to_s
        },
        class: "inline-flex items-center justify-center gap-1"
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
