# frozen_string_literal: true

module RubyUI
  class Combobox < Base
    def initialize(term: nil, **)
      @term = term
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
          action: "turbo:morph@window->ruby-ui--combobox#updateTriggerContent"
        }
      }
    end
  end
end
