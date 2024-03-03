class SigninLinkMailer < ApplicationMailer
  def signin_link
    @user = params[:user]
    @token = params[:token]
    @redirect_path = params[:redirect_path]

    mail(
      to: @user.email,
      subject: "Your Magic Sign-in Link"
    ) do |format|
      format.html { render Mailers::SigninLinkMailer::SigninLink.new(user: @user, token: @token, redirect_path: @redirect_path) }
    end
  end
end
