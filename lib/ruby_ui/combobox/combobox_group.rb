# frozen_string_literal: true

module RubyUI
  class ComboboxGroup < Base
    def initialize(heading: nil, **attrs)
      @heading = heading
      super(**attrs)
    end

    def view_template(&block)
      div(**attrs) do
        render_header if @heading
        render_items(&block)
      end
    end

    private

    def render_header
      div(group_heading: @heading, class: "px-2 py-1.5 text-xs font-medium text-muted-foreground") { @heading }
    end

    def render_items(&)
      div(group_items: "", role: "group", &)
    end

    def default_attrs
      {
        class: "overflow-hidden p-1 text-foreground",
        role: "presentation",
        data: {
          value: @heading,
          ruby_ui__combobox_content_target: "group"
        }
      }
    end
  end
end
