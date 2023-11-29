class User < ApplicationRecord
    has_many :team_members, dependent: :destroy
    
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validate :team_members_limit, if: :team?
    
    enum plan: { free: 0, personal: 1, team: 2 }

    def subscribed?
        personal? || team? || is_team_member?
    end

    def not_subscribed?
        !subscribed?
    end

    private

    def team_members_limit
        errors.add(:team_members, "limit is 25") if team_members.size > 25
    end

    def is_team_member?
        TeamMember.exists?(email: email)
    end
end
