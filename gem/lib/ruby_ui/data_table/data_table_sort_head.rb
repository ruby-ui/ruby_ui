# frozen_string_literal: true

require "cgi"

module RubyUI
  class DataTableSortHead < Component
    attr_reader :label

    def initialize(column_key:, label:, sort: nil, direction: nil, sort_param: "sort", direction_param: "direction", page_param: "page", path: "", query: {}, **attrs)
      @column_key = column_key
      @label = label
      @sort = sort
      @direction = direction
      @sort_param = sort_param
      @direction_param = direction_param
      @page_param = page_param
      @path = path
      @query = query.to_h.transform_keys(&:to_s)
      super(**attrs)
    end

    def sort_href
      qs = build_query(next_params)
      qs.empty? ? @path : "#{@path}?#{qs}"
    end

    # Through Attributes.flat, so the href keeps Phlex's guard: a path that
    # decodes to javascript: is dropped, not written.
    def anchor_attrs
      Attributes.flat(href: sort_href, class: "inline-flex items-center gap-1 text-inherit no-underline hover:text-foreground transition-colors")
    end

    def icon_class
      current_direction ? "inline-block w-3 h-3" : "inline-block w-3 h-3 opacity-30"
    end

    # The lucide polylines: chevron-up, chevron-down, or chevrons-up-down.
    def icon_points
      case current_direction
      when "asc" then ["18 15 12 9 6 15"]
      when "desc" then ["6 9 12 15 18 9"]
      else ["8 15 12 19 16 15", "8 9 12 5 16 9"]
      end
    end

    private

    def current_direction
      (@sort.to_s == @column_key.to_s) ? @direction : nil
    end

    def next_params
      next_dir = {nil => "asc", "asc" => "desc", "desc" => nil}[current_direction]
      base = @query.except(@sort_param, @direction_param, @page_param)
      next_dir ? base.merge(@sort_param => @column_key.to_s, @direction_param => next_dir) : base
    end

    def build_query(hash)
      hash.flat_map { |k, v|
        Array(v).map { |val| "#{CGI.escape(k.to_s)}=#{CGI.escape(val.to_s)}" }
      }.join("&")
    end
  end
end
