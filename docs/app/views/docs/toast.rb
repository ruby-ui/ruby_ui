# frozen_string_literal: true

class Views::Docs::Toast < Views::Base
  include Phlex::Rails::Helpers::ButtonTo

  EXAMPLES = [
    {key: "default", label: "Default", title: "Event has been created", description: "Sunday, December 03, 2023 at 9:00 AM"},
    {key: "success", label: "Success", title: "Event has been created"},
    {key: "info", label: "Info", title: "Be at the area 10 minutes before the event time"},
    {key: "warning", label: "Warning", title: "Event start time cannot be earlier than 8am"},
    {key: "error", label: "Error", title: "Event has not been created"},
    {key: "with_action", label: "With Action", title: "Event has been created", action_label: "Undo"},
    {key: "promise", label: "Promise", title: nil},
    {key: "text_only", label: "Text Only", title: "Event has been created"}
  ].freeze

  POSITIONS = %w[top-left top-center top-right bottom-left bottom-center bottom-right].freeze

  def view_template
    component = "Toast"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(
        title: "Toast",
        description: "Toast notifications, Hotwire-native. Trigger from the server with Turbo Streams or from JavaScript via window.RubyUI.toast.*. Heavily inspired by the original sonner: https://github.com/emilkowalski/sonner."
      )

      Heading(level: 2) { "Mount" }
      div(class: "rounded-md border bg-muted/30 p-4") do
        Codeblock(<<~RUBY, syntax: :ruby)
          # In application_layout.rb (Phlex), once globally:
          render RubyUI::ToastRegion.new

          # Pass flash to render Rails flash on initial load:
          render RubyUI::ToastRegion.new(flash: helpers.flash.to_h)
        RUBY
      end

      Heading(level: 2) { "Examples" }
      Heading(level: 3) { "Types" }
      div(class: "grid gap-4 sm:grid-cols-2", data: {controller: "toast-demo"}) do
        EXAMPLES.each { |ex| example_box(ex) }
      end

      Heading(level: 3) { "Position" }
      p(class: "text-muted-foreground text-sm") { "Use the position prop to change where toasts mount." }
      div(class: "rounded-md border p-8 flex flex-wrap items-center justify-center gap-2", data: {controller: "toast-demo"}) do
        POSITIONS.each do |pos|
          button(
            type: "button",
            class: button_class,
            data: {action: "click->toast-demo#position", toast_demo_position_param: pos}
          ) { pos.split("-").map(&:capitalize).join(" ") }
        end
      end

      Heading(level: 2) { "Server-pushed (Turbo Stream)" }
      p(class: "text-muted-foreground text-sm") { "Append a toast to the global region from any controller." }
      div(class: "flex flex-wrap gap-2 mt-2") do
        button_to "Push success from server",
          docs_toast_demo_success_path,
          class: button_class,
          form: {data: {turbo_stream: "true"}, class: "inline"}
      end
      div(class: "rounded-md border bg-muted/30 p-4 mt-4") do
        Codeblock(<<~RUBY, syntax: :ruby)
          # In your controller:
          render turbo_stream: turbo_stream.append("ruby-ui-toaster") {
            render RubyUI::ToastItem.new(variant: :success) do
              render RubyUI::ToastIcon.new(variant: :success)
              render RubyUI::ToastTitle.new { "Saved" }
              render RubyUI::ToastDescription.new { "Project updated." }
              render RubyUI::ToastClose.new
            end
          }
        RUBY
      end

      Heading(level: 2) { "JavaScript API" }
      p(class: "text-muted-foreground text-sm") do
        plain "Hotwire-friendly: window.RubyUI.toast.* is sugar over a CustomEvent dispatch. Either path works."
      end
      div(class: "rounded-md border bg-muted/30 p-4 mt-2") do
        Codeblock(<<~JS, syntax: :javascript)
          // Sugar:
          RubyUI.toast.success("Saved", { description: "Project updated." })
          RubyUI.toast.error("Boom")
          RubyUI.toast.info("Heads up")
          RubyUI.toast.warning("Storage almost full")
          RubyUI.toast.loading("Working...")
          RubyUI.toast.dismiss(id)              // no-arg: dismiss all
          RubyUI.toast.promise(p, { loading, success, error })

          // Equivalent CustomEvent (any source can dispatch this):
          window.dispatchEvent(new CustomEvent("ruby-ui:toast", {
            detail: { variant: "success", title: "Saved", description: "..." }
          }))
        JS
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end

  private

  def example_box(ex)
    div(class: "rounded-md border p-8 flex items-center justify-center min-h-[120px]") do
      button(
        type: "button",
        class: button_class,
        data: {action: "click->toast-demo#fire", toast_demo_kind_param: ex[:key]}
      ) { "Show #{ex[:label]} toast" }
    end
  end

  def button_class
    "inline-flex items-center justify-center rounded-md border border-input bg-background px-4 py-2 text-sm font-medium hover:bg-accent transition-colors"
  end
end
