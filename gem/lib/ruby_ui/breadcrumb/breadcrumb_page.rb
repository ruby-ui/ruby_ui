# frozen_string_literal: true

module RubyUI
  class BreadcrumbPage < Base
    def view_template(&)
      span(**attrs, &)
    end

    private

    # aria values are strings: Phlex renders `true` as a bare attribute
    # (aria-disabled=""), which ARIA treats as undefined.
    def default_attrs
      {
        aria: {disabled: "true", current: "page"},
        data: {slot: "breadcrumb-page"},
        class: "font-normal text-foreground",
        role: "link"
      }
    end
  end
end
