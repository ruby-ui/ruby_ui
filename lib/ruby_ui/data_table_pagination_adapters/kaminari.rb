# frozen_string_literal: true

module RubyUI
  module DataTablePaginationAdapters
    class Kaminari
      def initialize(collection)
        @collection = collection
      end

      def current_page = @collection.current_page

      def total_pages = @collection.total_pages

      def total_count = @collection.total_count

      def per_page = @collection.limit_value
    end
  end
end
