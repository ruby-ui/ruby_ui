module Typography
  class InlineLink < ApplicationComponent
    def initialize(href:, **attrs)
      @href = href
      @attrs = attrs
    end

    def template(&)
      a(href: @href, **@attrs, class: "text-primary font-medium hover:underline underline-offset-4", &)
    end
  end
end
