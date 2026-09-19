# frozen_string_literal: true

# The golden catalog: what "parity with 1.6" is measured against.
#
# One `component` block per directory under lib/ruby_ui/, and inside it the
# scenarios whose HTML is recorded as a snapshot. Every RubyUI::Base subclass
# must be reachable from at least one scenario — golden_test.rb fails if one is
# not, so a new component cannot be added without extending the ruler.
#
# Scenario blocks are written exactly like the body of the `phlex { ... }`
# helper in test_helper.rb. Two rules for the content inside them:
#
#   * Keep text short and free of leading/trailing spaces. The canonical form
#     is blind to whitespace between a text node and a sibling element, so
#     spacing baked into a string is not something this suite can measure.
#   * Prefer real compositions over isolated sub-components. The composition is
#     what users write, and for table/list/select fragments it is also what
#     keeps the scenario meaningful rather than a bare `<td>`.
#
# Variant coverage is enumerative where a component exposes a closed set:
# Button and Link have six variants and four sizes, Badge has 28 colours, and
# those are the cases a restyle regresses.

Golden::Catalog.component "accordion" do
  scenario "default_trigger_and_content" do
    RubyUI.Accordion do
      RubyUI.AccordionItem do
        RubyUI.AccordionDefaultTrigger { "Title" }
        RubyUI.AccordionDefaultContent { "Content" }
      end
    end
  end

  scenario "custom_trigger_with_icon" do
    RubyUI.Accordion do
      RubyUI.AccordionItem(open: true, rotate_icon: 90) do
        RubyUI.AccordionTrigger do |trigger|
          trigger.p { "What is RubyUI?" }
          RubyUI.AccordionIcon
        end
        RubyUI.AccordionContent do |content|
          content.p { "A UI component library for Ruby." }
        end
      end
    end
  end
end

Golden::Catalog.component "alert" do
  scenario "default" do
    RubyUI.Alert do
      RubyUI.AlertTitle { "Heads up!" }
      RubyUI.AlertDescription { "You can add components to your app." }
    end
  end

  scenario "destructive" do
    RubyUI.Alert(variant: :destructive) do
      RubyUI.AlertTitle { "Error" }
      RubyUI.AlertDescription { "Your session expired." }
    end
  end

  scenario "warning" do
    RubyUI.Alert(variant: :warning) { RubyUI.AlertTitle { "Careful" } }
  end

  scenario "success" do
    RubyUI.Alert(variant: :success) { RubyUI.AlertTitle { "Done" } }
  end
end

Golden::Catalog.component "alert_dialog" do
  scenario "default" do
    RubyUI.AlertDialog do
      RubyUI.AlertDialogTrigger { RubyUI.Button { "Show dialog" } }
      RubyUI.AlertDialogContent do
        RubyUI.AlertDialogHeader do
          RubyUI.AlertDialogTitle { "Are you absolutely sure?" }
          RubyUI.AlertDialogDescription { "This action cannot be undone." }
        end
        RubyUI.AlertDialogFooter do
          RubyUI.AlertDialogCancel { "Cancel" }
          RubyUI.AlertDialogAction { "Continue" }
        end
      end
    end
  end

  scenario "open" do
    RubyUI.AlertDialog(open: true) do
      RubyUI.AlertDialogContent { RubyUI.AlertDialogTitle { "Open" } }
    end
  end
end

Golden::Catalog.component "aspect_ratio" do
  scenario "default" do
    RubyUI.AspectRatio do |aspect|
      aspect.img(alt: "Placeholder", loading: "lazy", src: "/placeholder.png")
    end
  end

  scenario "square" do
    RubyUI.AspectRatio(aspect_ratio: "1/1", class: "rounded-md border") do |aspect|
      aspect.img(alt: "Placeholder", src: "/placeholder.png")
    end
  end
end

Golden::Catalog.component "avatar" do
  scenario "image_with_fallback" do
    RubyUI.Avatar do
      RubyUI.AvatarImage(src: "/avatar.png", alt: "Jane Doe")
      RubyUI.AvatarFallback { "JD" }
    end
  end

  %i[sm md lg xl].each do |size|
    scenario "size_#{size}" do
      RubyUI.Avatar(size: size) { RubyUI.AvatarFallback { "JD" } }
    end
  end
end

Golden::Catalog.component "badge" do
  %i[sm md lg].each do |size|
    scenario "size_#{size}" do
      RubyUI.Badge(size: size) { "Badge" }
    end
  end

  scenario "all_variants" do
    RubyUI::Badge::COLORS.each_key do |variant|
      RubyUI.Badge(variant: variant) { variant.to_s }
    end
  end
end

