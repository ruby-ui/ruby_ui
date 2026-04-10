# frozen_string_literal: true

module RubyUI
  class TableBody
    include ComponentBase

    private

    def default_attrs
      {class: "[&_tr:last-child]:border-0"}
    end
  end
end
