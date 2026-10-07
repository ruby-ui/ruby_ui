# frozen_string_literal: true

module RubyUI
  class DataTablePerPageSelect < Component
    attr_reader :name, :options

    def initialize(path:, name: "per_page", value: nil, frame_id: nil, options: [5, 10, 25, 50], **attrs)
      @path = path
      @name = name
      @value = value
      @frame_id = frame_id
      @options = options
      super(**attrs)
    end

    def form_attrs
      form = {action: @path, method: "get"}
      form[:data] = {turbo_frame: @frame_id} if @frame_id
      Attributes.flat(mixed_attrs.merge(form))
    end

    def option_attrs(option)
      attributes = {value: option.to_s}
      attributes[:selected] = true if option.to_s == @value.to_s
      Attributes.flat(attributes)
    end

    # 1.6 passed the handler through Phlex's `safe`. NativeSelect is still
    # Phlex and refuses an `on*` attribute unless its value is a SafeObject;
    # the 2.0 Attributes has no such bypass, so this goes when NativeSelect
    # migrates and Phase 2.2 chooses between a bypass and a Stimulus action.
    def onchange
      Phlex::SGML::SafeValue.new("this.form.requestSubmit()")
    end
  end
end