Golden::Catalog.component "breadcrumb" do
  scenario "default" do
    RubyUI.Breadcrumb do
      RubyUI.BreadcrumbList do
        RubyUI.BreadcrumbItem { RubyUI.BreadcrumbLink(href: "/") { "Home" } }
        RubyUI.BreadcrumbSeparator
        RubyUI.BreadcrumbItem { RubyUI.BreadcrumbEllipsis }
        RubyUI.BreadcrumbSeparator
        RubyUI.BreadcrumbItem { RubyUI.BreadcrumbPage { "Current" } }
      end
    end
  end
end

Golden::Catalog.component "bubble" do
  scenario "default" do
    RubyUI.Bubble { RubyUI.BubbleContent { "Hi" } }
  end

  scenario "muted_aligned_end_with_reactions" do
    RubyUI.BubbleGroup do
      RubyUI.Bubble(variant: :muted, align: :end) do
        RubyUI.BubbleContent { "Hi" }
        RubyUI.BubbleReactions { "OK" }
      end
    end
  end

  scenario "content_as_anchor" do
    RubyUI.Bubble { RubyUI.BubbleContent(as: :a, href: "#") { "Open" } }
  end

  scenario "reactions_top_start" do
    RubyUI.BubbleReactions(side: :top, align: :start) { "OK" }
  end
end

Golden::Catalog.component "button" do
  %i[primary secondary destructive outline ghost link].each do |variant|
    scenario "variant_#{variant}" do
      RubyUI.Button(variant: variant) { variant.to_s }
    end
  end

  %i[sm md lg xl].each do |size|
    scenario "size_#{size}" do
      RubyUI.Button(size: size) { size.to_s }
    end

    scenario "icon_size_#{size}" do
      RubyUI.Button(size: size, icon: true) { "X" }
    end
  end

  scenario "submit_disabled" do
    RubyUI.Button(type: :submit, disabled: true) { "Save" }
  end
end

Golden::Catalog.component "calendar" do
  scenario "default" do
    RubyUI.Calendar
  end

  scenario "bound_to_input" do
    RubyUI.Calendar(
      input_id: "#event-date",
      selected_date: "2026-05-15",
      min_date: "2026-05-07",
      date_format: "dd/MM/yyyy",
      class: "rounded-md border shadow"
    )
  end

  scenario "header_parts" do
    RubyUI.CalendarHeader do
      RubyUI.CalendarTitle(default: "May 2026")
      RubyUI.CalendarPrev
      RubyUI.CalendarNext
    end
  end
end

Golden::Catalog.component "card" do
  scenario "default" do
    RubyUI.Card do
      RubyUI.CardHeader do
        RubyUI.CardTitle { "Create project" }
        RubyUI.CardDescription { "Deploy your new project in one click." }
      end
      RubyUI.CardContent { "Body" }
      RubyUI.CardFooter { RubyUI.Button { "Deploy" } }
    end
  end
end

Golden::Catalog.component "carousel" do
  %i[horizontal vertical].each do |orientation|
    scenario orientation.to_s do
      RubyUI.Carousel(orientation: orientation) do
        RubyUI.CarouselContent do
          RubyUI.CarouselItem { "1" }
          RubyUI.CarouselItem { "2" }
        end
        RubyUI.CarouselPrevious
        RubyUI.CarouselNext
      end
    end
  end

  scenario "with_options" do
    RubyUI.Carousel(options: {loop: true, align: "start"}) do
      RubyUI.CarouselContent { RubyUI.CarouselItem { "1" } }
    end
  end
end

Golden::Catalog.component "chart" do
  scenario "bar" do
    RubyUI.Chart(
      options: {
        type: "bar",
        data: {
          labels: ["Phlex", "ERB"],
          datasets: [{label: "render time (ms)", data: [100, 520]}]
        },
        options: {indexAxis: "y", scales: {y: {beginAtZero: true}}}
      }
    )
  end
end

Golden::Catalog.component "checkbox" do
  scenario "default" do
    RubyUI.Checkbox(name: "terms", value: "1")
  end

  scenario "checked_disabled" do
    RubyUI.Checkbox(name: "terms", checked: true, disabled: true)
  end

  scenario "group" do
    RubyUI.CheckboxGroup do
      RubyUI.Checkbox(name: "colors[]", value: "red")
      RubyUI.Checkbox(name: "colors[]", value: "blue")
    end
  end
end

Golden::Catalog.component "clipboard" do
  scenario "default" do
    RubyUI.Clipboard
  end

  scenario "custom_source_and_trigger" do
    RubyUI.Clipboard(success: "Copiado!", error: "Falhou!") do
      RubyUI.ClipboardSource { "gem install ruby_ui" }
      RubyUI.ClipboardTrigger { RubyUI.Button(icon: true) { "C" } }
    end
  end

  %i[success error].each do |type|
    scenario "popover_#{type}" do
      RubyUI.ClipboardPopover(type: type) { type.to_s }
    end
  end
