# frozen_string_literal: true

require "securerandom"

module RubyUI
  class AlertDialogContent < Base
    SIZES = %i[default sm].freeze

    def initialize(size: :default, **attrs)
      raise ArgumentError, "size must be one of #{SIZES.join(", ")}" unless SIZES.include?(size.to_sym)

      @size = size.to_sym
      super(**attrs)
    end

    # Title and Description take their ids from the context; the children are
    # captured first so the <dialog> only references the ones that rendered.
    def view_template(&block)
      previous = context[:ruby_ui_alert_dialog]
      id = attrs[:id] || "ruby-ui-alert-dialog-#{SecureRandom.hex(4)}"
      names = context[:ruby_ui_alert_dialog] = {id: id}
      body = block ? capture(&block) : ""
      dialog(**dialog_attrs(id, names)) { raw(safe(body)) }
    ensure
      context[:ruby_ui_alert_dialog] = previous
    end

    private

    def dialog_attrs(id, names)
      aria = {}
      aria[:labelledby] = names[:labelledby] if names[:labelledby] && !author_aria?(:label, :labelledby)
      aria[:describedby] = names[:describedby] if names[:describedby] && !author_aria?(:describedby)
      (aria.empty? ? attrs : mix({aria: aria}, attrs)).merge(id: id)
    end

    def author_aria?(*keys)
      keys.any? { |key| attrs[:"aria_#{key}"] || attrs.dig(:aria, key) }
    end

    # No backdrop click action: an alert dialog only closes through its
    # buttons or Esc (APG alertdialog).
    def default_attrs
      {
        role: "alertdialog",
        data: {
          ruby_ui__alert_dialog_target: "dialog",
          size: @size
        },
        class: [
          "group/alert-dialog-content fixed open:grid top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 z-50 w-full gap-6 rounded-xl bg-popover p-6 text-popover-foreground outline-none ring-1 ring-foreground/10 data-[size=default]:max-w-xs data-[size=sm]:max-w-xs data-[size=default]:sm:max-w-lg",
          "backdrop:bg-black/10 supports-backdrop-filter:backdrop:backdrop-blur-xs",
          "duration-100 data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95 data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95 data-[state=closed]:fill-mode-forwards motion-reduce:animate-none!",
          "backdrop:duration-100 data-[state=open]:backdrop:animate-in data-[state=open]:backdrop:fade-in-0 data-[state=closed]:backdrop:animate-out data-[state=closed]:backdrop:fade-out-0 data-[state=closed]:backdrop:fill-mode-forwards motion-reduce:backdrop:animate-none!"
        ]
      }
    end
  end
end
