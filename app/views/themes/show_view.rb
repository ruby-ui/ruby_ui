# frozen_string_literal: true

class Themes::ShowView < ApplicationView
  def initialize(theme:)
    @theme = theme
  end

  def template
    render Shared::Container.new(size: "2xl", class: "py-12") do
      div(class: "md:flex items-center justify-between") do
        div do
          render PhlexUI::Typography::H1.new { "Themes" }
          render PhlexUI::Typography::Lead.new { "Customize your app fast with hand-picked themes." }
        end
        div(class: "flex gap-x-2 mt-4") do
          render Themes::CustomizePopover.new(theme: @theme)
          render Themes::CopyCode.new(theme: @theme)
        end
      end

      div(class: "flex flex-wrap justify-between -mx-2 pt-12") do
        div(class: "flex flex-col gap-y-6 p-3 w-full sm:w-1/2 xl:w-1/3") do
          render Themes::Grid::RepoTabs.new
          render Themes::Grid::LineGraph.new
          render Themes::Grid::Card.new
        end
        div(class: "flex flex-col gap-y-6 p-3 w-full sm:w-1/2 xl:w-1/3") do
          render Themes::Grid::Chat.new
          render Themes::Grid::Chart.new
          render Themes::Grid::CreateEvent.new
        end
        div(class: "flex flex-col gap-y-6 p-3 w-full sm:w-1/2 xl:w-1/3") do
          # render Themes::Grid::Command.new
          render Themes::Grid::Signin.new
          render Themes::Grid::Table.new
        end
      end
    end
  end
end
