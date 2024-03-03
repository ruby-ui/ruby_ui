class UserMailer < ApplicationMailer
  def welcome
    @user = params[:user]

    mail(
      to: @user.email,
      subject: "Welcome to PhlexUI"
    ) do |format|
      format.html { render Mailers::UserMailer::Welcome.new(user: @user) }
    end
  end

  def future_of_phlexui
    @user = params[:user]

    mail(
      to: @user.email,
      subject: "Open Source and the Future of PhlexUI (Retry)"
    ) do |format|
      format.html { render Mailers::UserMailer::FutureOfPhlexui.new(user: @user) }
    end
  end
end
