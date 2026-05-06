# frozen_string_literal: true

module RubyUI
  class DataTableSearch < Base
    def initialize(path:, name: "search", value: nil, frame_id: nil, placeholder: "Search...", debounce: 300, preserved_params: {}, **attrs)
      @path = path
      @name = name
      @value = value
      @frame_id = frame_id
      @placeholder = placeholder
      @debounce = debounce
      @preserved_params = preserved_params
      super(**attrs)
    end

    def view_template
      form_attrs = {method: "get", action: @path}
      form_attrs[:data] = form_data

      form(**attrs.merge(form_attrs)) do
        render RubyUI::Input.new(
          type: :search,
          name: @name,
          value: @value,
          placeholder: @placeholder,
          autocomplete: "off"
        )
        @preserved_params.each do |k, v|
          next if v.nil? || (v.respond_to?(:empty?) && v.empty?)
          next if k.to_s == @name
          input(type: "hidden", name: k.to_s, value: v.to_s)
        end
      end
    end

    private

    def debounce_enabled?
      @debounce && @debounce.to_i > 0
    end

    def form_data
      base = {}
      base[:turbo_frame] = @frame_id if @frame_id
      if debounce_enabled?
        base[:controller] = "ruby-ui--data-table-search"
        base[:"ruby-ui--data-table-search-delay-value"] = @debounce.to_i
        base[:action] = "input->ruby-ui--data-table-search#submit"
      end
      base
    end

    def default_attrs
      {class: "max-w-sm flex-1"}
    end
  end
end
