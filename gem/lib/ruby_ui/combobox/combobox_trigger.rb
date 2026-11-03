# frozen_string_literal: true

module RubyUI
  # The button that opens the popup, for the "Combobox in Popup" pattern: put a
  # ComboboxValue inside it and a ComboboxInput inside ComboboxContent. It is a
  # RubyUI Button (variant: :outline) with role=combobox, like Base UI's
  # Combobox.Trigger rendered through shadcn's Button.
  class ComboboxTrigger < Base
    include ComboboxContext

    def view_template(&block)
      # The popup holds the search input, so it is a dialog (Base UI's role).
      combobox[:popup] = :dialog
      # aria-controls is set by the controller while the popup is open.
      trigger_attrs = with_combobox_defaults(aria: {required: (combobox[:required] ? "true" : nil)})
      render Button.new(variant: :outline, disabled: !!combobox[:disabled], **trigger_attrs) do
        yield if block
        chevron
      end
    end

    private

    def default_attrs
      {
        role: "combobox",
        class: "w-full justify-between font-normal",
        aria: {haspopup: "dialog", expanded: "false"},
        data: {
          ruby_ui__combobox_target: "trigger",
          action: "click->ruby-ui--combobox#toggle keydown->ruby-ui--combobox#triggerKeydown"
        }
      }
    end

    def chevron
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        viewbox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        stroke_width: "2",
        stroke_linecap: "round",
        stroke_linejoin: "round",
        aria_hidden: "true",
        class: "pointer-events-none size-4 text-muted-foreground"
      ) { |s| s.path(d: "m6 9 6 6 6-6") }
    end
  end
end
