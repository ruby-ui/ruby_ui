# frozen_string_literal: true

class Docs::InstallationView < ApplicationView
  include Phlex::DeferredRender

  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Installation", description: "How to install dependencies and structure your app.")

      render PhlexUI::Typography::H2.new(class: 'text-xl !font-semibold pb-4 border-b') { "Select a Framework" }
      div(class: "grid grid-cols-1 sm:grid-cols-2 gap-4") do
        framework_card(title: "Rails", link: "#") { rails_logo } 
      end
    end
  end

  def framework_card(title:, link:, &block)
    a(href: link) do
      render PhlexUI::Card.new(class: "flex flex-col items-center gap-y-4 p-6 py-10 hover:bg-accent hover:text-accent-foreground transition-colors duration-200 ease-in-out") do
        block.call
        p(class: "text-lg font-medium") { title }
      end
    end
  end

  def rails_logo
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      id: "Layer_1",
      viewbox: "0 0 395.9 139.2",
      fill: "currentColor",
      class: 'w-20'
    ) do |s|
      s.path(
        class: "st0",
        d:
          "M344.6 121.1v18.1h32.7c6.7 0 18.2-4.9 18.6-18.6v-7c0-11.7-9.6-18.6-18.6-18.6H361v-8.4h32.3V68.4h-31c-8 0-18.7 6.6-18.7 18.9v6.3c0 12.3 10.6 18.6 18.7 18.6 22.5.1-5.4 0 15.4 0v8.8m-208.3-4.3s17.5-1.5 17.5-24.1-21.2-24.7-21.2-24.7h-38.2v71.3h19.2V122l16.6 17.2h28.4l-22.3-22.5zm-7.4-14.6h-15.3V85.8h15.4s4.3 1.6 4.3 8.1-4.4 8.2-4.4 8.2zm72.3-33.7h-19.5c-13.9 0-18.6 12.6-18.6 18.6v52.2h19.5v-12.5H234v12.5h18.9V87c0-15.2-13.8-18.6-18.6-18.6zm-.3 38.1h-18.4V89.2s0-3.9 6.1-3.9h6.7c5.4 0 5.5 3.9 5.5 3.9v17.3h.1zM261.8 68.4h20.3v70.8h-20.3zM310.6 120.9V68.4h-20.2v70.8h47.5v-18.3z"
      )
      s.path(
        class: "st0",
        d:
          "M7 139.2h79s-15.1-68.9 34.9-96.8c10.9-5.3 45.6-25.1 102.4 16.9 1.8-1.5 3.5-2.7 3.5-2.7s-52-51.9-109.9-46.1C87.8 13.1 52 39.6 31 74.6S7 139.2 7 139.2z"
      )
      s.path(
        class: "st0",
        d:
          "M7 139.2h79s-15.1-68.9 34.9-96.8c10.9-5.3 45.6-25.1 102.4 16.9 1.8-1.5 3.5-2.7 3.5-2.7s-52-51.9-109.9-46.1C87.8 13.1 52 39.6 31 74.6S7 139.2 7 139.2z"
      )
      s.path(
        class: "st0",
        d:
          "M7 139.2h79s-15.1-68.9 34.9-96.8c10.9-5.3 45.6-25.1 102.4 16.9 1.8-1.5 3.5-2.7 3.5-2.7s-52-51.9-109.9-46.1c-29.2 2.6-65 29.1-86 64.1S7 139.2 7 139.2zM171.6 16.1l.4-6.7c-.9-.5-3.4-1.7-9.7-3.5l-.4 6.6c3.3 1.1 6.5 2.3 9.7 3.6z"
      )
      s.path(
        class: "st0",
        d:
          "M162.1 37.3l-.4 6.3c3.3.1 6.6.5 9.9 1.2l.4-6.2c-3.4-.7-6.7-1.1-9.9-1.3zm-37-31.2h1l-2-6.1c-3.1 0-6.3.2-9.6.6l1.9 5.9c2.9-.3 5.8-.4 8.7-.4zm4.8 36.8l2.3 6.9c2.9-1.4 5.8-2.6 8.7-3.5l-2.2-6.6c-3.4 1-6.3 2.1-8.8 3.2zM84.5 16.6L80 9.7c-2.5 1.3-5.1 2.7-7.8 4.3l4.6 7c2.6-1.6 5.1-3.1 7.7-4.4zm20.5 45l4.8 7.2c1.7-2.5 3.7-4.8 5.9-7.1l-4.5-6.8c-2.3 2.1-4.4 4.4-6.2 6.7zM90.5 93.8l8.1 6.4c.4-3.9 1.1-7.8 2.1-11.7l-7.2-5.7c-1.3 3.7-2.2 7.4-3 11zM46.7 46.3l-7.1-6.2c-2.6 2.5-5.1 5-7.4 7.5l7.7 6.6c2.1-2.7 4.4-5.4 6.8-7.9zM16.5 91L5 86.8c-1.9 4.3-4 9.3-5 12l11.5 4.2c1.3-3.4 3.4-8.3 5-12zM89 119.2c.2 5.3.7 9.6 1.2 12.6l12 4.3c-.9-3.9-1.8-8.3-2.4-13L89 119.2z"
      )
    end
  end
end
