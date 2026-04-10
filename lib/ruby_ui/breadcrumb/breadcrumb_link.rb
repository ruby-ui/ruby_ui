# frozen_string_literal: true

module RubyUI
  class BreadcrumbLink
    include ComponentBase

    def initialize(href: "#", **attrs)
      @href = href
      super(**attrs)
    end

    private

    def default_attrs
      {
        href: @href,
        class: "transition-colors hover:text-foreground"
      }
    end
  end
end
