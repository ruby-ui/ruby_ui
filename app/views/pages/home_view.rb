# frozen_string_literal: true

class Pages::HomeView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto py-10 space-y-8") do
      render Typography::H1.new { "Typography" }
      render Docs::Component.new(title: "h1", description: "This is an h1 title") do
        render Typography::H1.new { "This is an H1 title" }
      end
      render Docs::Component.new(title: "h2", description: "This is an h2 title") do
        render Typography::H2.new { "This is an H2 title" }
      end
      render Docs::Component.new(title: "h3", description: "This is an h3 title") do
        render Typography::H3.new { "This is an H3 title" }
      end
      render Docs::Component.new(title: "h4", description: "This is an h4 title") do
        render Typography::H4.new { "This is an H4 title" }
      end
      render Docs::Component.new(title: "p", description: "This is an p title") do
        render Typography::P.new { "This is an P tag" }
      end
      render Docs::Component.new(title: "List", description: "This is a list") do
        render Typography::List.new(items: [
          'Phlex is fast',
          'Phlex is easy to use',
          'Phlex is awesome',
        ])
      end
      render Docs::Component.new(title: "Inline Code", description: "This is an inline code block") do
        render Typography::InlineCode.new { "This is an inline code block" }
      end
      render Docs::Component.new(title: "Lead") do
        render Typography::Lead.new { "A modal dialog that interrupts the user with important content and expects
      a response." }
      end
      render Docs::Component.new(title: "Large") do
        render Typography::Large.new { "Are you sure absolutely sure?" }
      end
    end
  end
end
