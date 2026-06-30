# frozen_string_literal: true

module RubyUI
  class InputOtp < Base
    def initialize(length:, pattern: nil, **attrs)
      @length = length
      @char_class = pattern || "[0-9]"
      super(**attrs)
    end

    def view_template(&block)
      div(
        data: {
          controller: "ruby-ui--input-otp",
          ruby_ui__input_otp_length_value: @length,
          ruby_ui__input_otp_char_class_value: @char_class
        },
        class: "relative inline-flex items-center has-disabled:opacity-50"
      ) do
        div(class: "flex items-center gap-2", &block)
        input(**attrs)
      end
    end

    private

    def default_attrs
      {
        type: "text",
        inputmode: (@char_class == "[0-9]") ? "numeric" : "text",
        pattern: "^(?:#{@char_class}){#{@length}}$",
        maxlength: @length,
        autocomplete: "one-time-code",
        data: {
          ruby_ui__input_otp_target: "input",
          action: "input->ruby-ui--input-otp#onInput keydown->ruby-ui--input-otp#onKeydown paste->ruby-ui--input-otp#onPaste focus->ruby-ui--input-otp#onFocus blur->ruby-ui--input-otp#onBlur"
        },
        class: "absolute inset-0 h-full w-full cursor-text border-0 bg-transparent p-0 text-transparent caret-transparent outline-none selection:bg-transparent disabled:cursor-not-allowed"
      }
    end
  end
end
