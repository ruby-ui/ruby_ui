# frozen_string_literal: true

module RubyUI
  class Combobox
    include ComponentBase

    def initialize(term: nil, **attrs)
      @term = term
      super(**attrs)
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
