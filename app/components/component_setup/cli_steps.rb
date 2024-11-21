module Components
  module ComponentSetup
    class CLISteps < Components::Base
      def initialize(component_name:)
        @component_name = component_name
      end

      private

      attr_reader :component_name

      def view_template
        div(class: "max-w-2xl mx-auto w-full py-10 space-y-6") do
          Heading(level: 4, class: "pb-4 border-b") { "Using RubyUI CLI" }
          Text do
            "We provide a Ruby gem with useful generators to help you to setup RubyUI components in your apps."
          end

          render Steps::Builder.new do |steps|
            steps.add_step do
              render Steps::Container do
                Text(size: "4", weight: "semibold") do
                  plain "Add RubyUI gem to your Gemfile if you don't have it yet"
                end

                code = <<~CODE
                  bundle add ruby_ui --group development --require false
                CODE
                div(class: "w-full") do
                  Codeblock(code, syntax: :javascript)
                end
              end
            end
            steps.add_step do
              render Steps::Container do
                Text(size: "4", weight: "semibold") do
                  "Run the install command"
                end

                code = <<~CODE
                  rails g ruby_ui:component #{component_name.camelcase}
                CODE
                div(class: "w-full") do
                  Codeblock(code, syntax: :javascript)
                end
              end
            end
          end
        end
      end
    end
  end
end
