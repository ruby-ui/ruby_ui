# frozen_string_literal: true

module RubyUI
  # Secondary dismiss button (a RubyUI extra; shadcn's Toast has no cancel).
  class ToastCancel < Base
    def initialize(label:, **attrs)
      @label = label
      super(**attrs)
    end

    def view_template
      render RubyUI::Button.new(variant: :ghost, size: :sm, **button_attrs) { @label }
    end

    private

    # slot! makes Button replace its own data-slot="button" instead of joining
    # it. Added after Base's mix, which would strip the bang.
    def button_attrs
      attrs.merge(data: attrs.fetch(:data, {}).merge(slot!: "toast-cancel"))
    end

    def default_attrs
      {data: {action: "click->ruby-ui--toast#dismiss"}, class: "shrink-0"}
    end
  end
end
