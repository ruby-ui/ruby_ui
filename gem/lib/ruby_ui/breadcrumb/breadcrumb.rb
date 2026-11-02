# frozen_string_literal: true

module RubyUI
  class Breadcrumb < Base
    def view_template(&)
      nav(**attrs, &)
    end

    private

    def default_attrs
      {
        aria: {label: "breadcrumb"},
        data: {slot: "breadcrumb"}
      }
    end
  end
end
