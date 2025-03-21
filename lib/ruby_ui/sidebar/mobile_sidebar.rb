# frozen_string_literal: true

module RubyUI
  class MobileSidebar < Base
    def view_template(&)
      div(**attrs) do
      end
    end

    private

    def default_attrs
      {}
    end
  end
end
