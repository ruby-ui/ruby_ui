# frozen_string_literal: true

class Views::Docs::Avatar < Views::Base
  def view_template
    component = "Avatar"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Avatar", description: "An image element with a fallback for representing the user.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Image & fallback", description: "The fallback shows while the image loads, and stays if it fails.", context: self) do
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

      render Docs::VisualCodeExample.new(title: "Sizes", description: "sm, default and lg match shadcn; xs and xl are RubyUI extras. :md still works as an alias of :default.", context: self) do
        <<~RUBY
          div(class: "flex items-center gap-4") do
            [:xs, :sm, :default, :lg, :xl].each do |size|
              Avatar(size: size) do
                AvatarImage(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
                AvatarFallback { "JD" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Sizes (only fallback)", context: self) do
        <<~RUBY
          div(class: "flex items-center gap-4") do
            [:xs, :sm, :default, :lg, :xl].each do |size|
              Avatar(size: size) do
                AvatarFallback { "JD" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Badge", description: "AvatarBadge sits on the bottom-right corner, e.g. an online status.", context: self) do
        <<~RUBY
          Avatar do
            AvatarImage(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
            AvatarFallback { "JD" }
            AvatarBadge(class: "bg-green-600 dark:bg-green-800")
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Group", description: "AvatarGroup overlaps the avatars; AvatarGroupCount shows how many are left.", context: self) do
        <<~RUBY
          AvatarGroup do
            Avatar do
              AvatarImage(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
              AvatarFallback { "JD" }
            end
            Avatar do
              AvatarFallback { "CN" }
            end
            Avatar do
              AvatarFallback { "RU" }
            end
            AvatarGroupCount { "+3" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Fallback delay", description: "delay: (ms) waits before showing the fallback, so a fast image doesn't flash the initials first. The avatar dispatches ruby-ui--avatar:status with detail.status (loading, loaded or error) on every change. The delay needs JavaScript: without it, a delayed fallback stays hidden.", context: self) do
        <<~RUBY
          Avatar do
            AvatarImage(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
            AvatarFallback(delay: 600) { "JD" }
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
