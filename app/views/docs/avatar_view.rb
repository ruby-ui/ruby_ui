# frozen_string_literal: true

class Docs::AvatarView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-8") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Avatar" }
        render Typography::P.new { "An image element with a fallback for representing the user." }
      end

      render Docs::Component.new do
        render Avatar.new do
          render AvatarImage.new(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
          render AvatarFallback.new { "JD" }
        end
      end
    end
  end
end
