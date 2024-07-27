# frozen_string_literal: true

module PhlexUi
  class TooltipPreview < Lookbook::Preview
    # Default TooltipPreview
    # ---------------
    def default
      render(TestView.new) do
        Tooltip do
          TooltipTrigger do
            Button(variant: :outline, icon: true) do
              plain(ActionController::Base.helpers.lucide_icon("bookmark", class: "w-4 h-4"))
            end
          end

          TooltipContent { plain("Add to library") }
        end
      end
    end
  end
end
