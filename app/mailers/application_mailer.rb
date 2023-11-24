class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"

  def self.template_path
    "mailers/#{name.underscore}"
  end
end
