# frozen_string_literal: true

module RubyUI
  class ClipboardSource
    include ComponentBase

    private

    def default_attrs
      {
        data: {
          ruby_ui__clipboard_target: "source"
        }
      }
    end
  end
end
