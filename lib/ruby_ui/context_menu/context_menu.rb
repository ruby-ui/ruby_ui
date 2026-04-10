# frozen_string_literal: true

module RubyUI
  class ContextMenu
    include ComponentBase

    def initialize(options: {}, **attrs)
      @options = options
      @options[:trigger] ||= "manual"
      super(**attrs)
    end

    private

    def default_attrs
      {
        data: {
          controller: "ruby-ui--context-menu",
          ruby_ui__context_menu_options_value: @options.to_json
        }
      }
    end
  end
end
