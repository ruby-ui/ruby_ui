class User < ApplicationRecord
    include AfterSaveProvideGithubAccess

    has_many :team_members, dependent: :destroy
    
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validate :team_members_limit, if: :team?
    validates :github_username, uniqueness: true, allow_blank: true
    validate :github_username_exists, if: -> { github_username.present? && github_username_changed? }
    
    enum plan: { free: 0, personal: 1, team: 2 }

    def subscribed?
        personal? || team? || is_team_member?
    end

    def not_subscribed?
        !subscribed?
    end

    def is_team_member?
        TeamMember.exists?(email: email)
    end

    def team_member
        TeamMember.find_by(email: email)
    end

    private

    def team_members_limit
        errors.add(:team_members, "limit is 25") if team_members.size > 25
    end

    def github_username_exists
        GITHUB_CLIENT.user(github_username)
    rescue Octokit::NotFound
        errors.add(:github_username, 'does not exist on GitHub')
    end
end
