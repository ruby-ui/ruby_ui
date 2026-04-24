# frozen_string_literal: true

module RubyUI
  module DataTablePaginationAdapters
    class Manual
      attr_reader :current_page, :per_page, :total_count

      def initialize(page:, per_page:, total_count:)
        @current_page = page.to_i
        @per_page = [per_page.to_i, 1].max
        @total_count = total_count.to_i
      end

      def total_pages
        [(@total_count.to_f / @per_page).ceil, 1].max
      end
    end
  end
end
