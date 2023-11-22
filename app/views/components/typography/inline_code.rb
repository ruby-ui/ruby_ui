# frozen_string_literal: true

class Typography::InlineCode < ApplicationComponent
  def template(&)
    code(class: "relative rounded bg-muted-background px-[0.3rem] py-[0.2rem] font-mono text-sm font-semibold", &)
  end
end