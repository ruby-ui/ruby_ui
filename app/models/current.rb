class Current < ActiveSupport::CurrentAttributes
  attribute :user, :user_subscribed

  def user_subscribed?
    user_subscribed
  end
end