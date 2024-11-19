class UserMailer < ApplicationMailer
  def welcome
    @user = params[:user]

    mail(
      to: @user.email,
      subject: "Welcome to RubyUI"
    ) do |format|
      format.html { render Mailers::UserMailer::Welcome.new(user: @user) }
    end
  end
end
