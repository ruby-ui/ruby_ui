# frozen_string_literal: true

class Typography::Muted < ApplicationComponent
  def template(&)
    p(class: "text-sm text-muted-foreground", &)
  end
end