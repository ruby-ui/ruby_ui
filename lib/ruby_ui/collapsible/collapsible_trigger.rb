# frozen_string_literal: true

module RubyUI
  class CollapsibleTrigger
    include ComponentBase

    private

    def default_attrs
      {
        data: {
          action: "click->ruby-ui--collapsible#toggle"
        }
      }
    end
  end
end
