# frozen_string_literal: true

class Views::Docs::Avatar < Views::Base
  def view_template
    component = "Avatar"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Avatar", description: "An image element with a fallback for representing the user.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Image & fallback", context: self) do
        <<~RUBY
          Avatar do
            AvatarImage(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
            AvatarFallback { "JD" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Only fallback", context: self) do
        <<~RUBY
          Avatar do
            AvatarFallback { "JD" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Sizes", context: self) do
        <<~RUBY
          div(class: 'flex items-center space-x-2') do
            # size: :xs
            Avatar(size: :xs) do
              AvatarImage(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
              AvatarFallback { "JD" }
            end
            # size: :sm
            Avatar(size: :sm) do
              AvatarImage(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
              AvatarFallback { "JD" }
            end
            # size: :md
            Avatar(size: :md) do
              AvatarImage(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
              AvatarFallback { "JD" }
            end
            # size: :lg
            Avatar(size: :lg) do
              AvatarImage(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
              AvatarFallback { "JD" }
            end
            # size: :xl
            Avatar(size: :xl) do
              AvatarImage(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
              AvatarFallback { "JD" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Sizes (only fallback)", context: self) do
        @@code = <<~RUBY
          div(class: 'flex items-center space-x-2') do
            # size: :xs
            Avatar(size: :xs) do
              AvatarFallback { "JD" }
            end
            # size: :sm
            Avatar(size: :sm) do
              AvatarFallback { "JD" }
            end
            # size: :md
            Avatar(size: :md) do
              AvatarFallback { "JD" }
            end
            # size: :lg
            Avatar(size: :lg) do
              AvatarFallback { "JD" }
            end
            # size: :xl
            Avatar(size: :xl) do
              AvatarFallback { "JD" }
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
