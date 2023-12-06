class MarketingMailer < ApplicationMailer
    def early_access_welcome
        @user = params[:user]

        mail(
            to: @user.email,
            subject: "PhlexUI is ready for testing ✨"
        ) do |format|
            format.html { render Mailers::MarketingMailer::EarlyAccessWelcome.new(user: @user) }
        end
    end
end