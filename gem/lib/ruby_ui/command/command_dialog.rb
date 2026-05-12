# frozen_string_literal: true

module RubyUI
  class CommandDialog < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          controller: "ruby-ui--command-dialog",
          ruby_ui__command_dialog_ruby_ui__command_outlet: "[data-ruby-ui--command-dialog-instance]"
        }
      }
    end
  end
end
