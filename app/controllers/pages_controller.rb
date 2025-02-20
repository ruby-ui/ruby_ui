# frozen_string_literal: true

class PagesController < ApplicationController
  layout -> { PagesLayout }

  def home
    render Views::Pages::Home.new
  end
end
