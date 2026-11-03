# frozen_string_literal: true

module RubyUI
  class EmptyTitle < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "empty-title"},
        class: "font-heading text-lg font-medium tracking-tight"
      }
    end
  end
end
