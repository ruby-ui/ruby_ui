# frozen_string_literal: true

module Components
  module Steps
    class Container < Components::Base
      def view_template(&)
        div(class: "space-y-4", &)
      end
    end
  end
end
