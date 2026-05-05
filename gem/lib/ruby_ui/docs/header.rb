# frozen_string_literal: true

module Docs
  class Header < Phlex::HTML
    def initialize(title:, description: nil)
      @title = title
      @description = description
    end

    def view_template
      div do
        h1 { @title }
        p { @description } if @description
      end
    end
  end
end