end

Golden::Catalog.component "codeblock" do
  scenario "ruby_with_clipboard" do
    RubyUI.Codeblock(<<~RUBY, syntax: :ruby)
      def hello_world
        puts "Hello, world!"
      end
    RUBY
  end

  scenario "ruby_without_clipboard" do
    RubyUI.Codeblock("puts :ok\n", syntax: :ruby, clipboard: false)
  end
end

Golden::Catalog.component "collapsible" do
  scenario "closed" do
    RubyUI.Collapsible do
      RubyUI.CollapsibleTrigger { RubyUI.Button(variant: :ghost) { "Toggle" } }
      RubyUI.CollapsibleContent { "Hidden body" }
    end
  end

  scenario "open" do
    RubyUI.Collapsible(open: true) do
      RubyUI.CollapsibleTrigger { RubyUI.Button(variant: :ghost) { "Toggle" } }
      RubyUI.CollapsibleContent { "Visible body" }
    end
  end
end

Golden::Catalog.component "combobox" do
  scenario "radio_items" do
    RubyUI.Combobox(term: "frameworks") do
      RubyUI.ComboboxTrigger(placeholder: "Select your framework")
      RubyUI.ComboboxPopover do
        RubyUI.ComboboxSearchInput(placeholder: "Type the framework name")
        RubyUI.ComboboxList do
          RubyUI.ComboboxEmptyState { "No results" }
          RubyUI.ComboboxListGroup(label: "Ruby") do
            RubyUI.ComboboxItem { RubyUI.ComboboxRadio(name: "Rails", value: "rails") }
            RubyUI.ComboboxItem { RubyUI.ComboboxRadio(name: "Hanami", value: "hanami") }
          end
        end
      end
    end
  end

  scenario "multiple_with_badges" do
    RubyUI.Combobox(multiple: true, term: "frameworks", placement: "top-start") do
      RubyUI.ComboboxBadgeTrigger(placeholder: "Select", clear_button: true)
      RubyUI.ComboboxPopover do
        RubyUI.ComboboxList do
          RubyUI.ComboboxToggleAllCheckbox
          RubyUI.ComboboxItem do
            RubyUI.ComboboxCheckbox(name: "Rails", value: "rails")
            RubyUI.ComboboxItemIndicator
          end
        end
      end
    end
  end

  scenario "input_trigger" do
    RubyUI.ComboboxInputTrigger(placeholder: "Pick one")
  end

  scenario "clear_button" do
    RubyUI.ComboboxClearButton
  end

  # The badge is cloned into the trigger by the Stimulus controller, so it is
  # never composed from Ruby — it is only ever rendered on its own.
  scenario "badge" do
    RubyUI.ComboboxBadge { "Rails" }
  end
end

Golden::Catalog.component "command" do
  scenario "dialog" do
    RubyUI.CommandDialog do
      RubyUI.CommandDialogTrigger do
        RubyUI.Button(variant: :outline) do
          RubyUI.ShortcutKey { "K" }
        end
      end
      RubyUI.CommandDialogContent do
        RubyUI.Command do
          RubyUI.CommandInput
          RubyUI.CommandEmpty { "No results found." }
          RubyUI.CommandList do
            RubyUI.CommandGroup(title: "Components") do
              RubyUI.CommandItem(value: "Accordion", href: "/docs/accordion") { "Accordion" }
              RubyUI.CommandItem(value: "Alert", href: "/docs/alert") { "Alert" }
            end
          end
        end
      end
    end
  end

  %i[sm md lg].each do |size|
    scenario "dialog_content_#{size}" do
      RubyUI.CommandDialogContent(size: size) { "body" }
    end
  end

  scenario "trigger_with_custom_keybindings" do
    RubyUI.CommandDialogTrigger(keybindings: ["ctrl+p"]) { "Open" }
  end
end

Golden::Catalog.component "context_menu" do
  scenario "default" do
    RubyUI.ContextMenu do
      RubyUI.ContextMenuTrigger { "Right click here" }
      RubyUI.ContextMenuContent(class: "w-64") do
        RubyUI.ContextMenuItem(href: "#", shortcut: "[") { "Back" }
        RubyUI.ContextMenuItem(href: "#", shortcut: "]", disabled: true) { "Forward" }
        RubyUI.ContextMenuSeparator
        RubyUI.ContextMenuItem(href: "#", checked: true) { "Show Bookmarks Bar" }
      end
    end
  end

  scenario "with_options" do
    RubyUI.ContextMenu(options: {placement: "right-start"}) do
      RubyUI.ContextMenuTrigger { "Target" }
    end
  end

  # ContextMenuLabel#default_attrs reads
  #
  #   class: ["px-2 py-1.5 ...", inset?: "pl-8"]
  #
  # so the trailing pair is a Hash in the class list, not a condition: the
  # literal `Hash#inspect` of `{inset?: "pl-8"}` lands in the class attribute
  # for every value of `inset:`. Ruby 3.4 changed that inspect format, so the
  # rendered HTML differs between the two Rubies CI runs and cannot be pinned
  # by one snapshot. Recorded here rather than dropped, so the ruler names the
  # bug instead of hiding it. Remove `pending:` when the component is fixed.
  %i[inset flush].each do |style|
    scenario "label_#{style}", pending: "ContextMenuLabel renders Hash#inspect into class; output differs on Ruby 3.3 vs 3.4" do
      RubyUI.ContextMenuLabel(inset: style == :inset) { "More Tools" }
    end
  end
