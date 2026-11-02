# frozen_string_literal: true

module RubyUI
  # The modal panel of a CommandDialog: a Dialog content pinned at a third of
  # the viewport, with the dialog's sr-only title and description.
  class CommandDialogContent < Base
    def view_template(&block)
      settings = context[:ruby_ui_command_dialog] || {}
      render DialogContent.new(show_close_button: settings.fetch(:show_close_button, false), **attrs) do
        div(class: "sr-only") do
          render DialogTitle.new { settings.fetch(:title, "Command Palette") }
          render DialogDescription.new { settings.fetch(:description, "Search for a command to run...") }
        end
        yield if block
      end
    end

    private

    def default_attrs
      {class: "top-1/3 translate-y-0 overflow-hidden rounded-xl! p-0"}
    end
  end
end
