module Mailers
    module TeamMemberMailer
        class Invite < ::Mailers::ApplicationMailer
            def initialize(user:, email:)
                @user = user
                @email = email
            end
            
            def template
                div(class: '!block flex justify-center', style: 'display: none;') do
                    render Shared::Logo.new
                end
                render PhlexUI::Card.new(class: "p-6 flex flex-col items-center gap-y-4 max-w-lg mx-auto") do
                    render PhlexUI::Typography::Muted.new do
                        plain "You've been invited by "
                        strong(class: 'font-semibold !text-foreground') { @user.email } 
                        plain " to join #{ENV['APP_NAME']}. Click the link below and make sure to sign in with the following email - "
                        strong(class: 'font-semibold !text-foreground') { @email }
                    end
                    render PhlexUI::Link.new(
                        variant: :primary, 
                        href: helpers.new_signin_url + "?email=#{CGI.escape(@email)}"
                    ) { "Sign in to PhlexUI" }
                end
            end
        end
    end
end