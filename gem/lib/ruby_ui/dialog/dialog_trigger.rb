# frozen_string_literal: true

module RubyUI
  class DialogTrigger < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          ruby_ui__dialog_target: "trigger",
          action: "click->ruby-ui--dialog#open"
        },
        class: "inline-block"
      }
    end
  end
end
