# frozen_string_literal: true

module RubyUI
  class DrawerMiddle < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    # Scrolling the body moves only the body: overscroll-contain keeps it from chaining into the snap scroller.
    def default_attrs
      {
        class: "min-h-0 flex-1 overflow-y-auto overscroll-contain px-4 pb-4"
      }
    end
  end
end
