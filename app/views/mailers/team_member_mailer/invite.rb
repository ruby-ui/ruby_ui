module Mailers
  module TeamMemberMailer
    class Invite < ::Mailers::BaseMailer
      def initialize(user:, email:)
        @user = user
        @email = email
      end
      
      def template
        para do
          plain "You've been invited by "
          strong { @user.email } 
          plain " to join #{ENV['APP_NAME']}. Click the link below and make sure to sign in with the following email - "
          strong { @email }
        end
        cta(href: helpers.new_signin_url + "?email=#{CGI.escape(@email)}") do
          "Sign in to PhlexUI"
        end
      end
    end
  end
end