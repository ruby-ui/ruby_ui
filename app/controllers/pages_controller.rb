# frozen_string_literal: true

class PagesController < ApplicationController
  layout -> { PagesLayout }
  skip_before_action :authenticate_user!
  
  def home
    render Pages::HomeView.new
  end
end
