# frozen_string_literal: true

module RubyUI
  class DataTable < Component
    def initialize(id:, **attrs)
      @id = id
      super(**attrs)
    end

    # The frame's own attributes, serialized as Phlex did: a nil id is omitted,
    # a Symbol dasherizes.
    def frame_attrs
      Attributes.flat(id: @id, target: "_top")
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
