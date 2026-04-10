# frozen_string_literal: true

module RubyUI
  class TableHeader
    include ComponentBase

    private

    def default_attrs
      {class: "[&_tr]:border-b"}
    end
  end
end
