# frozen_string_literal: true

class ComponentsController < ApplicationController
  layout -> { ApplicationLayout }
  
  def typography
    render Components::TypographyView.new
  end
end
