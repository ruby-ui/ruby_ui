# frozen_string_literal: true

module RubyUI
  # Top-right slot for a control (a button, a link). The Alert reserves right
  # padding for it when present.
  class AlertAction < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "alert-action"},
        class: "absolute top-2.5 right-3"
      }
    end
  end
end
