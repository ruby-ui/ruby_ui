# frozen_string_literal: true

module Views
  class Base < Phlex::HTML
    def Heading(level:, &)
      tag = :"h#{level}"
      send(tag, &)
    end

    def component_files(component_name)
      []
    end
  end
end
