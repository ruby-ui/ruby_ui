# frozen_string_literal: true

require "securerandom"

module RubyUI
  # A date field with a calendar popover, after shadcn's date-picker-input
  # example (Base UI + vega): a field with a label, an input group holding the
  # text input and an icon button that opens a Popover with a Calendar.
  #
  # The ruby-ui--date-picker controller wires the parts: ArrowDown in the input
  # or Enter/Space on the button opens the calendar with focus on the selected
  # day, picking a day writes it into the input and closes the popover, focus
  # returns to the button, and a date typed in the input moves the calendar.
  #
  # input_attrs go to the <input>, trigger_attrs to the icon button,
  # content_attrs to PopoverContent and calendar_attrs to Calendar.
  class DatePicker < Base
    INPUT_GROUP = [
      "group/input-group relative flex w-full min-w-0 items-center outline-none",
      "h-9 rounded-md border border-input shadow-xs transition-[color,box-shadow] dark:bg-input/30",
      "has-[[data-slot=input-group-control]:focus-visible]:border-ring",
      "has-[[data-slot=input-group-control]:focus-visible]:ring-3",
      "has-[[data-slot=input-group-control]:focus-visible]:ring-ring/50",
      "has-[[data-slot][aria-invalid=true]]:border-destructive has-[[data-slot][aria-invalid=true]]:ring-3",
      "has-[[data-slot][aria-invalid=true]]:ring-destructive/20",
      "dark:has-[[data-slot][aria-invalid=true]]:ring-destructive/40",
      "has-[>[data-align=inline-end]]:[&>input]:pr-1.5"
    ].freeze

    # vega's inline-end addon; -mr-1 is its has-[>button] rule (here the
    # button sits inside the Popover wrapper).
    ADDON = "order-last flex h-auto items-center justify-center gap-2 py-1.5 pr-2 -mr-1 " \
      "text-sm font-medium text-muted-foreground select-none"

    def initialize(
      id: nil,
      name: nil,
      label: "Select a date",
      value: nil,
      placeholder: "Select a date",
      selected_date: value,
      date_format: "yyyy-MM-dd",
      popover_options: {},
      input_attrs: {},
      calendar_attrs: {},
      trigger_attrs: {},
      content_attrs: {},
      **attrs
    )
      @id = id || "date-picker-#{SecureRandom.hex(4)}"
      @name = name
      @label = label
      @value = value || selected_date&.to_s
      @placeholder = placeholder
      @selected_date = selected_date
      @date_format = date_format
      @popover_options = {trigger: "click", placement: "bottom-end"}.merge(popover_options)
      @input_attrs = input_attrs
      @calendar_attrs = calendar_attrs
      @trigger_attrs = trigger_attrs
      @content_attrs = content_attrs
      super(**attrs)
    end

    def view_template
      div(**attrs) do
        RubyUI.FormFieldLabel(for: @id) { @label } if @label
        div(class: INPUT_GROUP, role: "group", data: {slot: "input-group"}) do
          RubyUI.Input(**input_attrs)
          div(class: ADDON, role: "group", data: {slot: "input-group-addon", align: "inline-end"}) do
            RubyUI.Popover(id: popover_id, options: @popover_options, class: "flex") do
              RubyUI.PopoverTrigger(class: "flex") do
                RubyUI.Button(**trigger_attrs) { calendar_icon }
              end
              RubyUI.PopoverContent(**content_attrs) do
                RubyUI.Calendar(input_id: "##{@id}", selected_date: @selected_date, date_format: @date_format, **calendar_attrs)
              end
            end
          end
        end
      end
    end

    private

    def popover_id = "#{@id}-popover"

    # The outlet selector follows a caller's own id (calendar_attrs: {id:}).
    def calendar_id = @calendar_attrs[:id!] || @calendar_attrs[:id] || "#{@id}-calendar"

    # One id, not mixed: mix would join a caller's id with the default.
    def calendar_attrs = @calendar_attrs.except(:id, :id!).merge(id: calendar_id)

    def content_id = "#{@id}-content"

    # Same grid as FormField (shadcn's Field), without its validation
    # controller: a DatePicker inside a FormField must leave the input to it.
    def default_attrs
      {
        role: "group",
        class: "group/field flex w-full flex-col gap-3 *:w-full [&>.sr-only]:w-auto data-[invalid=true]:text-destructive",
        data: {
          slot: "field",
          orientation: "vertical",
          controller: "ruby-ui--date-picker",
          ruby_ui__date_picker_ruby_ui__popover_outlet: "##{popover_id}",
          ruby_ui__date_picker_ruby_ui__calendar_outlet: "##{calendar_id}",
          action: "ruby-ui--popover:show->ruby-ui--date-picker#opened ruby-ui--popover:hide->ruby-ui--date-picker#closed"
        }
      }
    end

    def input_attrs
      mix({
        type: "text",
        placeholder: @placeholder,
        id: @id,
        name: @name,
        value: @value,
        autocomplete: "off",
        class: [
          "block h-full min-w-0 flex-1 rounded-none border-0 border-input bg-transparent px-2.5 shadow-none ring-0",
          "focus-visible:ring-0 focus-visible:shadow-none dark:bg-transparent"
        ],
        data: {
          slot: "input-group-control",
          controller: "ruby-ui--calendar-input",
          ruby_ui__date_picker_target: "input",
          action: "keydown->ruby-ui--date-picker#inputKeydown input->ruby-ui--date-picker#syncCalendar"
        }
      }.compact, @input_attrs)
    end

    # mix turns slot! into a plain slot when the caller also passes data:, and
    # Button's own mix would then join it with its "button" slot. Re-mark it as
    # an override so the button keeps a single data-slot.
    def trigger_attrs
      attrs = mix({
        variant: :ghost,
        size: :icon_xs,
        class: "size-6 gap-2 rounded-[calc(var(--radius)-5px)] p-0 shadow-none",
        aria: {label: "Select date", haspopup: "dialog", expanded: "false"},
        data: {slot!: "input-group-button", ruby_ui__date_picker_target: "trigger"}
      }, @trigger_attrs)
      data = attrs[:data]
      data[:slot!] = data.delete(:slot!) || data.delete(:slot)
      attrs
    end

    def content_attrs
      mix({
        id: content_id,
        role: "dialog",
        aria: {label: "Choose date"},
        class: "w-auto overflow-hidden p-0 font-normal",
        data: {slot: "popover-content", ruby_ui__date_picker_target: "content", action: "click->ruby-ui--date-picker#pick"}
      }, @content_attrs)
    end

    def calendar_icon
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
      ) do |s|
        s.path(d: "M8 2v4")
        s.path(d: "M16 2v4")
        s.rect(width: "18", height: "18", x: "3", y: "4", rx: "2")
        s.path(d: "M3 10h18")
      end
    end
  end
end
