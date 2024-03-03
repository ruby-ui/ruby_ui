# frozen_string_literal: true

class ErrorsController < ApplicationController
  layout -> { ErrorsLayout }

  def not_found
    render Errors::NotFoundView.new, status: :not_found
  end

  def internal_server_error
    render Errors::InternalServerErrorView.new, status: :internal_server_error
  end
end
