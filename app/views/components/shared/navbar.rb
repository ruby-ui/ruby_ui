# frozen_string_literal: true

class Shared::Navbar < ApplicationComponent
  def template
    header(class: 'supports-backdrop-blur:bg-background/60 sticky top-0 z-50 w-full border-b bg-background/95 backdrop-blur') do
      div(class: 'container flex h-14 items-center') do
        div(class: 'mr-4 flex') do
          a(href: helpers.root_path, class: 'mr-6 flex items-center space-x-2') do
            render Typography::H4.new {
              "Phlex Component Library"
            }
          end

          render Link.new(href: helpers.root_path, variant: 'ghost')  do
            "Components"
          end
        end
      end
    end
  end
end
