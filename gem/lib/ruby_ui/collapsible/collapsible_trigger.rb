# frozen_string_literal: true

module RubyUI
  # The button that toggles its Collapsible. It is the <button> itself, with
  # aria-expanded and aria-controls, like shadcn's CollapsibleTrigger.
  #
  # Unstyled by default. Pass any Button option (variant:, size:, icon:) to
  # render it as a RubyUI Button (ghost unless variant: says otherwise), the
  # counterpart of shadcn's render={<Button variant="ghost" />}.
  class CollapsibleTrigger < Base
    def initialize(variant: nil, size: nil, icon: false, **attrs)
      @variant = variant
      @size = size
      @icon = icon
      super(**attrs)
    end

    def view_template(&)
      state = context[:ruby_ui_collapsible] || {}
      trigger_attrs = mix(attrs, state_attrs(state))
      disabled = state[:disabled] || trigger_attrs.delete(:disabled) || false

      if @variant || @size || @icon
        button = RubyUI::Button.new(variant: @variant || :ghost, size: @size || :md, icon: @icon,
          disabled: disabled, **trigger_attrs)
        # Button sets its own data-slot; mix would join the two.
        button.attrs[:data][:slot] = "collapsible-trigger"
        render(button, &)
      else
        trigger_attrs[:disabled] = true if disabled
        button(**trigger_attrs, &)
      end
    end

    private

    def state_attrs(state)
      {
        aria: {expanded: (state[:open] || false).to_s, controls: state[:content_id]},
        data: {panel_open: state[:open] || nil, disabled: state[:disabled] || nil}
      }
    end

    def default_attrs
      {
        type: :button,
        data: {
          slot: "collapsible-trigger",
          ruby_ui__collapsible_target: "trigger",
          action: "click->ruby-ui--collapsible#toggle"
        }
      }
    end
  end
end
