# frozen_string_literal: true

module Components
  module Shared
    class Footer < Components::Base
      def view_template
        footer(class: "py-6 bg-background") do
          div(class: "container flex flex-col items-center justify-center gap-4 md:h-12 md:flex-row") do
            p(class: "text-balance text-center text-sm leading-loose text-foreground") do
              plain "Heavily inspired by "
              a(
                href: "https://ui.shadcn.com",
                target: "_blank",
                rel: "noreferrer",
                class: "font-medium underline underline-offset-4"
              ) { "shadcn" }
              plain ". The source code is available on "
              a(
                href: "https://github.com/ruby-ui/ruby_ui",
                target: "_blank",
                rel: "noreferrer",
                class: "font-medium underline underline-offset-4"
              ) { "GitHub" }
              plain "."
            end
          end
        end
      end
    end
  end
end
