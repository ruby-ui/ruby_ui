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
          action: %w[
            turbo:morph@window->ruby-ui--combobox#updateTriggerContent
            keydown.down->ruby-ui--combobox#keyDownPressed
            keydown.up->ruby-ui--combobox#keyUpPressed
            keydown.enter->ruby-ui--combobox#keyEnterPressed
            keydown.esc->ruby-ui--combobox#closePopover:prevent
          ]
        }
      }
    end
  end
end