end

Golden::Catalog.component "data_table" do
  columns = [
    {key: :email, label: "Email"},
    {key: :salary, label: "Salary", visible: false}
  ].freeze

  scenario "full_frame" do
    RubyUI.DataTable(id: "employees") do
      RubyUI.DataTableForm(action: "/employees/bulk", id: "employees_form") do
        RubyUI.DataTableToolbar do
          RubyUI.DataTableSearch(path: "/employees", value: "alice", frame_id: "employees")
          RubyUI.DataTableColumnToggle(columns: columns)
          RubyUI.DataTableBulkActions { RubyUI.Button(variant: :destructive) { "Delete" } }
        end
        RubyUI.Table do
          RubyUI.TableHeader do
            RubyUI.TableRow do
              RubyUI.TableHead { RubyUI.DataTableSelectAllCheckbox }
              RubyUI.DataTableSortHead(column_key: :name, label: "Name", sort: "name", direction: "asc", path: "/employees", query: {"search" => "alice"})
            end
          end
          RubyUI.TableBody do
            RubyUI.TableRow do
              RubyUI.TableCell { RubyUI.DataTableRowCheckbox(value: 42, label: "Select Alice") }
              RubyUI.TableCell { "Alice" }
              RubyUI.TableCell { RubyUI.DataTableExpandToggle(controls: "employee-42-detail") }
            end
          end
        end
        RubyUI.DataTablePaginationBar do
          RubyUI.DataTableSelectionSummary(total_on_page: 10)
          RubyUI.DataTablePerPageSelect(path: "/employees", value: 25)
          RubyUI.DataTablePagination(page: 3, per_page: 10, total_count: 61, path: "/employees", query: {"search" => "alice"})
        end
      end
    end
  end

  scenario "pagination_first_page" do
    RubyUI.DataTablePagination(page: 1, per_page: 10, total_count: 30, path: "/x", query: {})
  end

  scenario "pagination_wide_window" do
    RubyUI.DataTablePagination(page: 10, per_page: 1, total_count: 20, path: "/x", query: {}, window: 2)
  end

  scenario "pagination_manual_adapter" do
    RubyUI.DataTablePagination(
      with: RubyUI::DataTableManualAdapter.new(page: 2, per_page: 5, total_count: 21),
      path: "/x",
      query: {}
    )
  end

  scenario "sort_head_unsorted" do
    RubyUI.DataTableSortHead(column_key: :name, label: "Name", path: "/x", query: {})
  end

  scenario "expand_toggle_expanded" do
    RubyUI.DataTableExpandToggle(controls: "row-1", expanded: true, label: "Toggle")
  end

  scenario "search_without_debounce" do
    RubyUI.DataTableSearch(path: "/x", debounce: false, preserved_params: {"sort" => "name"})
  end
end

Golden::Catalog.component "date_picker" do
  scenario "default" do
    RubyUI.DatePicker(id: "event-date", name: "event[date]", value: "2026-05-15")
  end

  scenario "without_label" do
    RubyUI.DatePicker(id: "event-date", label: nil)
  end

  scenario "generated_id" do
    RubyUI.DatePicker
  end
end

Golden::Catalog.component "dialog" do
  scenario "default" do
    RubyUI.Dialog do
      RubyUI.DialogTrigger { RubyUI.Button { "Open Dialog" } }
      RubyUI.DialogContent do
        RubyUI.DialogHeader do
          RubyUI.DialogTitle { "RubyUI to the rescue" }
          RubyUI.DialogDescription { "Build accessible apps with ease." }
        end
        RubyUI.DialogMiddle { "Body" }
        RubyUI.DialogFooter do
          RubyUI.Button(variant: :outline) { "Cancel" }
          RubyUI.Button { "Save" }
        end
      end
    end
  end

  %i[sm md lg xl].each do |size|
    scenario "content_#{size}" do
      RubyUI.DialogContent(size: size) { "body" }
    end
  end

  scenario "open" do
    RubyUI.Dialog(open: true) { RubyUI.DialogContent { "body" } }
  end
