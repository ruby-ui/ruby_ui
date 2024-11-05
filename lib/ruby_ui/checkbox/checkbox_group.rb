# frozen_string_literal: true

module RubyUI
  class CheckboxGroup < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        role: "group",
        data: {
          controller: "rbui--checkbox-group"
        }
      }
    end
  end
end
