# frozen_string_literal: true

module RubyUI
  class DrawerClose < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {action: "click->ruby-ui--drawer-content#close"}
      }
    end
  end
end
