# frozen_string_literal: true

module RubyUI
  class DataTablePerPageSelect < Base
    def initialize(path:, name: "per_page", value: nil, frame_id: nil, options: [5, 10, 25, 50], label: "Rows per page", id: nil, **attrs)
      @path = path
      @name = name
      @value = value
      @frame_id = frame_id
      @options = options
      @label = label
      # Unique by default, so two tables on one page keep their labels apart.
      @id = id || "data-table-per-page-#{SecureRandom.hex(4)}"
      super(**attrs)
    end

    def view_template
      form_attrs = {action: @path, method: "get"}
      form_attrs[:data] = {turbo_frame: @frame_id} if @frame_id
      form(**attrs.merge(form_attrs)) do
        label(for: @id, class: "text-sm font-medium") { plain @label }
        render RubyUI::NativeSelect.new(id: @id, name: @name, size: :sm, onchange: safe("this.form.requestSubmit()")) do
          @options.each do |opt|
            option_attrs = {value: opt.to_s}
            option_attrs[:selected] = true if opt.to_s == @value.to_s
            option(**option_attrs) { plain opt.to_s }
          end
        end
      end
    end

    private

    def default_attrs
      {class: "flex items-center gap-2"}
    end
  end
end
