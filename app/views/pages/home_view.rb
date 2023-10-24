# frozen_string_literal: true

class Pages::HomeView < ApplicationView
  def template
    div do
      render Typography::H1.new { "Welcome to PhlexUI" }
      render Typography::P.new { "List all phlex components" }
    end
  end
end
