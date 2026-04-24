# frozen_string_literal: true

require "cgi"

module RubyUI
  class DataTableSortHead < Base
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

    def view_template
      render RubyUI::TableHead.new(class: "text-foreground whitespace-nowrap", **attrs) do
        a(href: sort_href, class: "inline-flex items-center gap-1 text-inherit no-underline hover:text-foreground transition-colors") do
          plain @label
          sort_icon
        end
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

    def sort_href
      qs = build_query(next_params)
      qs.empty? ? @path : "#{@path}?#{qs}"
    end

    def build_query(hash)
      hash.map { |k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join("&")
    end

    def sort_icon
      icon_name = case current_direction
      when "asc" then :chevron_up
      when "desc" then :chevron_down
      else :chevrons_up_down
      end
      icon_class = current_direction ? "inline-block w-3 h-3" : "inline-block w-3 h-3 opacity-30"
      render_sort_svg(icon_name, icon_class)
    end

    def render_sort_svg(icon_name, icon_class)
      case icon_name
      when :chevron_up
        # chevron-up: polyline pointing up
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          width: "12",
          height: "12",
          viewBox: "0 0 24 24",
          fill: "none",
          stroke: "currentColor",
          stroke_width: "2",
          stroke_linecap: "round",
          stroke_linejoin: "round",
          class: icon_class
        ) { |s| s.polyline(points: "18 15 12 9 6 15") }
      when :chevron_down
        # chevron-down: polyline pointing down
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          width: "12",
          height: "12",
          viewBox: "0 0 24 24",
          fill: "none",
          stroke: "currentColor",
          stroke_width: "2",
          stroke_linecap: "round",
          stroke_linejoin: "round",
          class: icon_class
        ) { |s| s.polyline(points: "6 9 12 15 18 9") }
      else
        # chevrons-up-down
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          width: "12",
          height: "12",
          viewBox: "0 0 24 24",
          fill: "none",
          stroke: "currentColor",
          stroke_width: "2",
          stroke_linecap: "round",
          stroke_linejoin: "round",
          class: icon_class
        ) do |s|
          s.polyline(points: "8 15 12 19 16 15")
          s.polyline(points: "8 9 12 5 16 9")
        end
      end
    end
  end
end
