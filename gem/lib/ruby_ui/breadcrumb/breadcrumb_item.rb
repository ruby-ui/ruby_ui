# frozen_string_literal: true

module RubyUI
  class BreadcrumbItem < Base
    def view_template(&)
      li(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "inline-flex items-center gap-1.5"
      }
    end
  end
end
