module SubscriberStatus
    extend ActiveSupport::Concern

    included do
        before_action :set_subscriber_status
    end

    def set_subscriber_status
        Current.user_subscribed = Current.user&.subscribed? || false
    end

    def subscriber_only!
        return if Current.user_subscribed?

        flash[:notice] = "You must be a paying customer to access this page."
        redirect_to root_path
    end
end