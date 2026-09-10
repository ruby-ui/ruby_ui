# frozen_string_literal: true

module RubyUI
  class DrawerFooter < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "mt-auto flex flex-col gap-2 border-t p-4 pb-[calc(1rem_+_env(safe-area-inset-bottom))]"
      }
    end
  end
end
