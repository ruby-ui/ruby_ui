# frozen_string_literal: true

module RubyUI
  class SelectValue < Base
    attr_reader :placeholder

    def initialize(placeholder: nil, **attrs)
      @placeholder = placeholder
      super(**attrs)
    end

    def view_template(&)
      span(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          ruby_ui__select_target: "value"
        },
        class: "truncate pointer-events-none"
      }
    end
  end
end
