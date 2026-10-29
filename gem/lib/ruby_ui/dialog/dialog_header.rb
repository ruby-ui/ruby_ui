# frozen_string_literal: true

module RubyUI
  class DialogHeader < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "flex flex-col gap-2"
      }
    end
  end
end
