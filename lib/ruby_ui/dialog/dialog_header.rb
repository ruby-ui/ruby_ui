# frozen_string_literal: true

module RubyUI
  class DialogHeader < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: 'flex flex-col space-y-1.5 text-center sm:text-left rtl:sm:text-right'
      }
    end
  end
end
