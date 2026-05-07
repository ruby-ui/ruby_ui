# frozen_string_literal: true

module Components
  module Shared
    class Sidebar < Components::Base
      def view_template
        aside(class: "fixed top-14 z-30 -ml-2 hidden h-[calc(100vh-3.5rem)] w-full shrink-0 md:sticky md:block") do
          div(class: "relative overflow-hidden h-full py-6 pl-8 pr-6 lg:py-8") do
            # Updated Scroll wrapper using CSS to hide scrollbar
            div(class: "h-full w-full rounded-[inherit] overflow-y-auto [&::-webkit-scrollbar]:hidden [-ms-overflow-style:none] [scrollbar-width:none] pb-10", data_controller: "sidebar-menu") do
              render Shared::Menu.new
            end
          end
        end
      end
    end
  end
end
