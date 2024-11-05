# frozen_string_literal: true

module RubyUI
  class ClipboardTrigger < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          rbui__clipboard_target: "trigger",
          action: "click->rbui--clipboard#copy"
        }
      }
    end
  end
end
