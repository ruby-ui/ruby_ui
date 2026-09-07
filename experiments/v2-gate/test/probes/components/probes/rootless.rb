module Probes
  # Renders nothing under a condition: DataTablePagination with total <= 1.
  class Rootless < RubyUI::Base
    def initialize(total:, **attrs)
      @total = total
      super(**attrs)
    end

    def render?
      @total > 1
    end
  end
end
