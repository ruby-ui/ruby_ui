# frozen_string_literal: true

module RubyUI
  # The bar behind the indicator. Progress renders it after its children.
  class ProgressTrack < Base
    def view_template(&)
      div(**mix(Progress.state_data(context, "progress-track"), attrs), &)
    end

    private

    def default_attrs
      {class: "relative flex h-1.5 w-full items-center overflow-x-hidden rounded-full bg-muted"}
    end
  end
end
