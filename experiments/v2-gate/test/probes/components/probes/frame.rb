module Probes
  # A custom element as root: DataTable's <turbo-frame>.
  class Frame < RubyUI::Base
    private

    def default_attrs
      {data: {controller: "ruby-ui--data-table"}}
    end
  end
end
