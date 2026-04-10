# frozen_string_literal: true

module RubyUI
  class TooltipTrigger
    include ComponentBase

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
