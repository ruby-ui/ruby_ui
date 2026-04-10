# frozen_string_literal: true

module RubyUI
  class DropdownMenu
    include ComponentBase

    def initialize(options: {}, **attrs)
      @options = options
      super(**attrs)
    end

    private

    def default_attrs
      {
        class: [
          "z-50",
          "group/dropdown-menu",
          (strategy == "absolute") ? "is-absolute" : "is-fixed"
        ],
        data: {
          controller: "ruby-ui--dropdown-menu",
          action: "click@window->ruby-ui--dropdown-menu#onClickOutside",
          ruby_ui__dropdown_menu_options_value: @options.to_json
        }
      }
    end

    def strategy
      @_strategy ||= @options[:strategy] || "absolute"
    end
  end
end
