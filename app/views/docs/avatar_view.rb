# frozen_string_literal: true

class Docs::AvatarView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: 'Avatar', description: 'An image element with a fallback for representing the user.')

      render PhlexUI::Typography::H2.new { 'Usage' }

      render Docs::VisualCodeExample.new(title: 'Builder with Image', context: self) do
        <<~RUBY
          render PhlexUI::Avatar::Builder.new(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper", initials: "JD")
        RUBY
      end

      render Docs::VisualCodeExample.new(title: 'Builder without Image', context: self) do
        <<~RUBY
          render PhlexUI::Avatar::Builder.new(initials: "JD")
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
            # size: :xs
            render PhlexUI::Avatar.new(size: :xs) do
              render PhlexUI::Avatar::Image.new(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
              render PhlexUI::Avatar::Fallback.new { "JD" }
            end
            # size: :sm
            render PhlexUI::Avatar.new(size: :sm) do
              render PhlexUI::Avatar::Image.new(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
              render PhlexUI::Avatar::Fallback.new { "JD" }
            end
            # size: :md
            render PhlexUI::Avatar.new(size: :md) do
              render PhlexUI::Avatar::Image.new(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
              render PhlexUI::Avatar::Fallback.new { "JD" }
            end
            # size: :lg
            render PhlexUI::Avatar.new(size: :lg) do
              render PhlexUI::Avatar::Image.new(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
              render PhlexUI::Avatar::Fallback.new { "JD" }
            end
            # size: :xl
            render PhlexUI::Avatar.new(size: :xl) do
              render PhlexUI::Avatar::Image.new(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
              render PhlexUI::Avatar::Fallback.new { "JD" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: 'Sizes (only fallback)', context: self) do
        <<~RUBY
          div(class: 'flex items-center space-x-2') do
            # size: :xs
            render PhlexUI::Avatar.new(size: :xs) do
              render PhlexUI::Avatar::Fallback.new { "JD" }
            end
            # size: :sm
            render PhlexUI::Avatar.new(size: :sm) do
              render PhlexUI::Avatar::Fallback.new { "JD" }
            end
            # size: :md
            render PhlexUI::Avatar.new(size: :md) do
              render PhlexUI::Avatar::Fallback.new { "JD" }
            end
            # size: :lg
            render PhlexUI::Avatar.new(size: :lg) do
              render PhlexUI::Avatar::Fallback.new { "JD" }
            end
            # size: :xl
            render PhlexUI::Avatar.new(size: :xl) do
              render PhlexUI::Avatar::Fallback.new { "JD" }
            end
          end
        RUBY
      end

      render Docs::ComponentsTable.new(components)
    end
  end

  private

  def components
    [
      Docs::ComponentStruct.new(name: "PhlexUI::Avatar::Builder", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/avatar/builder.rb", builder: true, built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Avatar", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/avatar.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Avatar::Image", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/avatar/image.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Avatar::Fallback", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/avatar/fallback.rb", built_using: :phlex),
    ]
  end
end
