# frozen_string_literal: true

module PhlexUi
  class AlertPreview < Lookbook::Preview
    # Default Alert
    # ---------------
    # @param variant [Symbol] select { choices: [nil, warning, success, destructive] }
    def variants(variant: nil)
      render(TestView.new) do
        Alert(variant:) do
          AlertTitle { "Pro tip" }
          AlertDescription { "With PhlexUI you'll ship faster." }
        end
      end
    end
  end
end
