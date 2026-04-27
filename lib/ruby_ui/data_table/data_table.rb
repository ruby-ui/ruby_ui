# frozen_string_literal: true

module RubyUI
  class DataTable < Base
    register_element :turbo_frame, tag: "turbo-frame"

    def initialize(id:, **attrs)
      @id = id
      super(**attrs)
    end

    def view_template(&block)
      turbo_frame(id: @id, target: "_top") do
        div(**attrs) do
          yield if block
        end
      end
    end

    private

    def default_attrs
      {
        class: "w-full space-y-4",
        data: {controller: "ruby-ui--data-table"}
      }
    end
  end
end
