# frozen_string_literal: true

module RubyUI
  class NativeSelectGroup < Base
    def view_template(&)
      optgroup(**attrs, &)
    end

    private

    def default_attrs
      {}
    end
  end
end
