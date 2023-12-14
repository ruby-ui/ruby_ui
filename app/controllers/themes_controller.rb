# frozen_string_literal: true

class ThemesController < ApplicationController
  layout -> { ApplicationLayout }
  skip_before_action :authenticate_user!, only: [:show]
  
  # GET /themes/:theme
  def show
    render Themes::ShowView.new(theme: params[:theme])
  end
end
