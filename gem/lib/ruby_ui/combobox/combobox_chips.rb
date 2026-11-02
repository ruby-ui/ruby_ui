# frozen_string_literal: true

module RubyUI
  # The trigger of a multiple: combobox: one chip per selected item, then a
  # ComboboxChipsInput. The controller builds the chips from the checked items
  # with the template below; the popup is anchored to this box.
  #
  # max: (RubyUI extra) caps the chips: past it they collapse into a single
  # "<count> <term>" chip (term: from the root, "selected" without one) whose
  # remove button, like Backspace, clears the whole selection.
  class ComboboxChips < Base
    def initialize(show_remove: true, max: nil, **)
      @show_remove = show_remove
      @max = max
      super(**)
    end

    def view_template(&)
      div(**attrs) do
        template(data: {ruby_ui__combobox_target: "chipTemplate"}) do
          render ComboboxChip.new(show_remove: @show_remove)
        end
        yield if block_given?
      end
    end

    private

    def default_attrs
      {
        data: {
          slot: "combobox-chips",
          ruby_ui__combobox_target: "chips",
          max: @max,
          action: "click->ruby-ui--combobox#focusInput"
        },
        class: [
          "flex min-h-9 flex-wrap items-center gap-1.5 rounded-md border border-input bg-transparent bg-clip-padding",
          "px-2.5 py-1.5 text-sm shadow-xs transition-[color,box-shadow] dark:bg-input/30 cursor-text",
          "focus-within:border-ring focus-within:ring-3 focus-within:ring-ring/50",
          "has-aria-invalid:border-destructive has-aria-invalid:ring-3 has-aria-invalid:ring-destructive/20",
          "dark:has-aria-invalid:border-destructive/50 dark:has-aria-invalid:ring-destructive/40",
          "has-data-[slot=combobox-chip]:px-1.5"
        ]
      }
    end
  end
end
