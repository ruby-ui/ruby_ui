# frozen_string_literal: true

class Docs::GettingStarted::CustomizingComponentsView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Customizing components", description: "When theming doesn't suffice, PhlexUI allows you to tailor the components to your specific needs.")

      div(class: "space-y-4") do
        render PhlexUI::Typography::H2.new { "Introduction" }
        render PhlexUI::Typography::P.new { "While theming provides a powerful tool for modifying aspects such as fonts, brand colors, and border attributes, there may be instances where you need to directly customize the components. PhlexUI is designed to facilitate this process with ease." }
      end

      div(class: "space-y-4") do
        render PhlexUI::Typography::H2.new { "Updating attributes & classes" }
        render PhlexUI::Typography::P.new do
          plain "All components accept any HTML attribute, and will pass it through to the underlying HTML element. This is great for quick changes, or when you need to add a custom class for a one off situation."
        end
        render PhlexUI::Alert.new do
          puzzle_icon
          render PhlexUI::Alert::Title.new { "How it works" }
          render PhlexUI::Alert::Description.new do
            plain "When you pass an attribute to a PhlexUI component, it will be processed by the"
            render PhlexUI::Typography::InlineCode.new { "PhlexUI::AttributeMerger" }
            plain " class. You can read more about the "
            render PhlexUI::Typography::InlineLink.new(href: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/base.rb") { "PhlexUI::Base" }
            plain " and the "
            render PhlexUI::Typography::InlineLink.new(href: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/attribute_merger.rb") { "PhlexUI::AttributeMerger" }
            plain " classes on Github."
          end
        end
        render PhlexUI::Typography::Large.new { "Adding attributes" }
        render PhlexUI::Typography::P.new do
          plain "By default, attribute values are added to the existing values of the component. For instance, if you want to make a button span the full width of its container, you can do it like this: "
          render PhlexUI::Typography::InlineCode.new { "render PhlexUI::Button.new(class: 'w-full')" }
          plain ". This will add the "
          render PhlexUI::Typography::InlineCode.new { "w-full" }
          plain " class to the button, causing it to span the full width of its container."
        end
        render PhlexUI::Typography::Large.new { "Overriding Classes" }
        render PhlexUI::Typography::P.new do
          plain "There might be instances where you need to override a specific style attribute. For instance, if you wish to alter the color of a button while keeping the rest of the styles intact, you can achieve this as follows: "
          render PhlexUI::Typography::InlineCode.new { "render PhlexUI::Button.new(class: '!bg-red-500')" }
          plain ". This will replace the default background color with red by utilizing the "
          render PhlexUI::Typography::InlineCode.new { "!important" }
          plain " modifier."
        end
        render PhlexUI::Typography::Large.new { "Replacing Attributes" }
        render PhlexUI::Typography::P.new do
          plain "In some rare cases, you might need to replace the default value of an attribute entirely. For instance, if you want to change all the styles of a button, you can do it as follows: "
          render PhlexUI::Typography::InlineCode.new { "render PhlexUI::Button.new(class!: 'bg-red-500 text-white py-2 px-4 font-medium hover:bg-red-600')" }
          plain ". This will override all the default classes and apply only the ones you specify. In this case, it will apply "
          render PhlexUI::Typography::InlineCode.new { "bg-red-500 text-white py-2 px-4 font-medium hover:bg-red-600" }
          plain "."
        end
      end

      div(class: "space-y-4") do
        render PhlexUI::Typography::H2.new { "Redefining components" }
        render PhlexUI::Typography::P.new { "Redefining components is a powerful concept that allows you to redefine the underlying components through inheritance, or completely. This is useful when you need to make more complex changes to the components, that can't be achieved with attributes and classes alone. In other words, you can change the whole damn thing if you like." }
        # to redefine a component, find the component you want to redefine in the source code, and copy it into your application. Then, make the changes you need. For example, if you want to change the button component, you can copy the button component from the source code, and paste it into your application. Then, you can make the changes you need.
        render PhlexUI::Typography::Large.new { "How it works" }
        render PhlexUI::Typography::P.new do
          plain "To redefine a component, find the component you want to redefine in the source code, and copy it into your application. Then, make the changes you need. For example, if you want to change the button component, you can copy the button component from the source code, and paste it into your application. Then, you can make the changes you need."
        end
        render PhlexUI::Typography::Large.new { "Let's redefine the Alert component" }
        render PhlexUI::Typography::P.new do
          plain "Let's say you want to change the alert component to use a particular icon every time it is rendered. You can do this by redefining the component as follows:"
        end
        render Steps::Builder.new do |steps|
          # Find source code
          steps.add_step do
            render PhlexUI::Typography::H4.new { "Find the source code" }
            render PhlexUI::Typography::P.new do
              plain "First, find the source code for the component you want to redefine. In this case, we want to redefine the "
              render PhlexUI::Typography::InlineCode.new { "PhlexUI::Alert" }
              plain " component, so we'll find the source code for the alert component "
              render PhlexUI::Typography::InlineLink.new(href: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/alert.rb") { "here on Github" }
              plain "."
            end
          end
          # Copy source code to application
          steps.add_step do
            render PhlexUI::Typography::H4.new { "Copy the source code" }
            render PhlexUI::Typography::P.new do
              plain "Next, copy the source code for the component into your application. You can do this by creating a new file at "
              render PhlexUI::Typography::InlineCode.new { "app/views/components/phlex_u_i/alert.rb" }
              plain ", and pasting the source code into it. When using the  "
              render PhlexUI::Typography::InlineCode.new { "phlex-rails" }
              plain " gem, all components are loaded from this directory. So if you want to redefine a component, it will always sit somewhere inside the "
              render PhlexUI::Typography::InlineCode.new { "app/views/components/phlex_u_i" }
              plain " directory."
            end
            render PhlexUI::Typography::P.new do
              plain "Your new file should look something like this:"
            end
            render PhlexUI::Codeblock.new(alert_component_definition, syntax: :ruby)
          end
          # Make changes
          steps.add_step do
            render PhlexUI::Typography::H4.new { "Edit to perfection!" }
          end
        end
      end
    end
  end

  private

  def alert_component_definition
    <<~RUBY
      # frozen_string_literal: true

      module PhlexUI
        class Alert < Base
          def initialize(variant: nil, **attrs)
            @variant = variant
            super(**attrs) # must be called after variant is set
          end

          def template(&)
            div(**attrs, &)
          end

          private

          def colors
            case @variant
            when nil then 'ring-border bg-muted/20 text-foreground [&>svg]:opacity-80'
            when :warning then 'ring-warning/20 bg-warning/5 text-warning [&>svg]:text-warning/80'
            when :success then 'ring-success/20 bg-success/5 text-success [&>svg]:text-success/80'
            when :destructive then 'ring-destructive/20 bg-destructive/5 text-destructive [&>svg]:text-destructive/80'
            end
          end

          def default_attrs
            base_classes = 'backdrop-blur relative w-full ring-1 ring-inset rounded-lg px-4 py-4 text-sm [&>svg+div]:translate-y-[-3px] [&>svg]:absolute [&>svg]:left-4 [&>svg]:top-4 [&>svg~*]:pl-8'
            {
              class: tokens(base_classes, colors),
            }
          end
        end
      end
    RUBY
  end

  private

  def puzzle_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      class: "w-5 h-5"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d:
          "M14.25 6.087c0-.355.186-.676.401-.959.221-.29.349-.634.349-1.003 0-1.036-1.007-1.875-2.25-1.875s-2.25.84-2.25 1.875c0 .369.128.713.349 1.003.215.283.401.604.401.959v0a.64.64 0 01-.657.643 48.39 48.39 0 01-4.163-.3c.186 1.613.293 3.25.315 4.907a.656.656 0 01-.658.663v0c-.355 0-.676-.186-.959-.401a1.647 1.647 0 00-1.003-.349c-1.036 0-1.875 1.007-1.875 2.25s.84 2.25 1.875 2.25c.369 0 .713-.128 1.003-.349.283-.215.604-.401.959-.401v0c.31 0 .555.26.532.57a48.039 48.039 0 01-.642 5.056c1.518.19 3.058.309 4.616.354a.64.64 0 00.657-.643v0c0-.355-.186-.676-.401-.959a1.647 1.647 0 01-.349-1.003c0-1.035 1.008-1.875 2.25-1.875 1.243 0 2.25.84 2.25 1.875 0 .369-.128.713-.349 1.003-.215.283-.4.604-.4.959v0c0 .333.277.599.61.58a48.1 48.1 0 005.427-.63 48.05 48.05 0 00.582-4.717.532.532 0 00-.533-.57v0c-.355 0-.676.186-.959.401-.29.221-.634.349-1.003.349-1.035 0-1.875-1.007-1.875-2.25s.84-2.25 1.875-2.25c.37 0 .713.128 1.003.349.283.215.604.401.96.401v0a.656.656 0 00.658-.663 48.422 48.422 0 00-.37-5.36c-1.886.342-3.81.574-5.766.689a.578.578 0 01-.61-.58v0z"
      )
    end
  end
end
