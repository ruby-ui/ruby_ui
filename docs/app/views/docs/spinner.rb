# frozen_string_literal: true

class Views::Docs::Spinner < Views::Base
  def view_template
    component = "Spinner"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Spinner", description: "An indicator that can be used to show a loading state.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          Spinner()
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Size", description: "The size is controlled from the outside with any size utility.", context: self) do
        <<~RUBY
          div(class: "flex items-center gap-6") do
            Spinner(class: "size-3")
            Spinner(class: "size-4")
            Spinner(class: "size-6")
            Spinner(class: "size-8")
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Color", description: "The spinner inherits the current text color.", context: self) do
        <<~RUBY
          div(class: "flex items-center gap-6") do
            Spinner(class: "size-6 text-red-500")
            Spinner(class: "size-6 text-green-500")
            Spinner(class: "size-6 text-blue-500")
            Spinner(class: "size-6 text-muted-foreground")
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Button", description: "The button carries the state, the spinner is decorative.", context: self) do
        <<~RUBY
          div(class: "flex flex-wrap items-center gap-4") do
            Button(disabled: true, aria: {busy: "true"}, class: "gap-2") do
              Spinner(label: nil)
              plain "Loading..."
            end
            Button(variant: :outline, disabled: true, aria: {busy: "true"}, class: "gap-2") do
              Spinner(label: nil)
              plain "Please wait"
            end
            Button(variant: :secondary, size: :sm, disabled: true, aria: {busy: "true"}, class: "gap-2") do
              Spinner(label: nil, class: "size-3")
              plain "Processing"
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Badge", context: self) do
        <<~RUBY
          div(class: "flex flex-wrap items-center gap-4") do
            Badge(class: "gap-1.5") do
              Spinner(label: nil, class: "size-3")
              plain "Syncing"
            end
            Badge(variant: :outline, class: "gap-1.5") do
              Spinner(label: nil, class: "size-3")
              plain "Updating"
            end
            Badge(variant: :destructive, class: "gap-1.5") do
              Spinner(label: nil, class: "size-3")
              plain "Deleting"
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Empty", description: "Use a spinner as the media of an empty state to build a loading screen.", context: self) do
        <<~RUBY
          Empty(class: "w-full") do
            EmptyHeader do
              EmptyMedia(variant: :icon) do
                Spinner()
              end
              EmptyTitle { "Processing your request" }
              EmptyDescription { "Please wait while we process your request. Do not refresh the page." }
            end
            EmptyContent do
              Button(variant: :outline, size: :sm) { "Cancel" }
            end
          end
        RUBY
      end

      Heading(level: 2) { "Customization" }

      Text do
        plain "The generator copies "
        InlineCode { "spinner.rb" }
        plain " into "
        InlineCode { "app/components/ruby_ui/spinner/" }
        plain ", so the component belongs to your app. RubyUI inlines the SVG because the gem ships no icon dependency — but if your app has one, such as "
        InlineLink(href: "https://github.com/AliOsm/phlex-icons", target: "_blank") { "phlex-icons" }
        plain ", replace "
        InlineCode { "view_template" }
        plain " with the icon component and drop the two constants."
      end

      Codeblock(<<~RUBY, syntax: :ruby)
        # app/components/ruby_ui/spinner/spinner.rb
        module RubyUI
          class Spinner < Base
            include PhlexIcons

            def view_template
              Lucide::LoaderPinwheel(**attrs)
            end

            # initialize and default_attrs stay as they are;
            # ICON_PATH and ICON_ATTRS are no longer needed
          end
        end
      RUBY

      Text do
        plain "Without an icon gem, swap "
        InlineCode { "ICON_PATH" }
        plain " for the path data of any other 24x24 stroke icon. An icon drawn with more than one path needs those extra elements added to "
        InlineCode { "view_template" }
        plain " too."
      end

      Heading(level: 2) { "Accessibility" }

      Text do
        plain "A standalone spinner announces itself with "
        InlineCode { 'role="status"' }
        plain " and "
        InlineCode { 'aria-label="Loading"' }
        plain ". Pass "
        InlineCode { "label:" }
        plain " to describe the specific operation."
      end

      Text do
        plain "Inside a button, badge or any other labelled control, pass "
        InlineCode { "label: nil" }
        plain " to render the spinner as decoration ("
        InlineCode { 'aria-hidden="true"' }
        plain ") and let the control announce the state with "
        InlineCode { 'aria-busy="true"' }
        plain ". A labelled spinner would otherwise be read out as part of the control's own name."
      end

      Codeblock(<<~RUBY, syntax: :ruby)
        # announces itself
        Spinner(label: "Saving changes")
        # => <svg role="status" aria-label="Saving changes" ...>

        # decorative, inside a control that announces the state
        Spinner(label: nil)
        # => <svg aria-hidden="true" ...>
      RUBY

      render Components::ComponentSetup::Tabs.new(component_name: component)

      # components
      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
