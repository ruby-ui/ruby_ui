# frozen_string_literal: true

module Components
  module Shared
    class Logo < Components::Base
      def view_template
        a(href: root_url, class: "mr-6 flex items-center space-x-2") do
          Heading(level: 4, class: "flex items-center") {
            img(src: image_url("logo.svg"), class: "h-4 block dark:hidden")
            img(src: image_url("logo_dark.svg"), class: "h-4 hidden dark:block")
            span(class: "sr-only") { "RubyUI" }
            Badge(variant: :amber, size: :sm, class: "ml-2 whitespace-nowrap") { "1.0" }
          }
        end
      end
    end
  end
end
