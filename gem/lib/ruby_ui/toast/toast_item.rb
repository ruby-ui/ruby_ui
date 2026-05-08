# frozen_string_literal: true

module RubyUI
  class ToastItem < Base
    ALERT_VARIANTS = %i[error].freeze

    def initialize(
      variant: :default,
      id: nil,
      duration: nil,
      dismissible: true,
      invert: false,
      on_dismiss: nil,
      on_auto_close: nil,
      **attrs
    )
      @variant = variant.to_sym
      @id = id
      @duration = duration
      @dismissible = dismissible
      @invert = invert
      @on_dismiss = on_dismiss
      @on_auto_close = on_auto_close
      super(**attrs)
    end

    def view_template(&)
      li(**attrs, &)
    end

    private

    def default_attrs
      a = {
        role: ALERT_VARIANTS.include?(@variant) ? "alert" : "status",
        aria_atomic: "true",
        tabindex: "0",
        data: {
          variant: @variant.to_s,
          state: "pending",
          swipe: "none",
          controller: "ruby-ui--toast",
          ruby_ui__toast_dismissible_value: @dismissible.to_s,
          ruby_ui__toast_invert_value: @invert.to_s
        },
        class: item_classes
      }
      a[:id] = @id if @id
      a[:data][:ruby_ui__toast_duration_value] = @duration.to_s if @duration
      a[:data][:ruby_ui__toast_on_dismiss_value] = @on_dismiss if @on_dismiss
      a[:data][:ruby_ui__toast_on_auto_close_value] = @on_auto_close if @on_auto_close
      a
    end

    def item_classes
      <<~CLASSES.tr("\n", " ").squeeze(" ").strip
        group/toast pointer-events-auto relative flex w-[356px] max-w-full items-center gap-3
        overflow-hidden rounded-lg border bg-popover text-popover-foreground
        border-border p-4 pr-8 shadow-lg
        transition-all duration-200 ease-out
        will-change-transform
        translate-y-[var(--y-offset,0px)] scale-[var(--scale,1)] opacity-[var(--opacity,1)]
        data-[state=pending]:opacity-0 data-[state=pending]:translate-y-2
        data-[state=open]:animate-in data-[state=open]:fade-in-0
        data-[state=closing]:animate-out data-[state=closing]:fade-out-0
        data-[swipe=move]:transition-none
        data-[swipe=cancel]:translate-x-0
        data-[swipe=end]:translate-x-[var(--swipe-end-x,0)]
        data-[swipe=end]:translate-y-[var(--swipe-end-y,0)]
        data-[variant=success]:border-green-500/30
        data-[variant=error]:border-red-500/30
        data-[variant=warning]:border-yellow-500/30
        data-[variant=info]:border-blue-500/30
      CLASSES
    end
  end
end
