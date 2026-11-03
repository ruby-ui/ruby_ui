# frozen_string_literal: true

class Views::Docs::Collapsible < Views::Base
  def view_template
    component = "Collapsible"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Collapsible", description: "An interactive component which expands/collapses a panel.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", description: "CollapsibleTrigger is the button itself. Pass Button options (variant:, size:, icon:) to style it as a Button.", context: self) do
        <<~RUBY
          Collapsible(class: "flex w-[350px] flex-col gap-2") do
            div(class: "flex items-center justify-between gap-4 px-4") do
              h4(class: "text-sm font-semibold") { "@joeldrapper starred 3 repositories" }
              CollapsibleTrigger(variant: :ghost, icon: true, class: "size-8") do
                chevrons_icon
                span(class: "sr-only") { "Toggle" }
              end
            end
            div(class: "rounded-md border px-4 py-2 font-mono text-sm") { "phlex-ruby/phlex" }
            CollapsibleContent(class: "flex flex-col gap-2") do
              div(class: "rounded-md border px-4 py-2 font-mono text-sm") { "phlex-ruby/phlex-rails" }
              div(class: "rounded-md border px-4 py-2 font-mono text-sm") { "ruby-ui/ruby_ui" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Open", description: "open: sets the initial state. The server renders it, so the panel shows the right state before any JavaScript runs.", context: self) do
        <<~RUBY
          Collapsible(open: true, class: "flex w-[350px] flex-col gap-2") do
            div(class: "flex items-center justify-between gap-4 px-4") do
              h4(class: "text-sm font-semibold") { "@joeldrapper starred 3 repositories" }
              CollapsibleTrigger(variant: :ghost, icon: true, class: "size-8") do
                chevrons_icon
                span(class: "sr-only") { "Toggle" }
              end
            end
            div(class: "rounded-md border px-4 py-2 font-mono text-sm") { "phlex-ruby/phlex" }
            CollapsibleContent(class: "flex flex-col gap-2") do
              div(class: "rounded-md border px-4 py-2 font-mono text-sm") { "phlex-ruby/phlex-rails" }
              div(class: "rounded-md border px-4 py-2 font-mono text-sm") { "ruby-ui/ruby_ui" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Rotating icon", description: "The trigger gets data-panel-open while open, and the root and content get data-open / data-closed, so you can style by state.", context: self) do
        <<~RUBY
          Collapsible(class: "w-[350px]") do
            CollapsibleTrigger(variant: :ghost, class: "group w-full justify-start") do
              chevron_right_icon
              plain "Order details"
            end
            CollapsibleContent(class: "px-2 pt-2 text-sm text-muted-foreground") do
              "Shipped on November 2 via express delivery."
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", context: self) do
        <<~RUBY
          Collapsible(disabled: true, class: "w-[350px]") do
            CollapsibleTrigger(variant: :outline) { "Show details" }
            CollapsibleContent(class: "pt-2 text-sm") { "You can't see this." }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Animated", description: "The panel exposes --collapsible-panel-height and gets data-starting-style while opening and data-ending-style while closing; it is hidden once its animation ends.", context: self) do
        <<~RUBY
          Collapsible(class: "w-[350px]") do
            CollapsibleTrigger(variant: :outline) { "Show recovery keys" }
            CollapsibleContent(class: "h-(--collapsible-panel-height) overflow-hidden transition-[height] duration-200 ease-out data-starting-style:h-0 data-ending-style:h-0") do
              div(class: "flex flex-col gap-2 pt-2 font-mono text-sm") do
                div(class: "rounded-md border px-4 py-2") { "alien-bean-pasta" }
                div(class: "rounded-md border px-4 py-2") { "wild-tiger-moon" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Find in page", description: "With hidden_until_found: true the browser's find in page can reach the hidden text and opens the panel. Try searching for “rubyists”.", context: self) do
        <<~RUBY
          Collapsible(class: "w-[350px]") do
            CollapsibleTrigger(variant: :outline) { "Who maintains RubyUI?" }
            CollapsibleContent(hidden_until_found: true) do
              p(class: "pt-2 text-sm") { "A community of rubyists who love Phlex." }
            end
          end
        RUBY
      end

      Heading(level: 2) { "Events" }

      Text do
        plain "Each toggle dispatches "
        InlineCode { "ruby-ui--collapsible:change" }
        plain " with "
        InlineCode { "detail: {open}" }
        plain " before the state changes. Call "
        InlineCode { "preventDefault()" }
        plain " to keep the current state. To open or close from your own code, set the "
        InlineCode { "data-ruby-ui--collapsible-open-value" }
        plain " attribute on the root."
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end

  private

  def chevrons_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      stroke_width: "2",
      stroke_linecap: "round",
      stroke_linejoin: "round"
    ) do |s|
      s.path(d: "m7 15 5 5 5-5")
      s.path(d: "m7 9 5-5 5 5")
    end
  end

  def chevron_right_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      stroke_width: "2",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      class: "transition-transform group-data-panel-open:rotate-90"
    ) do |s|
      s.path(d: "m9 18 6-6-6-6")
    end
  end
end
