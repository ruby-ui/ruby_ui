# frozen_string_literal: true

module RubyUI
  # Shared by the combobox parts: Base builds attrs in initialize, before the
  # Phlex context exists, so values that come from the root (ids, name,
  # multiple, disabled) are added while rendering. The caller's own attributes
  # still win.
  module ComboboxContext
    private

    def combobox = context[:ruby_ui_combobox] || {}

    def with_combobox_defaults(defaults)
      defaults.merge(attrs) { |_, ours, theirs| (ours.is_a?(Hash) && theirs.is_a?(Hash)) ? ours.merge(theirs) : theirs }
    end
  end
end
