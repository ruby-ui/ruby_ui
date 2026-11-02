# frozen_string_literal: true

module RubyUI
  # An option of a Command. value: is what the search matches (the item's text
  # when omitted), keywords: adds more terms. Selecting it (click or Enter on
  # the active item) dispatches a cancelable `ruby-ui--command:select` event
  # and, unless prevented, visits href: when given (Turbo.visit when Turbo is
  # loaded). disabled: items can't be made active or selected.
  class CommandItem < Base
    def initialize(value: nil, keywords: [], href: nil, disabled: false, **attrs)
      @value = value
      @keywords = Array(keywords)
      @href = href
      @disabled = disabled
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        role: "option",
        aria: {selected: "false", disabled: (@disabled ? "true" : nil)},
        class: [
          "group/command-item relative flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-hidden select-none",
          "in-[dialog]:rounded-lg! data-selected:bg-muted data-selected:text-foreground data-selected:**:[svg]:text-foreground",
          "data-[disabled=true]:pointer-events-none data-[disabled=true]:opacity-50",
          "[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
        ],
        data: {
          slot: "command-item",
          value: @value,
          keywords: (@keywords.join(" ") if @keywords.any?),
          href: @href,
          disabled: (@disabled ? "true" : nil),
          ruby_ui__command_target: "item",
          action: "click->ruby-ui--command#itemClick pointermove->ruby-ui--command#itemPointermove"
        }
      }
    end
  end
end
