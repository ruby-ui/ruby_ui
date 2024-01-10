# frozen_string_literal: true

class Votes::IndexView < ApplicationView
  register_element :turbo_frame

  def initialize
    @components = components
  end

  def template
    render Shared::Container.new(size: 'lg', class: '!max-w-2xl py-12 space-y-12') do
      div do
        render PhlexUI::Typography::H1.new { 'Component Leaderboard' }
        render PhlexUI::Typography::Lead.new { "Vote for the components you'd like to see built first." }
      end
      render PhlexUI::Card.new(class: 'overflow-hidden') do
        render PhlexUI::Table::Builder.new(@components) do |t|
          t.column("Component") do |component|
            span(class: 'font-medium') { component[:name] }
          end
          t.column("Votes") do |component|
            turbo_frame(id: component[:slug]) do
              render PhlexUI::Link.new(href: helpers.toggle_vote_path(component[:slug]), data_turbo_method: :post, data_turbo_frame: component[:slug], variant: upvote_link_variant(component), size: :sm, class: 'rounded-full') do
                span(class: '-ml-1 mr-2') { upvote_icon }
                span { component[:vote_count] }
              end
            end
          end
        end
      end
    end
  end

  private

  def vote_count(slug)
    Vote.where(component_slug: slug).count
  end

  def upvote_link_variant(component)
    component[:voted_by_current_user] ? :primary : :outline
  end

  def components
    list = [
      { name: "Autosave", slug: "autosave" },
      { name: "Carousel", slug: "carousel" },
      { name: "Chart", slug: "chart" },
      { name: "Clipboard", slug: "clipboard" },
      { name: "Color Picker", slug: "color_picker" },
      { name: "Combobox", slug: "combobox" },
      { name: "Data Table", slug: "data_table" },
      { name: "Form", slug: "form" },
      { name: "Menu Bar", slug: "menu_bar" },
      { name: "Multi Select", slug: "multi_select" },
      { name: "Navigation Menu", slug: "navigation_menu" },
      { name: "Pagination", slug: "pagination" },
      { name: "Progress", slug: "progress" },
      { name: "Radio Group", slug: "radio_group" },
      { name: "Read more", slug: "read_more" },
      { name: "Rich text editor", slug: "rich_text_editor" },
      { name: "Scroll Area", slug: "scroll_area" },
      { name: "Separator", slug: "separator" },
      { name: "Skeleton Loader", slug: "skeleton_loader" },
      { name: "Slider", slug: "slider" },
      { name: "Switch", slug: "switch" },
      { name: "Textarea (Autogrow)", slug: "textarea" },
      { name: "Toast (Swipe to dismiss)", slug: "toast" },
      { name: "Toggle", slug: "toggle" },
      { name: "Turbo Dialog / Modal", slug: "turbo_dialog" },
      { name: "Video Player", slug: "video_player" },
    ]
    add_votes(list)
    add_voted_by_current_user(list)
    sort_by_votes(list)
  end

  def add_votes(list)
    list.each do |component|
      component[:vote_count] = vote_count(component[:slug])
    end
  end

  def add_voted_by_current_user(list)
    list.each do |component|
      component[:voted_by_current_user] = Vote.find_by(component_slug: component[:slug], user_id: Current.user.id).present?
    end
  end

  def sort_by_votes(list)
    list.sort_by { |component| component[:vote_count] }.reverse
  end

  def upvote_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 0 20 20",
      fill: "currentColor",
      class: "w-4 h-4"
    ) do |s|
      s.path(
        fill_rule: "evenodd",
        d:
          "M9.47 6.47a.75.75 0 0 1 1.06 0l4.25 4.25a.75.75 0 1 1-1.06 1.06L10 8.06l-3.72 3.72a.75.75 0 0 1-1.06-1.06l4.25-4.25Z",
        clip_rule: "evenodd"
      )
    end
  end
end
