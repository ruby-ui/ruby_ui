# frozen_string_literal: true

class Shared::Logo < ApplicationComponent
    def template
        a(href: helpers.root_path, class: 'mr-6 flex items-center space-x-2') do
            render Typography::H4.new {
                "PhlexUI"
            }
        end
    end
end
