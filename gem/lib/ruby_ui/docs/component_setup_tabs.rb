# frozen_string_literal: true

module Components
  module ComponentSetup
    class Tabs < Phlex::HTML
      def initialize(component_name:)
        @component_name = component_name
      end

      def view_template
        # Minimal stub - empty by default
      end
    end
  end
end
