# frozen_string_literal: true

class Views::Docs::Card < Views::Base
  def view_template
    component = "Card"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Card", description: "Displays a card with header, content, and footer.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Card with image", context: self) do
        <<~RUBY
          Card(class: 'w-96') do
            CardHeader do
              CardTitle { 'You might like "RubyUI"' }
              CardDescription { "@joeldrapper" }
            end
            CardContent do
              AspectRatio(aspect_ratio: "16/9", class: "rounded-md overflow-hidden border") do
                img(
                  alt: "Placeholder",
                  loading: "lazy",
                  src: image_url('pattern.jpg')
                )
              end
            end
            CardFooter(class: 'flex justify-end gap-x-2') do
              Button(variant: :outline) { "See more" }
              Button(variant: :primary) { "Buy now" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Card with full-width image", context: self) do
        <<~RUBY
          Card(class: 'w-96 overflow-hidden') do
            AspectRatio(aspect_ratio: "16/9", class: "border-b") do
              img(
                alt: "Placeholder",
                loading: "lazy",
                src: image_url('pattern.jpg')
              )
            end
            CardHeader do
              CardTitle { 'Introducing RubyUI' }
              CardDescription { "Kickstart your project today!" }
            end
            CardFooter(class: 'flex justify-end') do
              Button(variant: :outline) { "Get started" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Account balance", context: self) do
        <<~RUBY
          Card(class: 'w-96 overflow-hidden') do
            CardHeader do
              div(class: 'w-10 h-10 rounded-xl flex items-center justify-center bg-violet-100 text-violet-700 -rotate-6') do
                cash_icon
              end
            end
            CardContent(class: 'space-y-1') do
              CardDescription(class: 'font-medium') { "Current Balance" }
              h5(class: 'font-semibold text-4xl') { '$2,602' }
            end
            CardFooter do
              Text(size: "2", class: "text-muted-foreground") { "**** 4620" }
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end

  def arrow_icon(classes: nil)
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 0 20 20",
      fill: "currentColor",
      class: ["w-4 h-4", classes]
    ) do |s|
      s.path(
        fill_rule: "evenodd",
        d:
          "M3 10a.75.75 0 01.75-.75h10.638L10.23 5.29a.75.75 0 111.04-1.08l5.5 5.25a.75.75 0 010 1.08l-5.5 5.25a.75.75 0 11-1.04-1.08l4.158-3.96H3.75A.75.75 0 013 10z",
        clip_rule: "evenodd"
      )
    end
  end

  def cash_icon(classes: nil)
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      class: ["w-6 h-6", classes]
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d:
          "M2.25 18.75a60.07 60.07 0 0115.797 2.101c.727.198 1.453-.342 1.453-1.096V18.75M3.75 4.5v.75A.75.75 0 013 6h-.75m0 0v-.375c0-.621.504-1.125 1.125-1.125H20.25M2.25 6v9m18-10.5v.75c0 .414.336.75.75.75h.75m-1.5-1.5h.375c.621 0 1.125.504 1.125 1.125v9.75c0 .621-.504 1.125-1.125 1.125h-.375m1.5-1.5H21a.75.75 0 00-.75.75v.75m0 0H3.75m0 0h-.375a1.125 1.125 0 01-1.125-1.125V15m1.5 1.5v-.75A.75.75 0 003 15h-.75M15 10.5a3 3 0 11-6 0 3 3 0 016 0zm3 0h.008v.008H18V10.5zm-12 0h.008v.008H6V10.5z"
      )
    end
  end
end
