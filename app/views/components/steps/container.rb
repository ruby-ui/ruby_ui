# frozen_string_literal: true

module Steps
  class Container < ApplicationComponent
    def view_template(&)
      div(class: "space-y-4", &)
    end
  end
end
