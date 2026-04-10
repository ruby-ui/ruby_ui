# frozen_string_literal: true

module RubyUI
  class Clipboard
    include ComponentBase

    def initialize(options: {}, success: "Copied!", error: "Copy Failed!", **attrs)
      @options = options
      @success = success
      @error = error
      super(**attrs)
    end

    def success_message
      @success
    end

    def error_message
      @error
    end

    private

    def default_attrs
      {
        data: {
          controller: "ruby-ui--clipboard",
          action: "click@window->ruby-ui--clipboard#onClickOutside",
          ruby_ui__clipboard_success_value: @success,
          ruby_ui__clipboard_error_value: @error,
          ruby_ui__clipboard_options_value: @options.to_json
        }
      }
    end
  end
end
