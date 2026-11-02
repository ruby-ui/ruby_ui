# frozen_string_literal: true

module RubyUI
  class DialogMiddle < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    # No padding: DialogContent's gap-6 spaces the body, as in shadcn (vega).
    def default_attrs
      {}
    end
  end
end
