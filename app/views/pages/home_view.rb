# frozen_string_literal: true

class Pages::HomeView < ApplicationView
  def template
    h1 { "Pages home" }
    p { "Find me in app/views/pages/home_view.rb" }
  end
end
