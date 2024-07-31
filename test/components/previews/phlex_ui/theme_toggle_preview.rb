# frozen_string_literal: true

module PhlexUi
  class ThemeTogglePreview < Lookbook::Preview
    def default
      render(TestView.new) do
        ThemeToggle do |toggle|
          toggle.light_mode do
            Button(variant: :ghost, icon: true) do
              plain(helpers.lucide_icon("sun", class: "w-4 h-4"))
            end
          end

          toggle.dark_mode do
            Button(variant: :ghost, icon: true) do
              plain(helpers.lucide_icon("moon", class: "w-4 h-4"))
            end
          end
        end
      end
    end
  end
end
