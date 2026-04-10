# frozen_string_literal: true

module RubyUI
  class SheetTrigger
    include ComponentBase

    private

    def default_attrs
      {
        data: {action: "click->ruby-ui--sheet#open"}
      }
    end
  end
end
