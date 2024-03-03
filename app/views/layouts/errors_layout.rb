# frozen_string_literal: true

class ErrorsLayout < ApplicationView
  include Phlex::Rails::Layout

  def template(&block)
    doctype

    html do
      render Shared::Head.new

      body do
        main(class: "relative flex flex-col items-center justify-center gap-y-6 h-screen w-screen overflow-y-scroll") do
          render Shared::GridPattern.new
          render PhlexUI::ThemeToggle.new(class: "hidden") # In order for dark mode to work, we need to render the theme toggle somewhere in the DOM
          render Shared::Logo.new
          div(class: "container w-full max-w-md", &block)
        end
        render Shared::Flashes.new(notice: helpers.flash[:notice], alert: helpers.flash[:alert])
      end
    end
  end
end
