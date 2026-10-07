# frozen_string_literal: true

module RubyUI
  module Probes
    # A custom-element root — DataTableFrame's shape.
    class Frame < Component
      private

      def default_attrs
        {id: "frame"}
      end
    end
  end
end
