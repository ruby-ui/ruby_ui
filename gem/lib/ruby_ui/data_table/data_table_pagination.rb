# frozen_string_literal: true

require "cgi"
require_relative "data_table_manual_adapter"
require_relative "data_table_pagy_adapter"
require_relative "data_table_kaminari_adapter"

module RubyUI
  class DataTablePagination < Component
    attr_reader :prev_label, :next_label

    def initialize(with: nil, pagy: nil, kaminari: nil, page: nil, per_page: nil, total_count: nil, page_param: "page", path: "", query: {}, window: 1, prev_label: "<", next_label: ">", **attrs)
      @adapter = resolve_adapter(with:, pagy:, kaminari:, page:, per_page:, total_count:)
      @page_param = page_param
      @path = path
      @query = query.to_h.transform_keys(&:to_s)
      @window = window
      @prev_label = prev_label
      @next_label = next_label
      super(**attrs)
    end

    # 1.6 returned before rendering anything for a single page.
    def paginate?
      total > 1
    end

    def current = @adapter.current_page

    def total = @adapter.total_pages

    def page_href(p)
      qs = build_query(@query.merge(@page_param => p.to_s))
      qs.empty? ? @path : "#{@path}?#{qs}"
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

    private

    def resolve_adapter(with:, pagy:, kaminari:, page:, per_page:, total_count:)
      return with if with
      return RubyUI::DataTablePagyAdapter.new(pagy) if pagy
      return RubyUI::DataTableKaminariAdapter.new(kaminari) if kaminari
      if page && per_page && total_count
        return RubyUI::DataTableManualAdapter.new(page:, per_page:, total_count:)
      end
      raise ArgumentError, "DataTablePagination requires one of: with:, pagy:, kaminari:, or page:+per_page:+total_count:"
    end

    def build_query(hash)
      hash.flat_map { |k, v|
        Array(v).map { |val| "#{CGI.escape(k.to_s)}=#{CGI.escape(val.to_s)}" }
      }.join("&")
    end
  end
end
