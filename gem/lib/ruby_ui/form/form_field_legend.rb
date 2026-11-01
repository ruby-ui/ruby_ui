# frozen_string_literal: true

module RubyUI
  class FormFieldLegend < Base
    VARIANTS = %i[legend label].freeze

    def initialize(variant: :legend, **user_attrs)
      @variant = variant&.to_sym
      raise ArgumentError, "variant must be one of #{VARIANTS.join(", ")}" unless VARIANTS.include?(@variant)

      super(**user_attrs)
    end

    def view_template(&)
      legend(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "field-legend", variant: @variant},
        class: "mb-3 font-medium data-[variant=label]:text-sm data-[variant=legend]:text-base"
      }
    end
  end
end
