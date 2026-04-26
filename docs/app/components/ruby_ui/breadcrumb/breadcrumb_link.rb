# frozen_string_literal: true

module RubyUI
  class BreadcrumbLink < Base
    def initialize(href: "#", **attrs)
      @href = href
      super(**attrs)
    end

    def view_template(&)
      a(href: @href, **attrs, &)
    end

    private

    def default_attrs
      {
        class: "transition-colors hover:text-foreground"
      }
    end
  end
end
