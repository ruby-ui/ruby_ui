# frozen_string_literal: true

module RubyUI
  class DialogTrigger < Base
    private

    def default_attrs
      {
        data: {
          action: "click->ruby-ui--dialog#open"
        },
        class: "inline-block"
      }
    end
  end
end
