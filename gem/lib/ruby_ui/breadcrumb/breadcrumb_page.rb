# frozen_string_literal: true

module RubyUI
  class BreadcrumbPage < Base
    def view_template(&)
      span(**attrs, &)
    end

    private

    def default_attrs
      {
        aria: {disabled: true, current: "page"},
        class: "font-normal text-foreground",
        role: "link"
      }
    end
  end
end
