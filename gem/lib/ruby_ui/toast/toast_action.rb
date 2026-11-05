# frozen_string_literal: true

module RubyUI
  # Primary action: shadcn's ToastAction (Button outline, size sm). Clicking it
  # also closes the toast (registered divergence: Base UI leaves that to the
  # handler).
  class ToastAction < Base
    def initialize(label:, on: nil, **attrs)
      @label = label
      @on = on
      super(**attrs)
    end

    def view_template
      render RubyUI::Button.new(variant: :outline, size: :sm, **button_attrs) { @label }
    end

    private

    # slot! makes Button replace its own data-slot="button" instead of joining
    # it. Added after Base's mix, which would strip the bang.
    def button_attrs
      attrs.merge(data: attrs.fetch(:data, {}).merge(slot!: "toast-action"))
    end

    def default_attrs
      actions = [@on, "click->ruby-ui--toast#close"].compact
      {data: {action: actions.join(" ")}, class: "shrink-0"}
    end
  end
end
