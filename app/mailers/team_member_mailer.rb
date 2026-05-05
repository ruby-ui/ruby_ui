class TeamMemberMailer < ApplicationMailer
  def invite
    @user = params[:user]
    @email = params[:email]

    mail(
      to: @email,
      subject: "You've been invited to join #{ENV["APP_NAME"]}!"
    ) do |format|
      format.html { render Mailers::TeamMemberMailer::Invite.new(user: @user, email: @email) }
    end
  end
end
