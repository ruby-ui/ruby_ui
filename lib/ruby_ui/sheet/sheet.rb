# frozen_string_literal: true

module RubyUI
  class Sheet < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: { controller: 'ruby-ui--sheet' }
      }
    end
  end
end
