module Components
  module ComponentSetup
    class Tabs < Components::Base
      def initialize(component_name:)
        @component_name = component_name
      end

      private

      attr_reader :component_name

      def view_template
        Heading(level: 2) { "Installation" }

        RubyUI::Tabs(default_value: "cli", class: "w-full") do
          TabsList do
            TabsTrigger(value: "cli") { "CLI" }
            TabsTrigger(value: "manual") { "Manual" }
          end

          TabsContent(value: "cli") do
            render CLISteps.new(component_name:)
          end

          TabsContent(value: "manual") do
            render ManualSteps.new(component_name:)
          end
        end
      end
    end
  end
end
