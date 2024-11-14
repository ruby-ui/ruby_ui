# frozen_string_literal: true

module RubyUI
  class ContextMenu < Base
    def initialize(options: {}, **attrs)
      @options = options
      @options[:trigger] ||= "manual"
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          controller: "ruby-ui--context-menu",
          popover_options_value: @options.to_json
        }
      }
    end
  end
end
