# frozen_string_literal: true

module RubyUI
  # The search field of a Command: an input group with a search icon. The
  # input is the combobox that controls CommandList; extra attributes go to the
  # <input>.
  class CommandInput < Base
    # shadcn's InputGroup focus ring targets data-slot=input-group-control,
    # which cmdk's input doesn't carry, so the command input shows no ring.
    INPUT_GROUP = "group/input-group relative flex w-full min-w-0 items-center outline-none " \
      "h-8! rounded-lg! border border-input/30 bg-input/30 shadow-none!"

    ADDON = "order-first flex h-auto cursor-text items-center justify-center gap-2 py-1.5 pl-2! " \
      "text-sm font-medium text-muted-foreground select-none"

    def initialize(placeholder: "Type a command or search...", **attrs)
      @placeholder = placeholder
      super(**attrs)
    end

    def view_template
      div(class: "p-1 pb-0", data: {slot: "command-input-wrapper"}) do
        div(class: INPUT_GROUP, role: "group", data: {slot: "input-group"}) do
          input(**attrs)
          div(class: ADDON, role: "group", data: {slot: "input-group-addon", align: "inline-start", action: "click->ruby-ui--command#focusInput"}) do
            search_icon
          end
        end
      end
    end

    private

    def search_icon
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        viewbox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        stroke_width: "2",
        stroke_linecap: "round",
        stroke_linejoin: "round",
        aria_hidden: "true",
        class: "size-4 shrink-0 opacity-50"
      ) do |s|
        s.path(d: "m21 21-4.34-4.34")
        s.circle(cx: "11", cy: "11", r: "8")
      end
    end

    def default_attrs
      {
        type: "text",
        role: "combobox",
        placeholder: @placeholder,
        autocomplete: "off",
        autocorrect: "off",
        autocapitalize: "none",
        spellcheck: "false",
        autofocus: true,
        aria: {autocomplete: "list", expanded: "true"},
        class: "h-full w-full min-w-0 flex-1 rounded-none border-0 bg-transparent py-1 pr-2 pl-1.5 text-sm shadow-none outline-hidden ring-0 " \
          "focus:ring-0 focus-visible:ring-0 placeholder:text-muted-foreground disabled:cursor-not-allowed disabled:opacity-50",
        data: {
          slot: "command-input",
          ruby_ui__command_target: "input",
          action: "input->ruby-ui--command#filter keydown->ruby-ui--command#inputKeydown"
        }
      }
    end
  end
end
