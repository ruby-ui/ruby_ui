# frozen_string_literal: true

require "cgi"
require_relative "../data_table_pagination_adapters/manual"
require_relative "../data_table_pagination_adapters/pagy"
require_relative "../data_table_pagination_adapters/kaminari"

module RubyUI
  class DataTablePagination < Base
    def initialize(with: nil, pagy: nil, kaminari: nil, page: nil, per_page: nil, total_count: nil, page_param: "page", path: "", query: {}, window: 1, **attrs)
      @adapter = resolve_adapter(with:, pagy:, kaminari:, page:, per_page:, total_count:)
      @page_param = page_param
      @path = path
      @query = query.to_h.transform_keys(&:to_s)
      @window = window
      super(**attrs)
    end

    def view_template
      render RubyUI::Pagination.new(class: "mx-0 w-auto justify-end", **attrs) do
        render RubyUI::PaginationContent.new do
          prev_item
          number_items
          next_item
        end
      end
    end

    private

    def resolve_adapter(with:, pagy:, kaminari:, page:, per_page:, total_count:)
      return with if with
      return RubyUI::DataTablePaginationAdapters::Pagy.new(pagy) if pagy
      return RubyUI::DataTablePaginationAdapters::Kaminari.new(kaminari) if kaminari
      if page && per_page && total_count
        return RubyUI::DataTablePaginationAdapters::Manual.new(page:, per_page:, total_count:)
      end
      raise ArgumentError, "DataTablePagination requires one of: with:, pagy:, kaminari:, or page:+per_page:+total_count:"
    end

    def current = @adapter.current_page

    def total = @adapter.total_pages

    def page_href(p)
      qs = build_query(@query.merge(@page_param => p.to_s))
      qs.empty? ? @path : "#{@path}?#{qs}"
    end

    def build_query(hash)
      hash.map { |k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join("&")
    end

    def prev_item
      if current <= 1
        li do
          span(class: "opacity-50 pointer-events-none px-3 h-9 inline-flex items-center text-sm") { plain "Previous" }
        end
      else
        render RubyUI::PaginationItem.new(href: page_href(current - 1)) { plain "Previous" }
      end
    end

    def next_item
      if current >= total
        li do
          span(class: "opacity-50 pointer-events-none px-3 h-9 inline-flex items-center text-sm") { plain "Next" }
        end
      else
        render RubyUI::PaginationItem.new(href: page_href(current + 1)) { plain "Next" }
      end
    end

    def number_items
      windowed_pages.each do |p|
        if p == :gap
          render RubyUI::PaginationEllipsis.new
        else
          render RubyUI::PaginationItem.new(href: page_href(p), active: p == current) { plain p.to_s }
        end
      end
    end

    def windowed_pages
      return (1..total).to_a if total <= 7
      pages = [1]
      pages << :gap if current - @window > 2
      ((current - @window)..(current + @window)).each { |p| pages << p if p > 1 && p < total }
      pages << :gap if current + @window < total - 1
      pages << total
      pages
    end
  end
end
