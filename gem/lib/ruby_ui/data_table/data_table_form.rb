# frozen_string_literal: true

module RubyUI
  class DataTableForm < Base
    def initialize(action: "", method: "post", id: nil, **attrs)
      @action = action
      @method = method
      @id = id
      super(**attrs)
    end

    def view_template(&block)
      form_attrs = {action: @action, method: @method}
      form_attrs[:id] = @id if @id
      form(**form_attrs, **attrs) do
        input(type: "hidden", name: "authenticity_token", value: csrf_token)
        yield if block
      end
    end

    private

    def csrf_token
      # In a Rails app, view_context provides a real CSRF token.
      # Outside Rails (gem tests), fall back to a placeholder.
      if respond_to?(:helpers, true) && helpers.respond_to?(:form_authenticity_token)
        helpers.form_authenticity_token
      elsif respond_to?(:view_context, true) && view_context.respond_to?(:form_authenticity_token)
        view_context.form_authenticity_token
      else
        "csrf-token-placeholder"
      end
    end

    def default_attrs
      {}
    end
  end
end
