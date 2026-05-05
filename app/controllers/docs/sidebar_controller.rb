# frozen_string_literal: true

class Docs::SidebarController < ApplicationController
  layout -> { Views::Layouts::ExamplesLayout }

  def example
    sidebar_state = cookies.fetch(:sidebar_state, "true") == "true"

    render Views::Docs::Sidebar::Example.new(sidebar_state:)
  end

  def inset_example
    sidebar_state = cookies.fetch(:sidebar_state, "true") == "true"

    render Views::Docs::Sidebar::InsetExample.new(sidebar_state:)
  end
end
