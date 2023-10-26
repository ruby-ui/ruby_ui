# frozen_string_literal: true

class Shared::Logo < ApplicationComponent
    def template
        a(href: helpers.root_path, class: 'mr-6 flex items-center space-x-2') do
            render Typography::H4.new(class: 'flex items-center') {
                plain "PhlexUI"
                render Badge.new(variant: :amber, size: :sm, class: 'ml-2') { "Pre Release" }
            }
        end
    end
end
