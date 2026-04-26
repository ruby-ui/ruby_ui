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
          ruby_ui__clipboard_target: "trigger",
          action: "click->ruby-ui--clipboard#copy"
        }
      }
    end
  end
end
