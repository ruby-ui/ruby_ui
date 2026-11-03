# frozen_string_literal: true

module RubyUI
  class InputOtp < Base
    CONTAINER_CLASS = "relative flex items-center gap-2 has-disabled:opacity-50"

    def initialize(length:, pattern: nil, container_class: nil, **attrs)
      @length = length
      @char_class = pattern || "[0-9]"
      @container_class = container_class
      super(**attrs)
    end

    def view_template(&block)
      div(
        translate: "no",
        data: {
          controller: "ruby-ui--input-otp",
          ruby_ui__input_otp_length_value: @length,
          ruby_ui__input_otp_char_class_value: @char_class
        },
        class: TAILWIND_MERGER.merge([CONTAINER_CLASS, @container_class].compact.join(" "))
      ) do
        block&.call
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
        spellcheck: "false",
        data: {
          slot: "input-otp",
          ruby_ui__input_otp_target: "input",
          action: "input->ruby-ui--input-otp#onInput keydown->ruby-ui--input-otp#onKeydown paste->ruby-ui--input-otp#onPaste focus->ruby-ui--input-otp#onFocus blur->ruby-ui--input-otp#onBlur"
        },
        class: "absolute inset-0 h-full w-full cursor-text appearance-none border-0 bg-transparent p-0 text-transparent caret-transparent shadow-none outline-none selection:bg-transparent focus:outline-none focus:ring-0 focus-visible:outline-none focus-visible:ring-0 disabled:cursor-not-allowed"
      }
    end
  end
end
