module Components
  module ComponentSetup
    class ManualSteps < Components::Base
      def initialize(component_name:)
        @component_name = component_name
        @dependencies = RubyUI::FileManager.dependencies(@component_name)
      end

      private

      attr_reader :component_name, :dependencies

      def view_template
        div(class: "max-w-2xl mx-auto w-full py-10 space-y-6") do
          Heading(level: 4, class: "pb-4 border-b") { "Manual installation" }

          render Steps::Builder.new do |steps|
            component_steps(steps)
            stimulus_controller_steps(steps)
            js_dependencies_steps(steps)
            ruby_dependencies_steps(steps)
            component_dependencies_steps(steps)
          end
        end
      end

      def component_steps(steps)
        component_file_paths = RubyUI::FileManager.component_file_paths(component_name)

        component_file_paths.each do |component_path|
          component_class = component_path.split("/").last.delete_suffix(".rb").camelcase
          component_file_name = component_path.split("/").last
          component_code = RubyUI::FileManager.component_code(component_path)

          steps.add_step do
            render Steps::Container do
              Text(size: "4", weight: "semibold") do
                plain "Add "
                InlineCode(class: "whitespace-nowrap") { "RubyUI::#{component_class}" }
                plain " to "
                InlineCode(class: "whitespace-nowrap") { "app/components/ruby_ui/#{component_name.underscore}/#{component_file_name}" }
              end

              div(class: "w-full") do
                Codeblock(component_code, syntax: :ruby)
              end
            end
          end
        end
      end

      def stimulus_controller_steps(steps)
        stimulus_controller_file_paths = RubyUI::FileManager.stimulus_controller_file_paths(component_name)

        return if stimulus_controller_file_paths.empty?

        stimulus_controller_file_paths.each do |controller_path|
          controller_file_name = controller_path.split("/").last
          controller_code = RubyUI::FileManager.component_code(controller_path)
          steps.add_step do
            render Steps::Container do
              Text(size: "4", weight: "semibold") do
                plain "Add "
                InlineCode(class: "whitespace-nowrap") { controller_file_name }
                plain " to "
                InlineCode(class: "whitespace-nowrap") { "app/javascript/controllers/ruby_ui/#{controller_file_name}" }
              end

              div(class: "w-full") do
                Codeblock(controller_code, syntax: :javascript)
              end
            end
          end
        end

        steps.add_step do
          render Steps::Container do
            Text(size: "4", weight: "semibold") do
              plain "Update the Stimulus controllers manifest file"
            end

            Alert(variant: :destructive) do
              AlertTitle { "Importmap!" }
              AlertDescription { "You don't need to run this command if you are using Importmap" }
            end

            div(class: "w-full") do
              Codeblock("rake stimulus:manifest:update", syntax: :javascript)
            end
          end
        end
      end

      def js_dependencies_steps(steps)
        return unless dependencies["js_packages"].present?

        dependencies["js_packages"].each do |js_package|
          steps.add_step do
            code = <<~CODE
              // with yarn
              yarn add #{js_package}
              // with npm
              npm install #{js_package}
              // with importmaps
              #{pin_importmap_instructions(js_package)}
            CODE

            render Steps::Container do
              Text(size: "4", weight: "semibold") do
                plain "Install "
                InlineCode(class: "whitespace-nowrap") { js_package }
                plain " Javascript dependency"
              end

              div(class: "w-full") do
                Codeblock(code, syntax: :javascript)
              end
            end
          end
        end
      end

      def ruby_dependencies_steps(steps)
        return unless dependencies["gems"].present?

        dependencies["gems"].each do |gem|
          steps.add_step do
            code = <<~CODE
              bundle add #{gem}
            CODE

            render Steps::Container do
              Text(size: "4", weight: "semibold") do
                plain "Install "
                InlineCode(class: "whitespace-nowrap") { gem }
                plain " Ruby gem"
              end

              div(class: "w-full") do
                Codeblock(code, syntax: :javascript)
              end
            end
          end
        end
      end

      def component_dependencies_steps(steps)
        return unless dependencies["components"].present?

        steps.add_step do
          render Steps::Container do
            Text(size: "4", weight: "semibold") do
              plain "Install required components"
            end

            Text do
              plain "Component  "
              InlineCode(class: "whitespace-nowrap") { component_name.camelcase }
              plain " relies on the following RubyUI components. Refer to their individual installation guides for setup instructions:"
            end

            TypographyList do
              dependencies["components"].each do |component|
                TypographyListItem do
                  Link(size: :lg, target: "_blank", href: public_send(:"docs_#{component.underscore}_path")) do
                    span(class: "font-bold") { component.camelcase }
                    span { " - Installation guide" }
                  end
                end
              end
            end
          end
        end
      end

      # Temporary solution while we don't remove
      # motion adn tippy.js dependencies
      def pin_importmap_instructions(js_package)
        case js_package
        when "motion"
          <<~CODE
            // Add to your config/importmap.rb
            pin "motion", to: "https://cdn.jsdelivr.net/npm/motion@10.18.0/+esm"
          CODE
        when "tippy.js"
          <<~CODE
            // Add to your config/importmap.rb
            pin "tippy.js", to: "https://cdn.jsdelivr.net/npm/tippy.js@6.3.7/+esm"
            pin "@popperjs/core", to: "https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/+esm"\n
          CODE
        else
          "bin/importmap pin #{js_package}"
        end
      end
    end
  end
end
