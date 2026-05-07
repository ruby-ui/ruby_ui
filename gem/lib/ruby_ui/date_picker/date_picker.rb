# frozen_string_literal: true

require "securerandom"

module RubyUI
  class DatePicker < Base
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
      @popover_options = {trigger: "click"}.merge(popover_options)
      @input_attrs = input_attrs
      @calendar_attrs = calendar_attrs
      @trigger_attrs = trigger_attrs
      @content_attrs = content_attrs
      super(**attrs)
    end

    def view_template
      div(**attrs) do
        RubyUI.Popover(options: @popover_options) do
          RubyUI.PopoverTrigger(**trigger_attrs) do
            div(class: "grid w-full max-w-sm items-center gap-1.5") do
              label(for: @id) { @label } if @label
              RubyUI.Input(**input_attrs)
            end
          end
          RubyUI.PopoverContent(**content_attrs) do
            RubyUI.Calendar(input_id: "##{@id}", selected_date: @selected_date, date_format: @date_format, **calendar_attrs)
          end
        end
      end
    end

    private

    def default_attrs
      {
        class: "space-y-4 w-[260px]"
      }
    end

    def trigger_attrs
      mix({class: "w-full"}, @trigger_attrs)
    end

    def input_attrs
      mix({
        type: "string",
        placeholder: @placeholder,
        id: @id,
        name: @name,
        value: @value,
        data_controller: "ruby-ui--calendar-input",
        class: "rounded-md border shadow"
      }.compact, @input_attrs)
    end

    def calendar_attrs
      mix({}, @calendar_attrs)
    end

    def content_attrs
      mix({}, @content_attrs)
    end
  end
end