end

Golden::Catalog.component "dropdown_menu" do
  scenario "default" do
    RubyUI.DropdownMenu do
      RubyUI.DropdownMenuTrigger(class: "w-full") { RubyUI.Button(variant: :outline) { "Open" } }
      RubyUI.DropdownMenuContent do
        RubyUI.DropdownMenuLabel { "My Account" }
        RubyUI.DropdownMenuSeparator
        RubyUI.DropdownMenuItem(href: "/profile") { "Profile" }
        RubyUI.DropdownMenuItem(as: :div) { "Billing" }
      end
    end
  end

  scenario "fixed_strategy" do
    RubyUI.DropdownMenu(options: {strategy: "fixed"}) do
      RubyUI.DropdownMenuContent { RubyUI.DropdownMenuItem(href: "#") { "Item" } }
    end
  end
end

Golden::Catalog.component "empty" do
  scenario "default" do
    RubyUI.Empty do
      RubyUI.EmptyHeader do
        RubyUI.EmptyMedia(variant: :icon) { "I" }
        RubyUI.EmptyTitle { "Nothing here" }
        RubyUI.EmptyDescription { "No content yet." }
      end
      RubyUI.EmptyContent { RubyUI.Button { "Create" } }
    end
  end

  scenario "media_default" do
    RubyUI.EmptyMedia { "M" }
  end
end

Golden::Catalog.component "form" do
  scenario "default" do
    RubyUI.Form(action: "/users", method: "post") do
      RubyUI.FormField do
        RubyUI.FormFieldLabel(for: "name") { "Name" }
        RubyUI.Input(id: "name", name: "name", placeholder: "Jane Doe", required: true, minlength: "3")
        RubyUI.FormFieldHint { "At least 3 characters." }
        RubyUI.FormFieldError { "Name is required." }
      end
    end
  end
end

Golden::Catalog.component "hover_card" do
  scenario "default" do
    RubyUI.HoverCard do
      RubyUI.HoverCardTrigger { RubyUI.Button(variant: :link) { "@joeldrapper" } }
      RubyUI.HoverCardContent do
        RubyUI.Avatar { RubyUI.AvatarFallback { "JD" } }
      end
    end
  end

  scenario "with_options" do
    RubyUI.HoverCard(option: {placement: "bottom"}) { RubyUI.HoverCardTrigger { "T" } }
  end
end

Golden::Catalog.component "input" do
  scenario "default" do
    RubyUI.Input(name: "email", placeholder: "jane@example.com")
  end

  scenario "typed_and_disabled" do
    RubyUI.Input(type: :email, name: "email", value: "jane@example.com", disabled: true)
  end
end

Golden::Catalog.component "input_otp" do
  scenario "default" do
    RubyUI.InputOtp(length: 6, name: "code") do
      RubyUI.InputOtpGroup do
        RubyUI.InputOtpSlot(index: 0)
        RubyUI.InputOtpSlot(index: 1)
        RubyUI.InputOtpSlot(index: 2)
      end
      RubyUI.InputOtpSeparator
      RubyUI.InputOtpGroup do
        RubyUI.InputOtpSlot(index: 3)
        RubyUI.InputOtpSlot(index: 4)
        RubyUI.InputOtpSlot(index: 5)
      end
    end
  end

  scenario "alphanumeric_pattern" do
    RubyUI.InputOtp(length: 4, pattern: "[a-zA-Z0-9]", name: "code") do
      RubyUI.InputOtpGroup { RubyUI.InputOtpSlot(index: 0) }
    end
  end
end

Golden::Catalog.component "link" do
  %i[primary secondary destructive outline ghost link].each do |variant|
    scenario "variant_#{variant}" do
      RubyUI.Link(href: "/docs", variant: variant) { variant.to_s }
    end
  end

  %i[sm md lg xl].each do |size|
    scenario "size_#{size}" do
      RubyUI.Link(href: "/docs", size: size) { size.to_s }
    end
  end

  scenario "icon" do
    RubyUI.Link(href: "/docs", icon: true) { "X" }
  end
end

Golden::Catalog.component "masked_input" do
  scenario "default" do
    RubyUI.MaskedInput(name: "phone", data: {ruby_ui__masked_input_mask_value: "(00) 00000-0000"})
  end
end

Golden::Catalog.component "message" do
  scenario "group_with_avatar_header_footer" do
    RubyUI.MessageGroup do
      RubyUI.Message do
        RubyUI.MessageAvatar { RubyUI.Avatar { RubyUI.AvatarFallback { "OL" } } }
        RubyUI.MessageContent do
          RubyUI.MessageHeader { "Oliver" }
          RubyUI.Bubble { RubyUI.BubbleContent { "Hi" } }
          RubyUI.MessageFooter { "Delivered" }
        end
      end
      RubyUI.Message(align: :end) do
        RubyUI.MessageContent { RubyUI.Bubble(align: :end) { RubyUI.BubbleContent { "Hey" } } }
      end
    end
  end
