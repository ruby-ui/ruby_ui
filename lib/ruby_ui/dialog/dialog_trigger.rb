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
          action: "click->ruby_ui--dialog#open"
        },
        class: "inline-block"
      }
    end
  end
end
