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
          ruby_ui__toaster_target: "toast",
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
        group/toast pointer-events-auto absolute left-0 right-0
        flex w-[356px] max-w-full items-center gap-1.5
        rounded-lg border bg-popover text-popover-foreground
        border-border p-4 text-[13px] shadow-[0_4px_12px_rgba(0,0,0,0.1)]
        group-data-[close-button=true]/toaster:pr-10
        transition-[transform,opacity] duration-300 ease-out
        will-change-transform
        opacity-[var(--opacity,1)]
        data-[state=pending]:opacity-0
        data-[state=closing]:opacity-0
        data-[swipe=move]:transition-none
      CLASSES
    end
  end
end
