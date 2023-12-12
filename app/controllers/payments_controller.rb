# frozen_string_literal: true

class PaymentsController < ApplicationController
  layout -> { ApplicationLayout }
  skip_before_action :authenticate_user!, only: [:confirmation]
  
  def confirmation
    render Payments::ConfirmationView.new(user: Current.user)
  end
end
