# frozen_string_literal: true

module RubyUI
  # The root. open: renders it open; modal: false keeps the page usable while
  # it is open (no scroll lock, nothing made inert). Placement lives on
  # DropdownMenuContent (side:, align:, side_offset:, align_offset:).
  # options: {placement: "bottom-start"} still works as a fallback for side:
  # and align:; options[:strategy] is ignored (the menu is a top-layer popover).
  class DropdownMenu < Base
    def initialize(open: false, modal: true, options: {}, **attrs)
      @open = open
      @modal = modal
      @options = options
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          slot: "dropdown-menu",
          controller: "ruby-ui--dropdown-menu",
          ruby_ui__dropdown_menu_open_value: @open.to_s,
          ruby_ui__dropdown_menu_modal_value: @modal.to_s,
          ruby_ui__dropdown_menu_options_value: @options.to_json
        }
      }
    end
  end
end
