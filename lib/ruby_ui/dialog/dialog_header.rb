# frozen_string_literal: true

module RubyUI
  class DialogHeader
    include ComponentBase

    private

    def default_attrs
      {
        class: "flex flex-col space-y-1.5 text-center sm:text-left rtl:sm:text-right"
      }
    end
  end
end
