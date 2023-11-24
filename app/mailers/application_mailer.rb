class ApplicationMailer < ActionMailer::Base
  default from: ENV["MAILER_SENDER"]
  layout "mailer"

  def self.template_path
    "mailers/#{name.underscore}"
  end
end
