# frozen_string_literal: true

class PagesController < ApplicationController
  layout -> { ApplicationLayout }
  
  def home
    render Pages::HomeView.new
  end
end
