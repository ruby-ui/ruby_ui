# frozen_string_literal: true

class ThemesController < ApplicationController
  layout -> { ApplicationLayout }
  skip_before_action :authenticate_user!, only: [:index]
  
  def index
    render Themes::IndexView.new
  end
end
