# frozen_string_literal: true

module RBUI
  class CheckboxPreview < Lookbook::Preview
    # Default Checkbox
    # ---------------
    def default
      render(TestView.new) do
        Checkbox(id: "terms")
      end
    end
  end
end
