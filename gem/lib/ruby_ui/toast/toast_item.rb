# frozen_string_literal: true

module RubyUI
  # One toast. Mirrors shadcn's Base UI Toast (role=dialog, aria-modal=false,
  # named by its title and described by its description) and wraps the block
  # in Base UI's ToastContent row.
  #
  # on_dismiss / on_remove take Stimulus action descriptors ("undo#commit")
  # bound to the toast's own ruby-ui:toast:close / ruby-ui:toast:remove events,
  # so the named controller must be on the toast or an ancestor.
  class ToastItem < Base
    PRIORITIES = %i[low high].freeze
    REMOVED_KWARGS = %i[invert on_auto_close].freeze

    def initialize(
      variant: :default,
      id: nil,
      duration: nil,
      dismissible: true,
      priority: :low,
      on_dismiss: nil,
      on_remove: nil,
      **attrs
    )
      removed = attrs.keys & REMOVED_KWARGS
      unless removed.empty?
        raise ArgumentError, "RubyUI::ToastItem: #{removed.map { |k| "#{k}:" }.join(", ")} " \
          "#{(removed.size == 1) ? "was" : "were"} removed (it never had an effect). See the Toast changelog."
      end

      @variant = variant.to_sym
      @id = id
      @duration = duration
      @dismissible = dismissible
      @priority = priority.to_sym
      raise ArgumentError, "RubyUI::ToastItem: priority must be :low or :high" unless PRIORITIES.include?(@priority)

      @on_dismiss = on_dismiss
      @on_remove = on_remove
      super(**attrs)
    end

    def view_template(&)
      div(**attrs) do
        div(data: {slot: "toast-content"}, class: content_classes, &)
      end
    end

    private

    def default_attrs
      actions = []
      actions << "ruby-ui:toast:close->#{@on_dismiss}" if @on_dismiss
      actions << "ruby-ui:toast:remove->#{@on_remove}" if @on_remove
      data = {
        slot: "toast",
        type: @variant.to_s,
        variant: @variant.to_s,
        priority: @priority.to_s,
        state: "pending",
        swipe: "none",
        controller: "ruby-ui--toast",
        ruby_ui__toaster_target: "toast",
        ruby_ui__toast_dismissible_value: @dismissible.to_s
      }
      data[:action] = actions.join(" ") unless actions.empty?
      data[:ruby_ui__toast_duration_value] = @duration.to_s if @duration
      a = {
        role: (@priority == :high) ? "alertdialog" : "dialog",
        aria_modal: "false",
        tabindex: "0",
        data: data,
        class: item_classes
      }
      a[:id] = @id if @id
      a
    end

    # Base UI + vega toast root. The stacking transforms, heights and z-index
    # come from the toaster controller (inline styles), not CSS variables.
    def item_classes
      <<~CLASSES.tr("\n", " ").squeeze(" ").strip
        group/toast pointer-events-auto absolute inset-x-0 w-full
        rounded-2xl border bg-popover text-popover-foreground shadow-lg
        will-change-transform outline-none select-none
        focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50
        transition-[transform,opacity,height] duration-500 ease-[cubic-bezier(0.22,1,0.36,1)]
        motion-reduce:transition-none
        data-[swipe=move]:transition-none
        data-[state=pending]:[transform:translateY(150%)]
        in-data-[position^=top]:data-[state=pending]:[transform:translateY(-150%)]
        data-[limited]:opacity-0 data-[limited]:pointer-events-none
        after:absolute after:top-full after:left-0 after:h-[13px] after:w-full after:content-['']
        before:absolute before:bottom-full before:left-0 before:h-[13px] before:w-full before:content-['']
      CLASSES
    end

    def content_classes
      "flex h-full items-center gap-3 overflow-hidden p-4 transition-opacity duration-250 " \
        "ease-[cubic-bezier(0.22,1,0.36,1)] group-data-[behind]/toast:opacity-0"
    end
  end
end
