# frozen_string_literal: true

module RBUI
  class CheckboxGroupPreview < Lookbook::Preview
    # Default CheckboxGroup
    # ---------------
    def default
      render(TestView.new) do
        CheckboxGroup(id: "terms")
      end
    end
  end
end
