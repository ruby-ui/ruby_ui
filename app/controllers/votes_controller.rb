# frozen_string_literal: true

class VotesController < ApplicationController
  layout -> { ApplicationLayout }

  def index
    render Votes::IndexView.new
  end
  
  # POST votes/:component_slug/toggle
  def toggle
    @vote = Vote.find_or_initialize_by(component_slug: params[:component_slug], user_id: Current.user.id)
    @vote.destroy if @vote.persisted?
    @vote.save if @vote.new_record?
    redirect_to votes_path
  end
end
