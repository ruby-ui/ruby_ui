# frozen_string_literal: true

require "securerandom"

module RubyUI
  # Names the progress bar: inside Progress, the root gets aria-labelledby
  # pointing at this element.
  class ProgressLabel < Base
    def view_template(&)
      progress = context[:ruby_ui_progress]
      id = attrs[:id] || progress&.dig(:label_id) || "progress-#{SecureRandom.hex(4)}-label"
      progress[:labelledby] = id if progress
      span(**mix(Progress.state_data(context, "progress-label"), attrs.except(:id), {id: id}), &)
    end

    private

    def default_attrs
      {role: "presentation", class: "text-sm font-medium"}
    end
  end
end
