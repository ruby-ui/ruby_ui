# frozen_string_literal: true

class DocsController < ApplicationController
  layout -> { ApplicationLayout }

  def link
    render Docs::LinkView.new
  end
  
  def typography
    render Docs::TypographyView.new
  end
end
