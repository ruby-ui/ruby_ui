# frozen_string_literal: true

module RubyUI
  class Breadcrumb
    include ComponentBase

    private

    def default_attrs
      {aria: {label: "breadcrumb"}}
    end
  end
end
