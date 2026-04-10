# frozen_string_literal: true

module RubyUI
  class AlertDialogHeader
    include ComponentBase

    private

    def default_attrs
      {class: "flex flex-col space-y-2 text-center sm:text-left rtl:sm:text-right"}
    end
  end
end
