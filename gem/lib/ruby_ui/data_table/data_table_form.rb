# frozen_string_literal: true

module RubyUI
  class DataTableForm < Component
    def initialize(action: "", method: "post", id: nil, **attrs)
      @action = action
      @method = method
      @id = id
      super(**attrs)
    end

    # The form's own attributes first, the caller's after — a caller's key wins,
    # as it did through 1.6's keyword splat.
    def form_attrs
      form = {action: @action, method: @method}
      form[:id] = @id if @id
      Attributes.flat(form.merge(mixed_attrs))
    end

    # In a Rails request the view context answers form_authenticity_token.
    # Outside one (the gem's tests) it does not, and the placeholder is what
    # the golden snapshots recorded.
    def csrf_token
      helpers.respond_to?(:form_authenticity_token) ? helpers.form_authenticity_token : "csrf-token-placeholder"
    end

    def token_input_attrs
      Attributes.flat(type: "hidden", name: "authenticity_token", value: csrf_token)
    end
  end
end
