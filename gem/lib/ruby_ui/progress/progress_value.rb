# frozen_string_literal: true

module RubyUI
  # Shows the formatted value ("56%"; empty when indeterminate). Hidden from
  # assistive tech: the progressbar already announces it. A block replaces
  # the text and receives the formatted value and the value given to
  # Progress, before clamping (nil when indeterminate).
  class ProgressValue < Base
    def view_template(&block)
      progress = context[:ruby_ui_progress] || {}
      span(**mix(Progress.state_data(context, "progress-value"), attrs)) do
        if block
          yield(progress[:formatted_value].to_s, progress[:value])
        else
          plain progress[:formatted_value].to_s
        end
      end
    end

    private

    def default_attrs
      {aria: {hidden: "true"}, class: "ml-auto text-sm text-muted-foreground tabular-nums"}
    end
  end
end
