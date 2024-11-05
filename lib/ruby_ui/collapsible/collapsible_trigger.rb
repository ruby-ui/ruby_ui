# frozen_string_literal: true

module RubyUI
  class CollapsibleTrigger < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          action: "click->ruby_ui--collapsible#toggle"
        }
      }
    end
  end
end
