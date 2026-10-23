# frozen_string_literal: true

module RubyUI
  class DrawerHeader < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "flex flex-col gap-1.5 p-4 text-center sm:text-left"
      }
    end
  end
end
