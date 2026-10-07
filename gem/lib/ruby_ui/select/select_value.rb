# frozen_string_literal: true

module RubyUI
  class SelectValue < Component
    attr_reader :placeholder

    def initialize(placeholder: nil, **attrs)
      @placeholder = placeholder
      super(**attrs)
    end

    # The block's content, or the placeholder when the block emitted nothing
    # (nil, or ""), as Phlex did — it wrote the placeholder only when the
    # buffer had not grown, so whitespace-only content is content.
    def value
      (content.nil? || content.empty?) ? placeholder : content
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
