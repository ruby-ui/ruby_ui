module Github
    class InviteUserToAllRepos
        def initialize(user)
            @user = user
            @client = GITHUB_CLIENT
            @repos = @client.org_repos(ENV['GITHUB_ORG'])
        end

        def call
            @repos.each do |repo|
                options = { permission: 'pull' } # 'pull' is equivalent to read access
                begin
                    @client.add_collaborator(repo.full_name, @user, options)
                rescue Octokit::Error => e
                    puts "Failed to add collaborator: #{e.message}"
                end
            end
        end
    end
end