# frozen_string_literal: true

module RubyUI
  class TooltipTrigger < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          ruby_ui__tooltip_target: "trigger",
          action: [
            "mouseenter->ruby-ui--tooltip#show",
            "mouseleave->ruby-ui--tooltip#hide",
            "focus->ruby-ui--tooltip#show",
            "blur->ruby-ui--tooltip#hide"
          ]
        },
        variant: :outline
      }
    end
  end
end
