# frozen_string_literal: true

class ErrorsController < ApplicationController
  layout -> { Views::Layouts::ErrorsLayout }

  def not_found
    render Views::Errors::NotFound.new, status: :not_found
  end

  def internal_server_error
    render Views::Errors::InternalServerError.new, status: :internal_server_error
  end
end
