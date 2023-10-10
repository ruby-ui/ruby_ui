# frozen_string_literal: true

class Typography::P < ApplicationComponent
  def template(&)
    p(class: "leading-7 [&:not(:first-child)]:mt-6", &)
  end
end