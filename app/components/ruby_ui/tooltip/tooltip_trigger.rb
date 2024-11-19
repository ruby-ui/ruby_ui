# frozen_string_literal: true

module RubyUI
  class TooltipTrigger < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {ruby_ui__tooltip_target: "trigger"},
        variant: :outline,
        class: "peer"
      }
    end
  end
end
