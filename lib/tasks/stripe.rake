namespace :stripe do
  desc "Sync all Stripe Checkout Sessions with users"
  task sync_checkout_sessions: :environment do
    begin
      # Retrieve all checkout sessions (modify as needed for pagination)
      sessions = Stripe::Checkout::Session.list({ limit: 1000, status: :complete }).data

      sessions.each do |session|
        # Sync each checkout session with the user
        Payment::SyncCheckoutSessionWithUser.new(session.id).call
      end

      puts "All sessions synced successfully."
    rescue Stripe::StripeError => e
      puts "Stripe error: #{e.message}"
    rescue StandardError => e
      puts "Unexpected error: #{e.message}"
    end
  end
end
