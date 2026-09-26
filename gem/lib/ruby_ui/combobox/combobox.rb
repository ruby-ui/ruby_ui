# frozen_string_literal: true

module RubyUI
  class Combobox < Base
    def initialize(term: nil, placement: "bottom-start", **)
      @term = term
      @placement = placement
      super(**)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        role: "combobox",
        data: {
          controller: "ruby-ui--combobox",
          ruby_ui__combobox_term_value: @term,
          ruby_ui__combobox_placement_value: @placement,
          action: %w[
            turbo:morph@window->ruby-ui--combobox#updateTriggerContent
            click@window->ruby-ui--combobox#handleOutsideClick
            keydown.esc@window->ruby-ui--combobox#handleEscape
          ]
        }
      }
    end
  end
end
