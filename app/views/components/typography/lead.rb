# frozen_string_literal: true

class Typography::Lead < ApplicationComponent
  def template(&)
    p(class: "text-xl text-muted-foreground", &)
  end
end