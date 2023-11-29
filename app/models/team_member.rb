class TeamMember < ApplicationRecord
  belongs_to :user

  validates :email, uniqueness: {
      scope: :user_id,
      message: "is already a member of your account"
    },
    format: { with: URI::MailTo::EMAIL_REGEXP }
end
