# frozen_string_literal: true

module RubyUI
  class Table
    include ComponentBase

    private

    def default_attrs
      {class: "w-full caption-bottom text-sm"}
    end
  end
end
