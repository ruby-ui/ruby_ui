# frozen_string_literal: true

class Views::Docs::Tabs < Views::Base
  Repo = Struct.new(:github_url, :name, :stars, :version, keyword_init: true)

  def view_template
    component = "Tabs"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Tabs", description: "A set of layered sections of content—known as tab panels—that are displayed one at a time.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          Tabs(default_value: "account", class: 'w-96') do
            TabsList do
              TabsTrigger(value: "account") { "Account" }
              TabsTrigger(value: "password") { "Password" }
            end
            TabsContent(value: "account") do
              div(class: "rounded-lg border p-6 space-y-4 bg-background text-foreground") do
                div(class: "space-y-0") do
                  Text(size: "4", weight: "semibold") { "Account" }
                  Text(size: "2", class: "text-muted-foreground") { "Update your account details." }
                end
              end
            end
            TabsContent(value: "password") do
              div(class: "rounded-lg border p-6 space-y-4 bg-background text-foreground") do
                div do
                  Text(size: "4", weight: "semibold") { "Password" }
                  Text(size: "2", class: "text-muted-foreground") { "Change your password here. After saving, you'll be logged out." }
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", context: self) do
        <<~RUBY
          Tabs(default_value: "account", class: 'w-96') do
            TabsList do
              TabsTrigger(disabled: true, value: "account") { "Account" }
              TabsTrigger(disabled: true, value: "password") { "Password" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Aria Disabled", context: self) do
        <<~RUBY
          Tabs(default_value: "account", class: 'w-96') do
            TabsList do
              TabsTrigger(aria: {disabled: "true"}, value: "account") { "Account" }
              TabsTrigger(aria: {disabled: "true"}, value: "password") { "Password" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Full width", context: self) do
        <<~RUBY
          Tabs(default_value: "overview", class: 'w-96') do
            TabsList(class: 'w-full grid grid-cols-2') do
              TabsTrigger(value: "overview") do
                book_icon
                span(class: 'ml-2') { "Overview" }
              end
              TabsTrigger(value: "repositories") do
                repo_icon
                span(class: 'ml-2') { "Repositories" }
              end
            end
            TabsContent(value: "overview") do
              div(class: "rounded-lg border p-6 bg-background text-foreground flex justify-between space-x-4") do
                Avatar do
                  AvatarImage(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
                  AvatarFallback { "JD" }
                end
                div(class: "space-y-4") do
                  div do
                    Text(size: "4", weight: "semibold") { "Joel Drapper" }
                    Text(size: "2", class: "text-muted-foreground") { "Creator of Phlex Components. Ruby on Rails developer." }
                  end
                  Link(href: "https://github.com/joeldrapper", variant: :outline, size: :sm) do
                    github_icon
                    span(class: 'ml-2') { "View profile" }
                  end
                end
              end
            end
            TabsContent(value: "repositories") do
              div(class: "rounded-lg border p-6 space-y-4 bg-background text-foreground") do
                repo = repositories.first
                Link(href: repo.github_url, variant: :link, class: "pl-0") { repo.name }
                Badge { repo.version }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Change default value", context: self) do
        <<~RUBY
          Tabs(default: "password", class: 'w-96') do
            TabsList do
              TabsTrigger(value: "account") { "Account" }
              TabsTrigger(value: "password") { "Password" }
            end
            TabsContent(value: "account") do
              div(class: "rounded-lg border p-6 space-y-4 bg-background text-foreground") do
                div(class: "space-y-0") do
                  Text(size: "4", weight: "semibold") { "Account" }
                  Text(size: "2", class: "text-muted-foreground") { "Update your account details." }
                end
              end
            end
            TabsContent(value: "password") do
              div(class: "rounded-lg border p-6 space-y-4 bg-background text-foreground") do
                div do
                  Text(size: "4", weight: "semibold") { "Password" }
                  Text(size: "2", class: "text-muted-foreground") { "Change your password here. After saving, you'll be logged out." }
                end
              end
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end

  private

  def book_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "2",
      stroke: "currentColor",
      class: "w-4 h-4 text-muted-foreground"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d:
          "M12 6.042A8.967 8.967 0 006 3.75c-1.052 0-2.062.18-3 .512v14.25A8.987 8.987 0 016 18c2.305 0 4.408.867 6 2.292m0-14.25a8.966 8.966 0 016-2.292c1.052 0 2.062.18 3 .512v14.25A8.987 8.987 0 0018 18a8.967 8.967 0 00-6 2.292m0-14.25v14.25"
      )
    end
  end

  def repo_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "2",
      stroke: "currentColor",
      class: "w-4 h-4 text-muted-foreground"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d:
          "M16.5 3.75V16.5L12 14.25 7.5 16.5V3.75m9 0H18A2.25 2.25 0 0120.25 6v12A2.25 2.25 0 0118 20.25H6A2.25 2.25 0 013.75 18V6A2.25 2.25 0 016 3.75h1.5m9 0h-9"
      )
    end
  end

  def github_icon
    svg(viewbox: "0 0 438.549 438.549", class: "h-4 w-4") do |s|
      s.path(
        fill: "currentColor",
        d:
          "M409.132 114.573c-19.608-33.596-46.205-60.194-79.798-79.8-33.598-19.607-70.277-29.408-110.063-29.408-39.781 0-76.472 9.804-110.063 29.408-33.596 19.605-60.192 46.204-79.8 79.8C9.803 148.168 0 184.854 0 224.63c0 47.78 13.94 90.745 41.827 128.906 27.884 38.164 63.906 64.572 108.063 79.227 5.14.954 8.945.283 11.419-1.996 2.475-2.282 3.711-5.14 3.711-8.562 0-.571-.049-5.708-.144-15.417a2549.81 2549.81 0 01-.144-25.406l-6.567 1.136c-4.187.767-9.469 1.092-15.846 1-6.374-.089-12.991-.757-19.842-1.999-6.854-1.231-13.229-4.086-19.13-8.559-5.898-4.473-10.085-10.328-12.56-17.556l-2.855-6.57c-1.903-4.374-4.899-9.233-8.992-14.559-4.093-5.331-8.232-8.945-12.419-10.848l-1.999-1.431c-1.332-.951-2.568-2.098-3.711-3.429-1.142-1.331-1.997-2.663-2.568-3.997-.572-1.335-.098-2.43 1.427-3.289 1.525-.859 4.281-1.276 8.28-1.276l5.708.853c3.807.763 8.516 3.042 14.133 6.851 5.614 3.806 10.229 8.754 13.846 14.842 4.38 7.806 9.657 13.754 15.846 17.847 6.184 4.093 12.419 6.136 18.699 6.136 6.28 0 11.704-.476 16.274-1.423 4.565-.952 8.848-2.383 12.847-4.285 1.713-12.758 6.377-22.559 13.988-29.41-10.848-1.14-20.601-2.857-29.264-5.14-8.658-2.286-17.605-5.996-26.835-11.14-9.235-5.137-16.896-11.516-22.985-19.126-6.09-7.614-11.088-17.61-14.987-29.979-3.901-12.374-5.852-26.648-5.852-42.826 0-23.035 7.52-42.637 22.557-58.817-7.044-17.318-6.379-36.732 1.997-58.24 5.52-1.715 13.706-.428 24.554 3.853 10.85 4.283 18.794 7.952 23.84 10.994 5.046 3.041 9.089 5.618 12.135 7.708 17.705-4.947 35.976-7.421 54.818-7.421s37.117 2.474 54.823 7.421l10.849-6.849c7.419-4.57 16.18-8.758 26.262-12.565 10.088-3.805 17.802-4.853 23.134-3.138 8.562 21.509 9.325 40.922 2.279 58.24 15.036 16.18 22.559 35.787 22.559 58.817 0 16.178-1.958 30.497-5.853 42.966-3.9 12.471-8.941 22.457-15.125 29.979-6.191 7.521-13.901 13.85-23.131 18.986-9.232 5.14-18.182 8.85-26.84 11.136-8.662 2.286-18.415 4.004-29.263 5.146 9.894 8.562 14.842 22.077 14.842 40.539v60.237c0 3.422 1.19 6.279 3.572 8.562 2.379 2.279 6.136 2.95 11.276 1.995 44.163-14.653 80.185-41.062 108.068-79.226 27.88-38.161 41.825-81.126 41.825-128.906-.01-39.771-9.818-76.454-29.414-110.049z"
      )
    end
  end

  def star_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "2",
      stroke: "currentColor",
      class: "w-4 h-4 text-amber-500"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d:
          "M11.48 3.499a.562.562 0 011.04 0l2.125 5.111a.563.563 0 00.475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 00-.182.557l1.285 5.385a.562.562 0 01-.84.61l-4.725-2.885a.563.563 0 00-.586 0L6.982 20.54a.562.562 0 01-.84-.61l1.285-5.386a.562.562 0 00-.182-.557l-4.204-3.602a.563.563 0 01.321-.988l5.518-.442a.563.563 0 00.475-.345L11.48 3.5z"
      )
    end
  end

  def repositories
    [
      Repo.new(github_url: "https://github.com/phlex-ruby/phlex", name: "phlex", stars: 961, version: "v1.8.1"),
      Repo.new(github_url: "https://github.com/joeldrapper/green_dots", name: "green_dots", stars: 40, version: "1.0"),
      Repo.new(github_url: "https://github.com/joeldrapper/literal", name: "literal", stars: 96, version: "v0.1.0")
    ]
  end
end
