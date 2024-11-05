# frozen_string_literal: true

module RubyUI
  class ClipboardSource < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          rbui__clipboard_target: "source"
        }
      }
    end
  end
end
