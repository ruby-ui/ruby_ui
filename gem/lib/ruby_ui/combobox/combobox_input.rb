# frozen_string_literal: true

module RubyUI
  # The text input of a combobox, inside an input group (shadcn's ComboboxInput).
  # Outside ComboboxContent it is the trigger: typing filters and opens the list,
  # show_trigger: adds the chevron, show_clear: a button that clears the value.
  # Inside ComboboxContent it is the search field of the popup; pass
  # show_trigger: false there. Extra attributes go to the <input>.
  class ComboboxInput < Base
    include ComboboxContext

    INPUT_GROUP = [
      "group/input-group relative flex w-auto min-w-0 items-center outline-none",
      "h-9 rounded-md border border-input shadow-xs transition-[color,box-shadow] dark:bg-input/30",
      "has-[[data-slot=input-group-control]:focus-visible]:border-ring",
      "has-[[data-slot=input-group-control]:focus-visible]:ring-3",
      "has-[[data-slot=input-group-control]:focus-visible]:ring-ring/50",
      "has-[[data-slot][aria-invalid=true]]:border-destructive has-[[data-slot][aria-invalid=true]]:ring-3",
      "has-[[data-slot][aria-invalid=true]]:ring-destructive/20",
      "dark:has-[[data-slot][aria-invalid=true]]:ring-destructive/40",
      "in-data-[slot=combobox-content]:focus-within:border-inherit in-data-[slot=combobox-content]:focus-within:ring-0",
      "has-[>[data-align=inline-end]]:[&>input]:pr-1.5",
      "data-[disabled=true]:cursor-not-allowed"
    ].freeze

    ADDON = "order-last flex h-auto cursor-text items-center justify-center gap-2 py-1.5 pr-2 " \
      "text-sm font-medium text-muted-foreground select-none has-[>button]:-mr-1 " \
      "group-data-[disabled=true]/input-group:opacity-50"

    ADDON_BUTTON = "size-6 rounded-[calc(var(--radius)-5px)] p-0 shadow-none"

    def initialize(placeholder: nil, show_trigger: true, show_clear: false, disabled: false, **)
      @placeholder = placeholder
      @show_trigger = show_trigger
      @show_clear = show_clear
      @disabled = disabled
      super(**)
    end

    def view_template
      @disabled ||= !!combobox[:disabled]
      div(class: INPUT_GROUP, role: "group", data: {slot: "input-group", disabled: (@disabled ? "true" : nil)}) do
        input(**with_combobox_defaults(disabled: @disabled, aria: {controls: combobox[:list_id], required: (combobox[:required] ? "true" : nil)}))
        addon
      end
    end

    private

    def addon
      div(class: ADDON, role: "group", data: {slot: "input-group-addon", align: "inline-end", action: "click->ruby-ui--combobox#focusInput"}) do
        trigger_button if @show_trigger
        clear_button if @show_clear
      end
    end

    # Hidden while the clear button shows, as in shadcn.
    def trigger_button
      render Button.new(
        variant: :ghost, size: :xs, icon: true, disabled: @disabled, tabindex: -1,
        class: "#{ADDON_BUTTON} group-has-[[data-slot=combobox-clear]:not([hidden])]/input-group:hidden",
        aria: {label: "Toggle list"},
        data: {slot!: "input-group-button", action: "click->ruby-ui--combobox#toggle"}
      ) do
        icon("m6 9 6 6 6-6")
      end
    end

    # The controller shows it only while there is a value. It stays in the tab
    # order: it is the keyboard way to clear a single value.
    def clear_button
      render Button.new(
        variant: :ghost, size: :xs, icon: true, disabled: @disabled, hidden: true,
        class: ADDON_BUTTON,
        aria: {label: "Clear"},
        data: {slot!: "combobox-clear", ruby_ui__combobox_target: "clear", action: "click->ruby-ui--combobox#clear"}
      ) do
        icon("M18 6 6 18", "m6 6 12 12")
      end
    end

    def icon(*paths)
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        viewbox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        stroke_width: "2",
        stroke_linecap: "round",
        stroke_linejoin: "round",
        aria_hidden: "true",
        class: "pointer-events-none size-4"
      ) { |s| paths.each { |d| s.path(d: d) } }
    end

    def default_attrs
      {
        type: "text",
        role: "combobox",
        placeholder: @placeholder,
        autocomplete: "off",
        autocorrect: "off",
        spellcheck: "false",
        autocapitalize: "none",
        aria: {autocomplete: "list", expanded: "false", haspopup: "listbox"},
        class: [
          "h-full w-full min-w-0 flex-1 rounded-none border-0 bg-transparent px-2.5 py-1 text-base shadow-none",
          "border-input outline-none ring-0 focus:ring-0 focus-visible:border-ring focus-visible:ring-0 focus-visible:ring-ring/50 md:text-sm dark:bg-transparent",
          "placeholder:text-muted-foreground disabled:cursor-not-allowed disabled:opacity-50"
        ],
        data: {
          slot: "input-group-control",
          ruby_ui__combobox_target: "input",
          action: "input->ruby-ui--combobox#filter keydown->ruby-ui--combobox#inputKeydown " \
            "click->ruby-ui--combobox#inputClick"
        }
      }
    end
  end
end
