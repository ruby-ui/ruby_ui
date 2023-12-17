# frozen_string_literal: true

class Chart < PhlexUI::Base
  def initialize(options: {}, **attrs)
    @options = options.to_json
    super(**attrs)
  end

  def template(&)
    canvas(**attrs, &)
  end

  private

  def default_attrs
    {
      data_controller: "chart",
      data_chart_options_value: @options
    }
  end
end