# frozen_string_literal: true

module Docs
  class VisualCodeExample < Phlex::HTML
    def initialize(title:, context:)
      @title = title
      @context = context
    end

    def view_template(&block)
      code = block.call
      div do
        h3 { @title }
        pre { code }
        @context.instance_eval(code)
      end
    end
  end
end
