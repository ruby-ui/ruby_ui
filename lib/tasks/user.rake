namespace :user do
  desc "Send future of PhlexUI email to all users"
  task send_future_of_phlexui_email: :environment do
    # Retrieve all users (modify as needed for pagination)
    users = User.all

    users.each do |user|
      begin
        # Send email to each user
        UserMailer.with(user: user).future_of_phlexui.deliver_now
        puts "Email sent successfully to #{user.email}."
      rescue StandardError => e
        puts "Failed to send email to #{user.email}. Unexpected error: #{e.message}"
      end
    end
  end
end
