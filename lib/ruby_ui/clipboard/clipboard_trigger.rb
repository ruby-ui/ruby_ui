# frozen_string_literal: true

module RubyUI
  class ClipboardTrigger
    include ComponentBase

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
