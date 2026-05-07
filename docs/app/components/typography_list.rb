# frozen_string_literal: true

class Components::TypographyList < Components::Base
  def initialize(items: [], numbered: false, **attrs)
    @items = items
    @numbered = numbered
    super(**attrs)
  end

  def view_template(&)
    if @items.empty?
      list(**attrs, &)
    else
      list(**attrs) do
        @items.each do |item|
          TypographyListItem { item }
        end
      end
    end
  end

  private

  def list(**attrs, &)
    if numbered?
      ol(**attrs, &)
    else
      ul(**attrs, &)
    end
  end

  def numbered? = @numbered

  def default_attrs
    {
      class: [
        "my-6 ml-6 [&>li]:mt-2 [&>li]:pl-2",
        (numbered? ? "list-decimal marker:font-medium" : "list-disc")
      ]
    }
  end
end
