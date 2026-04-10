# frozen_string_literal: true

module RubyUI
  class InlineLink < Base
    def initialize(href:, **attrs)
      @href = href
      super(**attrs)
    end

    def view_template(&)
      a(**attrs, &)
    end

    private

    def default_attrs
      {href: @href, class: "text-primary font-medium hover:underline underline-offset-4 cursor-pointer"}
    end
  end
end
