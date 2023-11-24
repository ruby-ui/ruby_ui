# frozen_string_literal: true

class Shared::Logo < ApplicationComponent
    def template
        a(href: helpers.root_url, class: 'mr-6 flex items-center space-x-2') do
            render PhlexUI::Typography::H4.new(class: 'flex items-center') {
                img(src: helpers.image_url('logo.svg'), class: 'h-4 block dark:hidden')
                img(src: helpers.image_url('logo_dark.svg'), class: 'h-4 hidden dark:block')
                span(class: 'sr-only') { "PhlexUI" }
                render PhlexUI::Badge.new(variant: :amber, size: :sm, class: 'ml-2') { "Pre Release" }
            }
        end
    end
end
