# frozen_string_literal: true

class PagesController < ApplicationController
  layout -> { PagesLayout }
  skip_before_action :authenticate_user!
  
  def home
    render Pages::HomeView.new
  end

  def license
    render Pages::LicenseView.new
  end

  def support
    render Pages::SupportView.new
  end
end
