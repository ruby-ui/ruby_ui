# frozen_string_literal: true

module RubyUI
  class Combobox < Base
    def initialize(multiple: false, term: "items", **)
      @multiple = multiple
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
          ruby_ui__combobox_multiple_value: @multiple.to_s,
          ruby_ui__combobox_term_value: @term.to_s
        }
      }
    end
  end
end