end

Golden::Catalog.component "message_scroller" do
  scenario "default" do
    RubyUI.MessageScrollerProvider do
      RubyUI.MessageScroller do
        RubyUI.MessageScrollerViewport do
          RubyUI.MessageScrollerContent do
            RubyUI.MessageScrollerItem(message_id: "m1") { "first" }
            RubyUI.MessageScrollerItem(scroll_anchor: true, message_id: "m2") { "last" }
          end
        end
        RubyUI.MessageScrollerButton
      end
    end
  end

  scenario "provider_custom_values" do
    RubyUI.MessageScrollerProvider(
      auto_scroll: false,
      previous_item_peek: 32,
      default_position: :last_anchor,
      preserve_on_prepend: false
    ) { "x" }
  end

  scenario "button_start" do
    RubyUI.MessageScrollerButton(direction: :start)
  end
end

Golden::Catalog.component "native_select" do
  scenario "default" do
    RubyUI.NativeSelect(name: "country") do
      RubyUI.NativeSelectOption(value: "") { "Select a country" }
      RubyUI.NativeSelectGroup(label: "Americas") do
        RubyUI.NativeSelectOption(value: "br", selected: true) { "Brazil" }
        RubyUI.NativeSelectOption(value: "us") { "United States" }
      end
    end
  end

  scenario "small" do
    RubyUI.NativeSelect(size: :sm, name: "country") do
      RubyUI.NativeSelectOption(value: "br") { "Brazil" }
    end
  end

  scenario "icon" do
    RubyUI.NativeSelectIcon
  end
end

Golden::Catalog.component "pagination" do
  scenario "default" do
    RubyUI.Pagination do
      RubyUI.PaginationContent do
        RubyUI.PaginationItem(href: "/page/1") { "Prev" }
        RubyUI.PaginationEllipsis
        RubyUI.PaginationItem(href: "/page/4") { "4" }
        RubyUI.PaginationItem(href: "/page/5", active: true) { "5" }
        RubyUI.PaginationEllipsis
        RubyUI.PaginationItem(href: "/page/6") { "Next" }
      end
    end
  end
end

Golden::Catalog.component "popover" do
  scenario "default" do
    RubyUI.Popover do
      RubyUI.PopoverTrigger(class: "w-full") { RubyUI.Button(variant: :outline) { "Open Popover" } }
      RubyUI.PopoverContent(class: "w-40") do
        RubyUI.Link(href: "/profile", variant: :ghost) { "Profile" }
      end
    end
  end

  scenario "with_options" do
    RubyUI.Popover(options: {trigger: "click", placement: "bottom-end"}) do
      RubyUI.PopoverTrigger { "T" }
    end
  end
end

Golden::Catalog.component "progress" do
  [0, 33.5, 100].each do |value|
    scenario "value_#{value.to_s.tr(".", "_")}" do
      RubyUI.Progress(value: value)
    end
  end
end

Golden::Catalog.component "radio_button" do
  scenario "default" do
    RubyUI.RadioButton(name: "plan", value: "pro")
  end

  scenario "checked" do
    RubyUI.RadioButton(name: "plan", value: "pro", checked: true)
  end
end

Golden::Catalog.component "select" do
  scenario "default" do
    RubyUI.Select do
      RubyUI.SelectInput(name: "person")
      RubyUI.SelectTrigger { RubyUI.SelectValue(placeholder: "Select a person") }
      RubyUI.SelectContent do
        RubyUI.SelectGroup do
          RubyUI.SelectLabel { "People" }
          RubyUI.SelectItem(value: 1) { "John Doe" }
          RubyUI.SelectItem(value: 2) { "Jane Doe" }
        end
      end
    end
  end

  scenario "value_falls_back_to_placeholder" do
    RubyUI.SelectValue(placeholder: "Placeholder") { nil }
  end
end

Golden::Catalog.component "separator" do
  scenario "default" do
    RubyUI.Separator
  end

  scenario "vertical" do
    RubyUI.Separator(orientation: :vertical)
  end

  scenario "not_decorative" do
    RubyUI.Separator(decorative: false)
  end

  scenario "as_hr" do
    RubyUI.Separator(as: :hr)
  end
end

