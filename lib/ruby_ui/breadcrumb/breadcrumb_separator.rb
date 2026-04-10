# frozen_string_literal: true

module RubyUI
  class BreadcrumbSeparator
    include ComponentBase

    private

    def default_attrs
      {
        aria: {hidden: true},
        class: "[&>svg]:w-3.5 [&>svg]:h-3.5",
        role: "presentation"
      }
    end
  end
end
