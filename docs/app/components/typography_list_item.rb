# frozen_string_literal: true

class Components::TypographyListItem < Components::Base
  def view_template(&)
    li(**attrs, &)
  end

  private

  def default_attrs
    {
      class: "leading-7"
    }
  end
end
