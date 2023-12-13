# frozen_string_literal: true

class Themes::IndexView < ApplicationView
  def template
    h1 { "Themes index" }
    p { "Find me in app/views/themes/index_view.rb" }
  end
end