Golden::Catalog.component "sheet" do
  scenario "default" do
    RubyUI.Sheet do
      RubyUI.SheetTrigger { RubyUI.Button(variant: :outline) { "Open Sheet" } }
      RubyUI.SheetContent(class: "sm:max-w-sm") do
        RubyUI.SheetHeader do
          RubyUI.SheetTitle { "Edit profile" }
          RubyUI.SheetDescription { "Make changes to your profile here." }
        end
        RubyUI.SheetMiddle { RubyUI.Input(name: "name") }
        RubyUI.SheetFooter { RubyUI.Button(type: "submit") { "Save" } }
      end
    end
  end

  %i[top right bottom left].each do |side|
    scenario "content_#{side}" do
      RubyUI.SheetContent(side: side) { "body" }
    end
  end

  scenario "open" do
    RubyUI.Sheet(open: true) { "content" }
  end
end

Golden::Catalog.component "shortcut_key" do
  scenario "default" do
    RubyUI.ShortcutKey do |key|
      key.span(class: "text-xs") { "Cmd" }
      key.plain "K"
    end
  end
end

Golden::Catalog.component "sidebar" do
  scenario "collapsible_offcanvas" do
    RubyUI.SidebarWrapper do
      RubyUI.Sidebar do
        RubyUI.SidebarHeader do
          RubyUI.SidebarGroup do
            RubyUI.SidebarGroupContent { RubyUI.SidebarInput(id: "search", placeholder: "Search the docs") }
          end
        end
        RubyUI.SidebarContent do
          RubyUI.SidebarGroup do
            RubyUI.SidebarGroupLabel { "Application" }
            RubyUI.SidebarGroupAction { "Add" }
            RubyUI.SidebarGroupContent do
              RubyUI.SidebarMenu do
                RubyUI.SidebarMenuItem do
                  RubyUI.SidebarMenuButton(as: :a, href: "/settings", active: true) { "Settings" }
                  RubyUI.SidebarMenuAction(show_on_hover: true) { "More" }
                  RubyUI.SidebarMenuBadge { "3" }
                  RubyUI.SidebarMenuSub do
                    RubyUI.SidebarMenuSubItem do
                      RubyUI.SidebarMenuSubButton(as: :a, href: "/settings/team") { "Team" }
                    end
                  end
                end
                RubyUI.SidebarMenuItem { RubyUI.SidebarMenuSkeleton(show_icon: true) }
                RubyUI.SidebarMenuItem { RubyUI.SidebarMenuSkeleton }
              end
            end
          end
          RubyUI.SidebarSeparator
        end
        RubyUI.SidebarFooter { "Footer" }
        RubyUI.SidebarRail
      end
      RubyUI.SidebarInset { RubyUI.SidebarTrigger }
    end
  end

  scenario "non_collapsible" do
    RubyUI.SidebarWrapper do
      RubyUI.Sidebar(collapsible: :none) { RubyUI.SidebarContent { "Body" } }
    end
  end

  scenario "collapsible_icon_right_floating" do
    RubyUI.Sidebar(side: :right, variant: :floating, collapsible: :icon, open: false) do
      RubyUI.SidebarContent { "Body" }
    end
  end

  scenario "mobile" do
    RubyUI.MobileSidebar(side: :right) { "Body" }
  end
end

Golden::Catalog.component "skeleton" do
  scenario "default" do
    RubyUI.Skeleton(class: "w-14 h-14")
  end
end

Golden::Catalog.component "switch" do
  scenario "default" do
    RubyUI.Switch(name: "notifications")
  end

  scenario "checked_without_hidden_input" do
    RubyUI.Switch(name: "notifications", include_hidden: false, checked: true, checked_value: "yes", unchecked_value: "no")
  end
end

Golden::Catalog.component "table" do
  scenario "default" do
    RubyUI.Table do
      RubyUI.TableCaption { "Employees at Acme inc." }
      RubyUI.TableHeader do
        RubyUI.TableRow do
          RubyUI.TableHead { "Name" }
          RubyUI.TableHead(class: "text-right") { "Amount" }
        end
      end
      RubyUI.TableBody do
        RubyUI.TableRow do
          RubyUI.TableCell(class: "font-medium") { "INV-0001" }
          RubyUI.TableCell(class: "text-right") { "100" }
        end
      end
      RubyUI.TableFooter do
        RubyUI.TableRow do
          RubyUI.TableHead(colspan: 1) { "Total" }
          RubyUI.TableHead(class: "text-right") { "100" }
        end
      end
    end
  end

  # A bare <tr> is exactly the fragment an "in body" HTML5 parse would throw
  # away; it is recorded here to keep the <template> parse context honest.
  scenario "detached_row" do
    RubyUI.TableRow { RubyUI.TableCell { "detached" } }
  end
end

