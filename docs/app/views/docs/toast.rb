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
    {key: "text_only", label: "Text Only", title: "Event has been created"},
    {key: "close_button", label: "Close Button", title: "Event has been created"},
    {key: "close_action", label: "Close + Action", title: "Event has been created"}
  ].freeze

  POSITIONS = %w[top-left top-center top-right bottom-left bottom-center bottom-right].freeze

  def view_template
    component = "Toast"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(
        title: "Toast",
        description: "An opinionated toast component."
      )

      Heading(level: 2) { "Examples" }
      Heading(level: 3) { "Types" }
      div(class: "grid gap-4 sm:grid-cols-2", data: {controller: "toast-demo"}) do
        EXAMPLES.each { |ex| example_box(ex) }
      end

      Heading(level: 2) { "About" }
      p(class: "text-muted-foreground text-sm leading-relaxed") do
        plain "Trigger toasts from the server with Turbo Streams or from JavaScript via "
        code(class: "rounded bg-muted px-1.5 py-0.5 text-xs") { "window.RubyUI.toast.*" }
        plain ". Heavily inspired by the original "
        a(
          href: "https://github.com/emilkowalski/sonner",
          target: "_blank",
          rel: "noopener",
          class: "underline underline-offset-2 hover:text-foreground"
        ) { "sonner" }
        plain "."
      end

      Heading(level: 2) { "Mount" }
      div(class: "rounded-md border bg-muted/30 p-4") do
        Codeblock(<<~RUBY, syntax: :ruby)
          # In application_layout.rb (Phlex), once globally:
          render RubyUI::ToastRegion.new

          # Pass flash to render Rails flash on initial load:
          render RubyUI::ToastRegion.new(flash: helpers.flash.to_h)
        RUBY
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
          # Option A — custom Turbo Stream action (compact):
          render turbo_stream: turbo_stream.action(
            :toast,
            target: "ruby-ui-toaster",
            variant: :success,
            title: "Saved",
            description: "Project updated."
          )

          # Option B — append a fully-rendered ToastItem (for Action / Cancel slots):
          render turbo_stream: turbo_stream.append("ruby-ui-toaster") {
            render RubyUI::ToastItem.new(variant: :success) do
              render RubyUI::ToastIcon.new(variant: :success)
              render RubyUI::ToastTitle.new { "Saved" }
              render RubyUI::ToastDescription.new { "Project updated." }
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

      Heading(level: 2) { "API Reference" }

      Heading(level: 3) { "Toaster (Region)" }
      props_table(REGION_PROPS)

      Heading(level: 3) { "ToastItem" }
      props_table(ITEM_PROPS)

      Heading(level: 3) { "JS API options" }
      p(class: "text-muted-foreground text-sm") do
        plain "Second argument to "
        code(class: "rounded bg-muted px-1.5 py-0.5 text-xs") { "RubyUI.toast.<variant>(message, options)" }
        plain " or "
        code(class: "rounded bg-muted px-1.5 py-0.5 text-xs") { "ruby-ui:toast" }
        plain " CustomEvent detail."
      end
      props_table(JS_OPTIONS)
    end
  end

  REGION_PROPS = [
    {name: "position", default: ":bottom_right", values: ":top_left | :top_center | :top_right | :bottom_left | :bottom_center | :bottom_right", description: "Where the toaster mounts on the viewport."},
    {name: "expand", default: "false", values: "Boolean", description: "Always show items expanded (no stack peek)."},
    {name: "max", default: "3", values: "Integer", description: "Max visible toasts before oldest auto-evicts."},
    {name: "duration", default: "4000", values: "Integer (ms)", description: "Default lifetime per toast. Pass 0 or Infinity to disable auto-dismiss."},
    {name: "gap", default: "14", values: "Integer (px)", description: "Spacing between toasts when expanded."},
    {name: "offset", default: "24", values: "Integer (px)", description: "Distance from the viewport edge."},
    {name: "theme", default: ":system", values: ":system | :light | :dark", description: "Color scheme override."},
    {name: "rich_colors", default: "false", values: "Boolean", description: "Enable variant-tinted backgrounds."},
    {name: "close_button", default: "false", values: "Boolean", description: "Render an X button in every toast (top-right)."},
    {name: "hotkey", default: '%w[alt t]', values: "Array<String>", description: "Keyboard shortcut to focus the first toast."},
    {name: "dir", default: ":ltr", values: ":ltr | :rtl", description: "Text direction."},
    {name: "flash", default: "nil", values: "Hash | nil", description: "Pass `helpers.flash.to_h` to render Rails flash on initial load."}
  ].freeze

  ITEM_PROPS = [
    {name: "variant", default: ":default", values: ":default | :success | :error | :warning | :info | :loading", description: "Visual + a11y role + icon."},
    {name: "id", default: "nil", values: "String", description: "DOM id; auto-generated when not provided."},
    {name: "duration", default: "nil", values: "Integer | nil", description: "Override the Region default. nil inherits."},
    {name: "dismissible", default: "true", values: "Boolean", description: "Allow Escape, swipe, X, and force-dismiss to close."},
    {name: "invert", default: "false", values: "Boolean", description: "Invert background/foreground (light-on-dark in light theme)."},
    {name: "on_dismiss", default: "nil", values: "String", description: "Stimulus action descriptor fired when the user dismisses."},
    {name: "on_auto_close", default: "nil", values: "String", description: "Stimulus action descriptor fired when the timer expires."}
  ].freeze

  JS_OPTIONS = [
    {name: "title", default: "—", values: "String", description: "Headline text. Falls back to the first positional argument."},
    {name: "description", default: "—", values: "String", description: "Secondary line under the title."},
    {name: "duration", default: "(Region default)", values: "Number | Infinity", description: "ms before auto-dismiss. Infinity = sticky."},
    {name: "action", default: "—", values: "{ label, onClick }", description: "Primary action button rendered inside the toast."},
    {name: "cancel", default: "—", values: "{ label, onClick }", description: "Secondary dismiss button."},
    {name: "closeButton", default: "false", values: "Boolean", description: "Force an X close button on this toast."},
    {name: "position", default: "(Region default)", values: "String", description: "Per-toast position override (changes Region's data-position before append)."},
    {name: "id", default: "(auto)", values: "String", description: "Set a stable id (used by .dismiss(id) and .promise)."},
    {name: "dismissible", default: "true", values: "Boolean", description: "Disable Escape / swipe / dismiss-all for this toast."},
    {name: "className", default: "—", values: "String", description: "Extra classes appended to the rendered <li>."}
  ].freeze

  private

  def props_table(rows)
    div(class: "border rounded-lg overflow-hidden") do
      Table do
        TableHeader do
          TableRow do
            TableHead { "Prop" }
            TableHead { "Default" }
            TableHead { "Values" }
            TableHead(class: "w-full") { "Description" }
          end
        end
        TableBody do
          rows.each do |r|
            TableRow do
              TableCell { InlineCode { r[:name] } }
              TableCell { InlineCode { r[:default] } }
              TableCell(class: "whitespace-normal") { InlineCode { r[:values] } }
              TableCell(class: "text-muted-foreground") { r[:description] }
            end
          end
        end
      end
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
