class SigninsController < ApplicationController
    layout -> { AuthLayout }
    skip_before_action :authenticate_user!

    def new
        redirect_path = params[:redirect_path]
        render Signins::NewView.new(redirect_path: @redirect_path)
    end

    def create
        EmailAuth::EmailsLink.new(
            email: params[:email],
            redirect_path: params[:redirect_path]
        ).call

        flash[:notice] = "Check your email to sign in! (#{params[:email]})"
        redirect_to new_signin_path
    end
end
