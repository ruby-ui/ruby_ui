# frozen_string_literal: true

class Views::Docs::Toast < Views::Base
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

      render Docs::VisualCodeExample.new(title: "Click any to spawn", context: self) do
        div(class: "flex flex-wrap gap-2", data_controller: "toast-demo") do
          variants_buttons
        end
        nil
      end

      Heading(level: 2) { "Server-pushed (Turbo Stream)" }

      render Docs::VisualCodeExample.new(title: "Append from controller", context: self) do
        button_to(
          "Push from server",
          docs_toast_demo_with_action_path,
          class: "inline-flex items-center justify-center rounded-md border border-input bg-background px-3 py-2 text-sm font-medium hover:bg-accent",
          data: {turbo_stream: true}
        )
        nil
      end

      Heading(level: 2) { "JS API" }

      render Docs::VisualCodeExample.new(title: "window.RubyUI.toast", context: self) do
        <<~JS
          RubyUI.toast.success("Saved", { description: "Project updated." })
          RubyUI.toast.error("Boom", { description: "Server returned 500." })
          RubyUI.toast.info("Heads up")
          RubyUI.toast.warning("Storage almost full")
          RubyUI.toast.loading("Working...")
          RubyUI.toast.dismiss(id) // or no arg to dismiss all

          RubyUI.toast.promise(
            fetch("/things"),
            { loading: "Saving...", success: "Saved", error: "Failed" }
          )
        JS
      end

      Heading(level: 2) { "Position" }

      render Docs::VisualCodeExample.new(title: "All six positions", context: self) do
        <<~RUBY
          render RubyUI::ToastRegion.new(position: :top_right, expand: true, max: 5)
        RUBY
      end

      Heading(level: 2) { "Rails flash bridge" }

      render Docs::VisualCodeExample.new(title: "Renders flash on initial load", context: self) do
        <<~RUBY
          # In your controller
          flash[:notice] = "Saved"

          # In your layout, pass flash to the region
          render RubyUI::ToastRegion.new(flash: flash.to_h)
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end

  private

  def variants_buttons
    [
      {label: "Default", path: docs_toast_demo_default_path},
      {label: "Success", path: docs_toast_demo_success_path},
      {label: "Error", path: docs_toast_demo_error_path},
      {label: "Warning", path: docs_toast_demo_warning_path},
      {label: "Info", path: docs_toast_demo_info_path},
      {label: "With action", path: docs_toast_demo_with_action_path}
    ].each do |btn|
      button_to(
        btn[:label],
        btn[:path],
        class: "inline-flex items-center justify-center rounded-md border border-input bg-background px-3 py-2 text-sm font-medium hover:bg-accent",
        data: {turbo_stream: true},
        form: {class: "inline"}
      )
    end
  end
end
