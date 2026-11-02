# frozen_string_literal: true

module RubyUI
  class BreadcrumbList < Base
    def view_template(&)
      ol(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "breadcrumb-list"},
        class: "flex flex-wrap items-center gap-1.5 wrap-break-word text-sm text-muted-foreground sm:gap-2.5"
      }
    end
  end
end
