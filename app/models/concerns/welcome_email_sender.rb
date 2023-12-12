module WelcomeEmailSender
  extend ActiveSupport::Concern

  included do
    after_create :send_welcome_email
  end

  private

  def send_welcome_email
    UserMailer.with(user: self).welcome.deliver_now
  end
end