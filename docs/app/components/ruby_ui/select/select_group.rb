# frozen_string_literal: true

module RubyUI
  class SelectGroup < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {}
    end
  end
end
