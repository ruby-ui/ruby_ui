namespace :marketing_mailer do
  desc "Send early access welcome emails"
  task send_early_access_welcome_to_all_paying_users: :environment do
    # grab all paying users
    users = User.where.not(plan: [nil, "free"])

    users.each do |user|
        # send early access welcome email
        MarketingMailer.with(user: user).early_access_welcome.deliver_now
        # log error/success
        puts "Successfully sent early access welcome email to #{user.email} - #{user.plan}"
    end

    # log error/success
    puts "All early access welcome emails sent successfully."

  rescue StandardError => e
    puts "Unexpected error: #{e.message}"
  end
end
