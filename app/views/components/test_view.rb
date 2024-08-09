# frozen_string_literal: true

class TestView < Phlex::HTML
  include RBUI
  include PhlexUI

  def view_template(&)
    div(&)
  end
end
