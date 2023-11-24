# frozen_string_literal: true

class Shared::Logo < ApplicationComponent
    def template
        a(href: helpers.root_url, class: 'mr-6 flex items-center space-x-2') do
            render PhlexUI::Typography::H4.new(class: 'flex items-center') {
                img(src: helpers.image_url('logo.svg'), class: 'h-4 dark:hidden')
                img(src: helpers.image_url('logo_dark.svg'), style: "display: none;", class: 'h-4 dark:!block')
                span(style: "position: absolute;
                        width: 1px;
                        height: 1px;
                        padding: 0;
                        margin: -1px;
                        overflow: hidden;
                        clip: rect(0,0,0,0);
                        white-space: nowrap;
                        border-width: 0;" # Use styles to simulate 'sr-only' class (Needed for emails)
                ) { "PhlexUI" }
                render PhlexUI::Badge.new(variant: :amber, size: :sm, class: 'ml-2 !block', style: "display: none;",) { "Pre Release" } # Use styles to simulate 'hidden' class (Needed for emails)
            }
        end
    end
end
