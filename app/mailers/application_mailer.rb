class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name(ENV["MAILER_SENDER"], ENV["APP_NAME"]),
         reply_to: ENV["MAILER_SENDER"]
  layout -> { MailerLayout }

  def self.template_path
    "mailers/#{name.underscore}"
  end
end
