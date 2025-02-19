# frozen_string_literal: true

class PagesController < ApplicationController
  layout -> { PagesLayout }

  def home
    render Views::Pages::HomeView.new
  end
end
