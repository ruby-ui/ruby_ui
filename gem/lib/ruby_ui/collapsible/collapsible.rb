# frozen_string_literal: true

require "securerandom"

module RubyUI
  # A panel that expands and collapses, after shadcn's Collapsible (Base UI).
  #
  # open: is the initial state (shadcn's defaultOpen). The server renders the
  # matching state, so a closed panel is hidden before any JS runs. From the
  # outside, change the ruby-ui--collapsible open value to open or close it.
  #
  # Every toggle dispatches a cancelable ruby-ui--collapsible:change event
  # (detail: {open}) before the state changes, like onOpenChange; call
  # preventDefault() on it to keep the current state.
  #
  # disabled: true blocks toggling and disables the trigger.
  class Collapsible < Base
    def initialize(open: false, disabled: false, **attrs)
      @open = open
      @disabled = disabled
      @content_id = "collapsible-content-#{SecureRandom.hex(4)}"
      super(**attrs)
    end

    def view_template(&)
      previous = context[:ruby_ui_collapsible]
      context[:ruby_ui_collapsible] = {open: @open, disabled: @disabled, content_id: @content_id}
      div(**attrs, &)
    ensure
      context[:ruby_ui_collapsible] = previous
    end

    private

    def default_attrs
      {
        data: {
          slot: "collapsible",
          controller: "ruby-ui--collapsible",
          ruby_ui__collapsible_open_value: @open ? "true" : "false",
          ruby_ui__collapsible_disabled_value: @disabled ? "true" : "false",
          open: @open || nil,
          closed: !@open || nil,
          disabled: @disabled || nil
        }
      }
    end
  end
end
