# frozen_string_literal: true

class Views::Docs::Components < Views::Base
  include Components::Shared::ComponentsList

  def view_template
    div(class: "mx-auto max-w-[800px] py-10") do
      h1(class: "scroll-m-24 text-3xl font-semibold tracking-tight sm:text-3xl mb-4") { "Components" }
      p(class: "text-lg text-foreground mb-8 text-balance") { "A UI component library, crafted precisely for Ruby devs who want to stay organised and build modern apps, fast." }

      div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-y-4 mb-24 mt-12") do
        components.each do |component|
          a(href: component[:path], class: "text-base text-foreground/80 hover:text-foreground hover:underline transition-colors") do
            component[:name]
          end
        end
      end

      div(class: "rounded-xl border border-muted bg-muted/20 p-6") do
        h3(class: "font-semibold text-lg tracking-tight mb-2") { "Missing a component?" }
        p(class: "text-foreground mb-4") do
          plain "Can't find the component you're looking for? Let us know what you'd like to see next by opening a suggestion on our "
          a(href: "https://github.com/ruby-ui/ruby_ui/issues/new", target: "_blank", class: "font-medium underline underline-offset-4") { "GitHub Issues" }
          plain " page."
        end
      end
    end
  end
end
