# frozen_string_literal: true

module RubyUI
  class Sheet < Base
    def initialize(open: false, **attrs)
      @open = open
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    # `contents` keeps the Stimulus wrapper out of layout, like shadcn's
    # element-less Root.
    def default_attrs
      {
        data: {
          slot: "sheet",
          controller: "ruby-ui--sheet",
          ruby_ui__sheet_open_value: @open.to_s
        },
        class: "contents"
      }
    end
  end
end
