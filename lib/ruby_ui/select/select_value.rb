# frozen_string_literal: true

module RubyUI
  class SelectValue < Base
    def initialize(placeholder: nil, **attrs)
      @placeholder = placeholder
      super(**attrs)
    end

    def view_template(&block)
      span(**attrs) do
        block ? block.call : @placeholder
      end
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
