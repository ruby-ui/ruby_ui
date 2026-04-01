# frozen_string_literal: true

module RubyUI
  class AlertTitle < Base
    def view_template(&)
      h5(**attrs, &)
    end

    private

    def default_attrs
      {
        class: 'mb-1 font-medium leading-none tracking-tight'
      }
    end
  end
end
