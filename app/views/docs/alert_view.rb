# frozen_string_literal: true

class Docs::AlertView < ApplicationView
  def template
    h1 { "Docs::Alert" }
    p { "Find me in app/views/docs/alert_view.rb" }
  end
end
