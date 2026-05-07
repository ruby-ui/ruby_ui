# frozen_string_literal: true

module Docs
  class VisualCodeExample < Phlex::HTML
    def initialize(title:, context:, description: nil, src: nil)
      @title = title
      @context = context
      @description = description
      @src = src
    end

    def view_template(&block)
      code = block.call
      div do
        h3 { @title }
        p { @description } if @description
        pre { code }
        @context.instance_eval(code)
      end
    end
  end
end
