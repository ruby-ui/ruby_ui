# frozen_string_literal: true

module RubyUI
  class Table < Base
    def view_template(&block)
      div(class: "w-full overflow-auto") do
        table(**attrs, &block)
      end
    end

    private

    def default_attrs
      {
        class: "w-full caption-bottom text-sm"
      }
    end
  end
end
