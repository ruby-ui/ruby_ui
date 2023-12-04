module Github
  class RevokeAccessFromProTeam
    TEAM_SLUG = "Pro"
    ORG = "PhlexUI"

    def initialize(username)
      @username = username
      @client = GITHUB_CLIENT
    end

    def call
      if @client.remove_team_membership(get_team_id, @username)
        puts "Successfully removed #{@username} from #{TEAM_SLUG} team"
      end
    rescue StandardError => e
      puts "Failed to remove #{@username} from #{TEAM_SLUG} team: #{e.message}"
    end

    private

    def get_team_id
      team = @client.org_teams(ORG).find { |t| t.name == TEAM_SLUG }
      team.id
    rescue StandardError
      raise "Team #{TEAM_SLUG} not found in organization #{ORG}"
    end
  end
end