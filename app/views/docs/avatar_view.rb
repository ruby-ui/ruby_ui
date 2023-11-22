# frozen_string_literal: true

class Docs::AvatarView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      div(class: 'space-y-2') do
        render PhlexUI::Typography::H1.new { "Avatar" }
        render PhlexUI::Typography::P.new { "An image element with a fallback for representing the user." }
      end

      render Docs::VisualCodeExample.new(title: 'Simple with Image', context: self) do
        <<~RUBY
          render PhlexUI::Avatar.new(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper", initials: "JD")
        RUBY
      end

      render Docs::VisualCodeExample.new(title: 'Simple with Initials', context: self) do
        <<~RUBY
          render PhlexUI::Avatar.new(initials: "JD")
        RUBY
      end

      render Docs::VisualCodeExample.new(title: 'Image & fallback', context: self) do
        <<~RUBY
          render PhlexUI::Avatar.new do
            render PhlexUI::Avatar::Image.new(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
            render PhlexUI::Avatar::Fallback.new { "JD" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: 'Only fallback', context: self) do
        <<~RUBY
          render PhlexUI::Avatar.new do
            render PhlexUI::Avatar::Fallback.new { "JD" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: 'Sizes', context: self) do
        <<~RUBY
          div(class: 'flex items-center space-x-2') do
            default_avatar(size: :xs)
            default_avatar(size: :sm)
            default_avatar(size: :md)
            default_avatar(size: :lg)
            default_avatar(size: :xl)
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: 'Sizes (only fallback)', context: self) do
        <<~RUBY
          div(class: 'flex items-center space-x-2') do
            default_avatar(size: :xs, image: false)
            default_avatar(size: :sm, image: false)
            default_avatar(size: :md, image: false)
            default_avatar(size: :lg, image: false)
            default_avatar(size: :xl, image: false)
          end
        RUBY
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end

  def default_avatar(size: :md, image: true)
    render PhlexUI::Avatar.new(size: size) do
      render PhlexUI::Avatar::Image.new(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper") if image
      render PhlexUI::Avatar::Fallback.new { "JD" }
    end
  end
end
