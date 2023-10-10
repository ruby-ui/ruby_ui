# frozen_string_literal: true

class Typography::Blockquote < ApplicationComponent
  def template(&)
    blockquote(class: "mt-6 border-l-2 pl-6 italic", &)
  end
end