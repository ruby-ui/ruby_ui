# frozen_string_literal: true

class DocsController < ApplicationController
  layout -> { ApplicationLayout }

  def accordion
    render Docs::AccordionView.new
  end

  def alert_component # alert is a reserved word
    render Docs::AlertView.new
  end

  def alert_dialog
    render Docs::AlertDialogView.new
  end

  def aspect_ratio
    render Docs::AspectRatioView.new
  end

  def avatar
    render Docs::AvatarView.new
  end

  def badge
    render Docs::BadgeView.new
  end

  def button
    render Docs::ButtonView.new
  end

  def link
    render Docs::LinkView.new
  end

  def theme_toggle
    render Docs::ThemeToggleView.new
  end
  
  def typography
    render Docs::TypographyView.new
  end
end
