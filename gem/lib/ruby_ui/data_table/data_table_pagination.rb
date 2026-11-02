# frozen_string_literal: true

require "cgi"
require_relative "data_table_manual_adapter"
require_relative "data_table_pagy_adapter"
require_relative "data_table_kaminari_adapter"

module RubyUI
  class DataTablePagination < Base
    # Mirrors the footer of shadcn's data table block (dashboard-01): "Page X of Y"
    # plus first/previous/next/last icon buttons. They are links (Button href:),
    # so paging stays a plain GET that works without JS and inside Turbo Frames.
    LABELS = {
      first: "Go to first page",
      previous: "Go to previous page",
      next: "Go to next page",
      last: "Go to last page"
    }.freeze

    def initialize(with: nil, pagy: nil, kaminari: nil, page: nil, per_page: nil, total_count: nil, page_param: "page", path: "", query: {}, labels: {}, **attrs)
      @adapter = resolve_adapter(with:, pagy:, kaminari:, page:, per_page:, total_count:)
      @page_param = page_param
      @path = path
      @query = query.to_h.transform_keys(&:to_s)
      @labels = LABELS.merge(labels)
      super(**attrs)
    end

    def view_template
      return if total <= 1

      nav(**attrs) do
        div(class: "flex w-fit items-center justify-center text-sm font-medium") { plain "Page #{current} of #{total}" }
        div(class: "ml-auto flex items-center gap-2 lg:ml-0") do
          page_button(1, :first, disabled: current <= 1, class: "hidden lg:flex")
          page_button(current - 1, :previous, disabled: current <= 1)
          page_button(current + 1, :next, disabled: current >= total)
          page_button(total, :last, disabled: current >= total, class: "hidden lg:flex")
        end
      end
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

    def current = @adapter.current_page

    def total = @adapter.total_pages

    def page_href(p)
      qs = build_query(@query.merge(@page_param => p.to_s))
      qs.empty? ? @path : "#{@path}?#{qs}"
    end

    def build_query(hash)
      hash.flat_map { |k, v|
        Array(v).map { |val| "#{CGI.escape(k.to_s)}=#{CGI.escape(val.to_s)}" }
      }.join("&")
    end

    def page_button(page, kind, disabled:, **extra)
      render RubyUI::Button.new(
        href: page_href(page), variant: :outline, size: :sm, icon: true, disabled: disabled,
        class: ["aria-disabled:pointer-events-none aria-disabled:opacity-50", extra[:class]]
      ) do
        span(class: "sr-only") { plain @labels.fetch(kind) }
        chevron_icon(kind)
      end
    end

    # lucide chevrons-left, chevron-left, chevron-right, chevrons-right
    ICON_PATHS = {
      first: ["m11 17-5-5 5-5", "m18 17-5-5 5-5"],
      previous: ["m15 18-6-6 6-6"],
      next: ["m9 18 6-6-6-6"],
      last: ["m6 17 5-5-5-5", "m13 17 5-5-5-5"]
    }.freeze

    def chevron_icon(kind)
      svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor",
        stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true") do |s|
        ICON_PATHS.fetch(kind).each { |d| s.path(d: d) }
      end
    end

    def default_attrs
      {
        aria: {label: "pagination"},
        class: "flex w-full items-center gap-8 lg:w-fit"
      }
    end
  end
end
