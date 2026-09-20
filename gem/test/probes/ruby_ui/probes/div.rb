# frozen_string_literal: true

module RubyUI
  module Probes
    # One element with attributes and content: the shape of most components.
    class Div < Component
      private

      def default_attrs
        {class: "probe", data: {probe: true}}
      end
    end
  end
end
