# frozen_string_literal: true

module RubyUI
  class FormField < Base
    # shadcn targets Base UI's role=checkbox/radio buttons; RubyUI's are native inputs.
    ORIENTATIONS = {
      vertical: "flex-col *:w-full [&>.sr-only]:w-auto",
      horizontal: [
        "flex-row items-center has-[>[data-slot=field-content]]:items-start *:data-[slot=field-label]:flex-auto",
        "has-[>[data-slot=field-content]]:[&>input[type=checkbox],&>input[type=radio]]:mt-px"
      ].join(" "),
      responsive: [
        "flex-col *:w-full [&>.sr-only]:w-auto",
        "@md/field-group:flex-row @md/field-group:items-center @md/field-group:*:w-auto",
        "@md/field-group:has-[>[data-slot=field-content]]:items-start @md/field-group:*:data-[slot=field-label]:flex-auto",
        "@md/field-group:has-[>[data-slot=field-content]]:[&>input[type=checkbox],&>input[type=radio]]:mt-px"
      ].join(" ")
    }.freeze

    def initialize(orientation: :vertical, **user_attrs)
      @orientation = orientation.to_sym
      raise ArgumentError, "orientation must be one of #{ORIENTATIONS.keys.join(", ")}" unless ORIENTATIONS.key?(@orientation)

      super(**user_attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        role: "group",
        data: {
          slot: "field",
          controller: "ruby-ui--form-field",
          orientation: @orientation
        },
        class: [
          "group/field flex w-full gap-3 data-[invalid=true]:text-destructive",
          ORIENTATIONS[@orientation]
        ]
      }
    end
  end
end