Golden::Catalog.component "tabs" do
  scenario "default" do
    RubyUI.Tabs(default: "account", class: "w-96") do
      RubyUI.TabsList do
        RubyUI.TabsTrigger(value: "account") { "Account" }
        RubyUI.TabsTrigger(value: "password", as: :a, href: "#password") { "Password" }
      end
      RubyUI.TabsContent(value: "account") { "Account panel" }
      RubyUI.TabsContent(value: "password") { "Password panel" }
    end
  end
end

Golden::Catalog.component "textarea" do
  scenario "default" do
    RubyUI.Textarea(name: "bio", placeholder: "Tell us about yourself")
  end

  scenario "rows_and_content" do
    RubyUI.Textarea(name: "bio", rows: 8) { "existing content" }
  end
end

Golden::Catalog.component "theme_toggle" do
  scenario "default" do
    RubyUI.ThemeToggle { "T" }
  end
end

Golden::Catalog.component "toast" do
  scenario "region_with_flash" do
    RubyUI.ToastRegion(flash: {"notice" => "Saved", "alert" => "Careful"})
  end

  scenario "region_top_center_with_close_button" do
    RubyUI.ToastRegion(
      position: :top_center,
      expand: true,
      max: 5,
      duration: 8000,
      theme: :dark,
      rich_colors: true,
      close_button: true,
      hotkey: %w[ctrl shift t],
      dir: :rtl
    )
  end

  scenario "item_with_all_slots" do
    RubyUI.ToastRegion do
      RubyUI.ToastItem(variant: :error, id: "t1", duration: 6000, dismissible: false, invert: true, on_dismiss: "log", on_auto_close: "log") do
        RubyUI.ToastIcon(variant: :error)
        RubyUI.ToastTitle { "Upload failed" }
        RubyUI.ToastDescription { "The file is too large." }
        RubyUI.ToastAction(label: "Retry", on: "retry")
        RubyUI.ToastCancel(label: "Dismiss")
        RubyUI.ToastClose
      end
    end
  end
end

Golden::Catalog.component "toggle" do
  scenario "default" do
    RubyUI.Toggle { "B" }
  end

  scenario "pressed_outline_with_name" do
    RubyUI.Toggle(pressed: true, name: "bold", value: "1", unpressed_value: "0", variant: :outline, size: :lg) { "B" }
  end

  scenario "disabled_small" do
    RubyUI.Toggle(disabled: true, size: :sm, wrapper: {class: "inline-flex"}) { "B" }
  end
end

Golden::Catalog.component "toggle_group" do
  scenario "single" do
    RubyUI.ToggleGroup(type: :single, name: "align", value: "right") do |group|
      group.ToggleGroupItem(value: "left") { "L" }
      group.ToggleGroupItem(value: "right") { "R" }
    end
  end

  scenario "multiple_outline_spaced_vertical" do
    RubyUI.ToggleGroup(type: :multiple, name: "fmt", value: %w[bold italic], variant: :outline, size: :sm, spacing: 2, orientation: :vertical) do |group|
      group.ToggleGroupItem(value: "bold") { "B" }
      group.ToggleGroupItem(value: "italic") { "I" }
      group.ToggleGroupItem(value: "underline") { "U" }
    end
  end

  scenario "disabled" do
    RubyUI.ToggleGroup(type: :multiple, name: "fmt", disabled: true) do |group|
      group.ToggleGroupItem(value: "bold") { "B" }
    end
  end
end

Golden::Catalog.component "tooltip" do
  scenario "default" do
    RubyUI.Tooltip do
      RubyUI.TooltipTrigger { RubyUI.Button(variant: :outline, icon: true) { "?" } }
      RubyUI.TooltipContent { "Add to library" }
    end
  end

  scenario "placement_right" do
    RubyUI.Tooltip(placement: "right") { RubyUI.TooltipContent { "Tip" } }
  end
end

Golden::Catalog.component "typography" do
  (1..4).each do |level|
    scenario "heading_level_#{level}" do
      RubyUI.Heading(level: level.to_s) { "H#{level}" }
    end
  end

  scenario "heading_custom_size" do
    RubyUI.Heading(as: "h2", size: "7") { "Custom Heading" }
  end

  (1..9).each do |size|
    scenario "text_size_#{size}" do
      RubyUI.Text(size: size.to_s) { "Size #{size}" }
    end
  end

  %w[light regular medium bold].each do |weight|
    scenario "text_weight_#{weight}" do
      RubyUI.Text(weight: weight) { weight }
    end
  end

  %w[p span div label].each do |element|
    scenario "text_as_#{element}" do
      RubyUI.Text(as: element) { element }
    end
  end

  scenario "inline_code" do
    RubyUI.InlineCode { "RubyUI::VERSION" }
  end

  scenario "inline_link" do
    RubyUI.InlineLink(href: "/docs") { "the docs" }
  end

  scenario "blockquote" do
    RubyUI.TypographyBlockquote { "After all, we are all Rubyists." }
  end
end
