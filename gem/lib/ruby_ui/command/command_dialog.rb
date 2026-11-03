# frozen_string_literal: true

module RubyUI
  # A Command in a modal Dialog (shadcn's CommandDialog). title: and
  # description: name the dialog for assistive technology (rendered sr-only);
  # show_close_button: adds the Dialog's close button. Wrap a
  # CommandDialogTrigger and a CommandDialogContent holding the Command.
  class CommandDialog < Base
    def initialize(title: "Command Palette", description: "Search for a command to run...", show_close_button: false, **attrs)
      @title = title
      @description = description
      @show_close_button = show_close_button
      super(**attrs)
    end

    def view_template(&)
      previous = context[:ruby_ui_command_dialog]
      context[:ruby_ui_command_dialog] = {title: @title, description: @description, show_close_button: @show_close_button}
      render Dialog.new(**attrs, &)
    ensure
      context[:ruby_ui_command_dialog] = previous
    end
  end
end
