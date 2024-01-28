namespace :user do
  desc "Send future of PhlexUI email to all users"
  task send_future_of_phlexui_email: :environment do
    begin
      # Retrieve all users (modify as needed for pagination)
      users = User.all

      users.each do |user|
        # Send email to each user
        UserMailer.with(user: user).future_of_phlexui.deliver_now
      end

      puts "All emails sent successfully."
    rescue StandardError => e
      puts "Unexpected error: #{e.message}"
    end
  end
end
