# frozen_string_literal: true

module RubyUI
  class DrawerTrigger < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {action: "click->ruby-ui--drawer#open"}
      }
    end
  end
end
