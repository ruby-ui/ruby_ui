# frozen_string_literal: true

module RubyUI
  class DataTablePerPageSelect < Base
    def initialize(path:, name: "per_page", value: nil, frame_id: nil, options: [5, 10, 25, 50], **attrs)
      @path = path
      @name = name
      @value = value
      @frame_id = frame_id
      @options = options
      super(**attrs)
    end

    def view_template
      form_attrs = {action: @path, method: "get"}
      form_attrs[:data] = {turbo_frame: @frame_id} if @frame_id

      form(**mix(attrs, form_attrs)) do
        render RubyUI::NativeSelect.new(name: @name, data: select_data) do
          @options.each do |opt|
            option_attrs = {value: opt.to_s}
            option_attrs[:selected] = true if opt.to_s == @value.to_s
            option(**option_attrs) { plain opt.to_s }
          end
        end
      end
    end

    private

    def select_data
      {
        controller: "ruby-ui--data-table-per-page-select",
        action: "change->ruby-ui--data-table-per-page-select#submit"
      }
    end

    def default_attrs
      {}
    end
  end
end
