# frozen_string_literal: true

class Views::Docs::Toast < Views::Base
  include Phlex::Rails::Helpers::ButtonTo

  def view_template
    component = "Toast"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(
        title: "Toast",
        description: "Hotwire-native sonner port. Push toasts from the server with Turbo Streams or trigger from JavaScript via window.RubyUI.toast."
      )

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Mount in your layout", context: self) do
        <<~RUBY
          # In application_layout.rb (Phlex) or application.html.erb (ERB), once globally:
          render RubyUI::ToastRegion.new
        RUBY
      end

      Heading(level: 2) { "Variants" }
      p(class: "text-muted-foreground text-sm") { "Click any to push a toast from the server (Turbo Stream)." }
      div(class: "flex flex-wrap gap-2 mt-2") do
        button_to "Default", docs_toast_demo_default_path, data: {turbo_stream: true}, class: button_class
        button_to "Success", docs_toast_demo_success_path, data: {turbo_stream: true}, class: button_class
        button_to "Error", docs_toast_demo_error_path, data: {turbo_stream: true}, class: button_class
        button_to "Warning", docs_toast_demo_warning_path, data: {turbo_stream: true}, class: button_class
        button_to "Info", docs_toast_demo_info_path, data: {turbo_stream: true}, class: button_class
        button_to "With action", docs_toast_demo_with_action_path, data: {turbo_stream: true}, class: button_class
      end

      Heading(level: 2) { "Server-pushed (Turbo Stream)" }
      div(class: "rounded-md border bg-muted/30 p-4") do
        Codeblock(<<~RUBY, syntax: :ruby)
          # In your controller, respond with a Turbo Stream that appends
          # a Toast::Item to the global region (id="ruby-ui-toaster"):
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

      Heading(level: 2) { "JS API" }
      div(class: "flex flex-wrap gap-2 mt-2", data: {controller: "toast-demo"}) do
        %w[success error info warning].each do |variant|
          button(
            type: "button",
            class: button_class,
            data: {action: "click->toast-demo#fire", toast_demo_variant_param: variant}
          ) { "toast.#{variant}" }
        end
        button(type: "button", class: button_class, data: {action: "click->toast-demo#promise"}) { "toast.promise" }
        button(type: "button", class: button_class, data: {action: "click->toast-demo#dismissAll"}) { "dismiss all" }
      end

      div(class: "rounded-md border bg-muted/30 p-4 mt-4") do
        Codeblock(<<~JS, syntax: :javascript)
          RubyUI.toast.success("Saved", { description: "Project updated." })
          RubyUI.toast.error("Boom")
          RubyUI.toast.info("Heads up")
          RubyUI.toast.warning("Storage almost full")
          RubyUI.toast.loading("Working...")
          RubyUI.toast.dismiss(id)  // no-arg dismisses all
          RubyUI.toast.promise(p, { loading, success, error })
        JS
      end

      Heading(level: 2) { "Position" }
      render Docs::VisualCodeExample.new(title: "Configurable on the Region", context: self) do
        <<~RUBY
          render RubyUI::ToastRegion.new(
            position: :top_right,
            expand: true,
            max: 5,
            duration: 6000
          )
        RUBY
      end

      Heading(level: 2) { "Rails flash bridge" }
      render Docs::VisualCodeExample.new(title: "Renders flash on initial load", context: self) do
        <<~RUBY
          # In your controller:
          # flash[:notice] = "Saved"
          # In your layout:
          render RubyUI::ToastRegion.new(flash: helpers.flash.to_h)
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end

  private

  def button_class
    "inline-flex items-center justify-center rounded-md border border-input bg-background px-3 py-2 text-sm font-medium hover:bg-accent"
  end
end
