# frozen_string_literal: true

module RubyUI
  class CalendarPrev < Base
    def view_template
      button(**attrs) do
        icon
      end
    end

    private

    def icon
      svg(
        width: '15',
        height: '15',
        viewbox: '0 0 15 15',
        fill: 'none',
        xmlns: 'http://www.w3.org/2000/svg',
        class: 'h-4 w-4'
      ) do |s|
        s.path(
          d:
                'M8.84182 3.13514C9.04327 3.32401 9.05348 3.64042 8.86462 3.84188L5.43521 7.49991L8.86462 11.1579C9.05348 11.3594 9.04327 11.6758 8.84182 11.8647C8.64036 12.0535 8.32394 12.0433 8.13508 11.8419L4.38508 7.84188C4.20477 7.64955 4.20477 7.35027 4.38508 7.15794L8.13508 3.15794C8.32394 2.95648 8.64036 2.94628 8.84182 3.13514Z',
          fill: 'currentColor',
          fill_rule: 'evenodd',
          clip_rule: 'evenodd'
        )
      end
    end

    def default_attrs
      {
        name: 'previous-month',
        aria_label: 'Go to previous month',
        class:
              'rdp-button_reset rdp-button inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 border border-input hover:bg-accent hover:text-accent-foreground h-7 w-7 bg-transparent p-0 opacity-50 hover:opacity-100 absolute left-1',
        type: 'button',
        data_action: 'click->ruby-ui--calendar#prevMonth'
      }
    end
  end
end
