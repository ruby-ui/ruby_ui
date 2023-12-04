module GithubAccessHandler
  extend ActiveSupport::Concern

  included do
    after_save :provide_github_access, if: :should_provide_github_access?
    after_save :revoke_previous_github_access, if: :should_revoke_previous_github_access?
  end

  private

  def should_provide_github_access?
    github_username.present? && saved_change_to_github_username?
  end

  def should_revoke_previous_github_access?
    saved_change_to_github_username?
  end

  def provide_github_access
    Github::InviteUserToProTeam.new(self.github_username).call
  end

  def revoke_previous_github_access
    previous_github_username = previous_changes['github_username'].first
    if previous_github_username
      Github::RevokeAccessFromProTeam.new(previous_github_username).call
    end
  end
end