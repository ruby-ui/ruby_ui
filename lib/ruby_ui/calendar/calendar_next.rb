# frozen_string_literal: true

module RubyUI
  class CalendarNext < Base
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
                'M6.1584 3.13508C6.35985 2.94621 6.67627 2.95642 6.86514 3.15788L10.6151 7.15788C10.7954 7.3502 10.7954 7.64949 10.6151 7.84182L6.86514 11.8418C6.67627 12.0433 6.35985 12.0535 6.1584 11.8646C5.95694 11.6757 5.94673 11.3593 6.1356 11.1579L9.565 7.49985L6.1356 3.84182C5.94673 3.64036 5.95694 3.32394 6.1584 3.13508Z',
          fill: 'currentColor',
          fill_rule: 'evenodd',
          clip_rule: 'evenodd'
        )
      end
    end

    def default_attrs
      {
        name: 'next-month',
        aria_label: 'Go to next month',
        class:
              'inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 border border-input hover:bg-accent hover:text-accent-foreground h-7 w-7 bg-transparent p-0 opacity-50 hover:opacity-100 absolute right-1',
        type: 'button',
        data_action: 'click->ruby-ui--calendar#nextMonth'
      }
    end
  end
end
