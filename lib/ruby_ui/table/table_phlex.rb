# frozen_string_literal: true

module RubyUI
  class Table < Base
    def view_template(&)
      div(class: "relative w-full overflow-auto") do
        table(**attrs, &)
      end
    end

    private

    def default_attrs
      {class: "w-full caption-bottom text-sm"}
    end
  end
end
