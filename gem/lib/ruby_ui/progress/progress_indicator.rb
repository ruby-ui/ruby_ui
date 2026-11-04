# frozen_string_literal: true

module RubyUI
  # The filled part of the track. Its width is the percentage of the value
  # between min and max (no width when indeterminate). Progress renders it.
  class ProgressIndicator < Base
    def view_template
      percentage = context[:ruby_ui_progress]&.dig(:percentage)
      width = percentage && {style: "inset-inline-start: 0px; height: inherit; width: #{format_percentage(percentage)}%;"}
      div(**mix(Progress.state_data(context, "progress-indicator"), width || {}, attrs))
    end

    private

    def default_attrs
      {class: "h-full bg-primary transition-all"}
    end

    def format_percentage(value)
      ((value % 1).zero? ? value.to_i : value.round(4)).to_s
    end
  end
end
