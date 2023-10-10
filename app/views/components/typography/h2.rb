# frozen_string_literal: true

class Typography::H2 < ApplicationComponent
  def template(&)
    h2(class: "scroll-m-20 border-b pb-2 text-3xl font-semibold tracking-tight transition-colors first:mt-0", &)
  end
end
