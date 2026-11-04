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
    {key: "close_action", label: "Close + Action", title: "Event has been created"},
    {key: "no_close", label: "No Close Button", title: "Event has been created"}
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
      render Docs::VisualCodeExample.new(title: "Click any to spawn a toast.", context: self) do
        <<~RUBY
          div(class: "grid gap-4 sm:grid-cols-2", data: {controller: "toast-demo"}) do
            [
              ["default", "Default"],
              ["success", "Success"],
              ["info", "Info"],
              ["warning", "Warning"],
              ["error", "Error"],
              ["with_action", "With Action"],
              ["promise", "Promise"],
              ["text_only", "Text Only"],
              ["close_button", "Close Button"],
              ["close_action", "Close + Action"],
              ["no_close", "No Close Button"]
            ].each do |key, label|
              div(class: "rounded-md border p-6 flex items-center justify-center min-h-[100px]") do
                button(
                  type: "button",
                  class: "inline-flex items-center justify-center rounded-md border border-input bg-background px-4 py-2 text-sm font-medium hover:bg-accent transition-colors cursor-pointer",
                  data: {action: "click->toast-demo#fire", toast_demo_kind_param: key}
                ) { "Show \#{label} toast" }
              end
            end
          end
        RUBY
      end

      Heading(level: 2) { "About" }
      p(class: "text-muted-foreground text-sm leading-relaxed") do
        plain "Trigger toasts from the server with Turbo Streams or from JavaScript via "
        code(class: "rounded bg-muted px-1.5 py-0.5 text-xs") { "window.RubyUI.toast.*" }
        plain ". Mirrors shadcn's Toast (Base UI): a polite live region, toasts that stack, "
        plain "pause while hovered or focused, and swipe away. Press F6 to move focus to the notifications, Tab to reach the newest toast and Escape to dismiss it."
      end

      Heading(level: 2) { "Mount" }
      div(class: "rounded-md border bg-muted/30 p-4") do
        Codeblock(<<~RUBY, syntax: :ruby)
          # In application_layout.rb (Phlex), once globally:
          render RubyUI::ToastRegion.new

          # Pass flash to render Rails flash on initial load:
          render RubyUI::ToastRegion.new(flash: helpers.flash.to_h)

          # The region is a popover="manual": a toast fired while a modal
          # Dialog/Sheet is open shows above it (it becomes clickable once
          # the modal closes, since the page behind a modal is inert).
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
              div(class: "flex min-w-0 flex-1 flex-col gap-1") do
                render RubyUI::ToastTitle.new { "Saved" }
                render RubyUI::ToastDescription.new { "Project updated." }
              end
              render RubyUI::ToastAction.new(label: "Undo", on: "click->projects#undo")
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
          RubyUI.toast("Saved", { priority: "high" }) // announced right away
          RubyUI.toast.dismiss(id)              // no-arg: dismiss all (alias: close)
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

      Heading(level: 3) { "ToastRegion (Toaster)" }
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
    {name: "position", default: ":bottom_right", values: ":top_left | :top_center | :top_right | :bottom_left | :bottom_center | :bottom_right", description: "Where the toaster mounts on the viewport (shadcn's is bottom-right)."},
    {name: "expand", default: "false", values: "Boolean", description: "Always show toasts expanded (no stack peek)."},
    {name: "max", default: "3", values: "Integer", description: "Toasts shown at once (Base UI limit). Older ones stay hidden and come back when a front toast closes."},
    {name: "duration", default: "5000", values: "Integer (ms)", description: "Default lifetime per toast (Base UI timeout). 0 keeps toasts until dismissed."},
    {name: "gap", default: "12", values: "Integer (px)", description: "Spacing between toasts when expanded."},
    {name: "close_button", default: "true", values: "Boolean", description: "Render the X button in every toast."},
    {name: "hotkey", default: "%w[F6]", values: "Array<String>", description: "Shortcut that moves focus to the notifications region (Tab then reaches the newest toast), e.g. %w[alt t]."},
    {name: "swipe_directions", default: "(from position)", values: "Array<:up | :down | :left | :right>", description: "Directions a swipe can dismiss in. Defaults to down/right for bottom-right; [] disables swipe."},
    {name: "flash", default: "nil", values: "Hash | nil", description: "Pass `helpers.flash.to_h` to render Rails flash on initial load."}
  ].freeze

  ITEM_PROPS = [
    {name: "variant", default: ":default", values: ":default | :success | :error | :warning | :info | :loading", description: "Icon and data-type."},
    {name: "priority", default: ":low", values: ":low | :high", description: "High-priority toasts are announced right away (role=alert) and use role=alertdialog."},
    {name: "id", default: "nil", values: "String", description: "DOM id; auto-generated when not provided."},
    {name: "duration", default: "nil", values: "Integer | nil", description: "Override the region default. nil inherits it; 0 stays until dismissed."},
    {name: "dismissible", default: "true", values: "Boolean", description: "Allow Escape, swipe, the X and Cancel to close it."},
    {name: "on_dismiss", default: "nil", values: "String", description: "Stimulus action (\"controller#method\") run on ruby-ui:toast:close. The controller must be on the toast or an ancestor."},
    {name: "on_remove", default: "nil", values: "String", description: "Stimulus action run on ruby-ui:toast:remove, after the exit animation."}
  ].freeze

  JS_OPTIONS = [
    {name: "title", default: "—", values: "String", description: "Headline text. Falls back to the first positional argument."},
    {name: "description", default: "—", values: "String", description: "Secondary line under the title."},
    {name: "duration", default: "(region default)", values: "Number | Infinity", description: "ms before auto-dismiss. 0 or Infinity = stays until dismissed."},
    {name: "priority", default: "\"low\"", values: "\"low\" | \"high\"", description: "\"high\" is announced right away."},
    {name: "action", default: "—", values: "{ label, onClick }", description: "Action button (outline). Clicking it closes the toast."},
    {name: "cancel", default: "—", values: "{ label, onClick }", description: "Secondary dismiss button (RubyUI extra)."},
    {name: "closeButton", default: "(region default)", values: "Boolean", description: "Show or hide the X on this toast."},
    {name: "onClose", default: "—", values: "Function", description: "Called when the toast starts closing ({ id, reason })."},
    {name: "onRemove", default: "—", values: "Function", description: "Called after the exit animation, when the toast leaves the DOM."},
    {name: "swipeDirections", default: "(region default)", values: "Array<String>", description: "Directions a swipe can dismiss this toast in."},
    {name: "position", default: "(region default)", values: "String", description: "Moves the region before this toast is added."},
    {name: "id", default: "(auto)", values: "String", description: "Stable id (used by .dismiss(id) and .promise)."},
    {name: "dismissible", default: "true", values: "Boolean", description: "Disable swipe / X / dismiss-all for this toast."},
    {name: "className", default: "—", values: "String", description: "Extra classes on the toast element."}
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
