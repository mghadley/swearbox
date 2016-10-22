module GithubApi

	def get_repos
		base_uri = "https://api.github.com"
		repos = []
		# TODO change to dynamic usernames
		response = HTTParty.get("#{base_uri}/users/#{self.name}/repos?client_id=&client_secret=")
		response.each do |repo|
			repos << repo['name']
		end
		return repos
	end

	def get_commits(repos)
		base_uri = "https://api.github.com"
		commits = []
		repos.each do |repo|
			response = HTTParty.get("#{base_uri}/repos/#{self.name}/#{repo}/commits?client_id=&client_secret=")
			response.each do |commit|
				commits << commit['commit']['message']
			end
		end
		return commits
	end
end