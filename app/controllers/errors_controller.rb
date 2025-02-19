# frozen_string_literal: true

class ErrorsController < ApplicationController
  layout -> { ErrorsLayout }

  def not_found
    render Views::Errors::NotFoundView.new, status: :not_found
  end

  def internal_server_error
    render Views::Errors::InternalServerErrorView.new, status: :internal_server_error
  end
end
