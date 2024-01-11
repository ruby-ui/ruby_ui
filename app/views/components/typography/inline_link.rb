module Typography
    class InlineLink < ApplicationComponent
        def initialize(href:, **attrs)
            @href = href
            @attrs = attrs
        end

        def template(&block)
            a(href: @href, **@attrs, class: "text-primary font-medium hover:underline underline-offset-4", &block)
        end
    end
end