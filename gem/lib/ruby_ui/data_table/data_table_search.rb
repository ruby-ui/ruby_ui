# frozen_string_literal: true

module RubyUI
  class DataTableSearch < Component
    attr_reader :name, :value, :placeholder

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

    # 1.6 merged the form's own attributes over the caller's — a caller's
    # `data:` gave way to the controller wiring; `merge` in that direction.
    def form_attrs
      Attributes.flat(mixed_attrs.merge(method: "get", action: @path, data: form_data))
    end

    # [name, value] for the hidden inputs that carry the other query parameters
    # through a search. Blank values and the search parameter itself are
    # skipped, as in 1.6.
    def preserved_inputs
      @preserved_params.filter_map do |key, value|
        next if value.nil? || (value.respond_to?(:empty?) && value.empty?)
        next if key.to_s == @name

        [key.to_s, value.to_s]
      end
    end

    def hidden_input_attrs(name, value)
      Attributes.flat(type: "hidden", name: name, value: value)
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
