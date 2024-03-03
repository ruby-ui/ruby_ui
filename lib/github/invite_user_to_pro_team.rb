module Github
  class InviteUserToProTeam
    BASE_URL = "https://api.github.com"
    TEAM_SLUG = "Pro"
    ORG = "PhlexUI"

    def initialize(username)
      @username = username
      @client = GITHUB_CLIENT
    end

    def call
      response = connection.put do |req|
        req.url membership_url
        req.body = {role: "member"}.to_json
      end

      handle_response(response)
    end

    private

    def connection
      Faraday.new(url: BASE_URL) do |faraday|
        faraday.request :url_encoded
        faraday.response :logger
        faraday.adapter Faraday.default_adapter
        faraday.headers["Authorization"] = "Bearer #{@client.access_token}"
        faraday.headers["Accept"] = "application/vnd.github+json"
      end
    end

    def membership_url
      "/orgs/#{ORG}/teams/#{TEAM_SLUG}/memberships/#{@username}"
    end

    def handle_response(response)
      if response.success?
        puts "Successfully added #{@username} to #{TEAM_SLUG} team"
      else
        puts "Failed to add #{@username} to #{TEAM_SLUG} team: #{response.body}"
      end
    rescue Faraday::Error => e
      puts "An error occurred: #{e.message}"
    end
  end
end
