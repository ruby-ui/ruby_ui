# frozen_string_literal: true

module RubyUI
  # A callout for user attention. An icon placed as the first child sits in
  # its own grid column next to the title and description, like shadcn's Alert.
  # role="alert" makes screen readers announce it and interrupt the user. Pass
  # role: "status" to announce it politely, or role: nil for a static callout.
  class Alert < Base
    VARIANTS = {
      default: "bg-card text-card-foreground",
      destructive: "text-destructive bg-card *:data-[slot=alert-description]:text-destructive/90 *:[svg]:text-current",
      warning: "text-warning bg-card *:data-[slot=alert-description]:text-warning/90 *:[svg]:text-current",
      success: "text-success bg-card *:data-[slot=alert-description]:text-success/90 *:[svg]:text-current"
    }.freeze

    def initialize(variant: :default, **attrs)
      @variant = variant.to_s.to_sym
      @variant = :default unless VARIANTS.key?(@variant) # nil or unknown: default look

      super(**attrs) # must be called after variant is set
      # mix joins string attributes ("alert status") and ignores nil, so the
      # user's role replaces the default here, and nil removes it.
      if attrs.key?(:role)
        attrs[:role].nil? ? @attrs.delete(:role) : @attrs[:role] = attrs[:role]
      end
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "alert"},
        role: "alert",
        class: [
          "group/alert relative grid w-full gap-0.5 rounded-lg border px-4 py-3 text-left text-sm",
          "has-data-[slot=alert-action]:relative has-data-[slot=alert-action]:pr-18",
          "has-[>svg]:grid-cols-[auto_1fr] has-[>svg]:gap-x-2.5",
          "*:[svg]:row-span-2 *:[svg]:translate-y-0.5 *:[svg]:text-current *:[svg:not([class*='size-'])]:size-4",
          VARIANTS.fetch(@variant)
        ]
      }
    end
  end
end
