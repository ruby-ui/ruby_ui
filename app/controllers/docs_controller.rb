# frozen_string_literal: true

class DocsController < ApplicationController
  layout -> { ApplicationLayout }
  
  def typography
    render Docs::TypographyView.new
  end
end
