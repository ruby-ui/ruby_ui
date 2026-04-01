# frozen_string_literal: true

module RubyUI
  class Select < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          controller: 'ruby-ui--select',
          ruby_ui__select_open_value: 'false',
          action: 'click@window->ruby-ui--select#clickOutside',
          ruby_ui__select_ruby_ui__select_item_outlet: '.item'
        },
        class: 'group/select w-full relative'
      }
    end
  end
end
