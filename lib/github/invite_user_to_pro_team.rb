# require 'faraday'
# require 'json'

module Github
  class InviteUserToProTeam
    def initialize(user)
      @user = user
      @client = GITHUB_CLIENT
      @team_slug = "Pro" # Pro team slug
      @org = "PhlexUI" # Organization name
    end

    def call
      conn = Faraday.new(url: 'https://api.github.com') do |faraday|
        faraday.request  :url_encoded
        faraday.response :logger
        faraday.adapter  Faraday.default_adapter
        faraday.headers['Authorization'] = "Bearer #{@client.access_token}"
        faraday.headers['Accept'] = "application/vnd.github+json"
      end

      response = conn.put do |req|
        req.url "/orgs/#{@org}/teams/#{@team_slug}/memberships/#{@user}"
        req.body = { role: "member" }.to_json
      end

      if response.success?
        puts "Successfully added #{@user} to #{@team_slug} team"
      else
        puts "Failed to add #{@user} to #{@team_slug} team: #{response.body}"
      end
    end
  end
end