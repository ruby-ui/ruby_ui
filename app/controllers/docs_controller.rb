# frozen_string_literal: true

class DocsController < ApplicationController
  layout -> { ApplicationLayout }

  def accordion
    render Docs::AccordionView.new
  end

  def alert_component # alert is a reserved word
    render Docs::AlertView.new
  end

  def link
    render Docs::LinkView.new
  end
  
  def typography
    render Docs::TypographyView.new
  end
end
