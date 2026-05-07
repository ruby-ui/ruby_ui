# frozen_string_literal: true

module RubyUI
  class DataTablePagyAdapter
    def initialize(pagy)
      @pagy = pagy
    end

    def current_page = @pagy.page

    def total_pages = @pagy.pages

    def total_count = @pagy.count

    def per_page = @pagy.items
  end
end
