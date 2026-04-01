# frozen_string_literal: true

module RubyUI
  class SheetTrigger < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: { action: 'click->ruby-ui--sheet#open' }
      }
    end
  end
end
