module AfterSaveProvideGithubAccess
  extend ActiveSupport::Concern

  included do
    after_save :add_to_github_repos, if: -> { github_username.present? && saved_change_to_github_username? }
  end

  private

  def add_to_github_repos
    Github::InviteUserToProTeam.new(self.github_username).call
  end
end