# frozen_string_literal: true

class Pages::HomeView < ApplicationView
  def template
    div(class: "max-w-md mx-auto py-10 space-y-6") do
      render Typography::H1.new { "This is an H1 title" }
      render Typography::H2.new { "This is an H2 title" }
      render Typography::H3.new { "This is an H3 title" }
      render Typography::H4.new { "This is an H4 title" }
      render Typography::P.new { "This is an P tag" }
      render Typography::List.new(items: [
        'This is a list item',
        'This is a list item',
        'This is a list item',
      ])
      render Typography::InlineCode.new { "This is an inline code block" }
    end
  end
end
