module Mailers
  module TeamMemberMailer
    class Invite < Phlex::HTML
      def initialize(user:, email:)
        @user = user
        @email = email
      end
      
      def template
        p do
          plain "You've been invited by "
          strong { @user.email } 
          plain " to join #{ENV['APP_NAME']}. Click the link below and make sure to sign in with the following email - "
          strong { @email }
        end
        a(
          href: helpers.new_signin_url + "?email=#{CGI.escape(@email)}",
          class: 'button'
        ) do
          "Sign in to PhlexUI"
        end
      end
    end
  end
end