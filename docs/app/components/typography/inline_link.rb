module Components
  module Typography
    class InlineLink < Components::Base
      def initialize(href:, **attrs)
        @href = href
        @attrs = attrs
      end

      def view_template(&)
        a(href: @href, **@attrs, class: "text-primary font-medium hover:underline underline-offset-4", &)
      end
    end
  end
end
