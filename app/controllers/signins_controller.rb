class SigninsController < ApplicationController
    layout -> { AuthLayout }
    skip_before_action :authenticate_user!

    def new
        @redirect_path = params[:redirect_path] || request.referrer || root_path
        render Signins::NewView.new(redirect_path: @redirect_path)
    end

    def create
        EmailAuth::EmailsLink.new(
            email: params[:email],
            redirect_path: params[:redirect_path]
        ).call

        flash[:notice] = "Check your email to sign in!"
        redirect_to signin_check_your_email_path(email: params[:email])
    end

    def destroy
        reset_session
        flash[:notice] = "You have successfully logged out."
        redirect_to root_path
    end

    def check_your_email
        render Signins::CheckYourEmailView.new(email: params[:email])
    end

    def authenticate
        result = EmailAuth::ValidatesLoginAttempt.new.validate(params[:token])
        if result.success?
            reset_session
            session[:user_id] = result.user.id
            flash[:notice] = "Welcome, #{result.user.email}!"
            begin
                redirect_to params[:redirect_path]
            rescue ActionController::Redirecting::UnsafeRedirectError
                redirect_to root_path
            end
        else
            flash[:alert] = "We weren't able to log you in with that link. Try again?"
            redirect_to new_signin_path(redirect_path: params[:redirect_path])
        end
    end
end
