class CrawlerWorker
	include Sidekiq::Worker
	require 'base64'

	def perform(user_id)
		user = User.find_by(user_id: user_id)
		repos = get_repos(user.github_username)
		commits = get_commits(repos)
		count_sins(user, commits.flatten.map { |c| c['message'] })
		file_urls = get_file_urls(commits.map { |c| c.last['tree_url'] })
		file_contents = get_contents(file_urls)
		count_sins(user, file_contents)
	end

	private

	@base_uri = "https://api.github.com"
	@credentials = "client_id=#{ENV[:GITHUB_CLIENT_ID]}&client_secret=#{ENV[:GITHUB_CLIENT_SECRET]}"

	def get_repos(username)
		repos = []
		# TODO change to dynamic usernames
		response = HTTParty.get("#{@base_uri}/users/#{username}/repos?#{@credentials}")
		response.each do |repo|
			repos << repo['name']
		end
		return repos
	end

	def get_commits(repos)
		commits = []
		repos.each do |repo|
			repo_commits = []
			response = HTTParty.get("#{@base_uri}/repos/#{self.name}/#{repo}/commits?#{@credentials}")
			response.each do |commit|
				repo_commits << { message: commit['commit']['message'], tree_url: commit['commit']['tree']['url'] }
			end
			commits << repo_commits
		end
		return commits
	end

	def get_file_urls(tree_urls)
		file_urls = []
		tree_urls.each do |tu|
			root = HTTParty.get("#{tu}?#{@credentials}")
			file_urls << crawl_tree(root['tree'])
		end
	end

	def crawl_tree(tree)
		file_urls = []
		tree.each do |object|
			if object['type'] == "blob"
				file_urls << object['url']
			else
				tree_url = object['url']
				next_tree = HTTParty.get("#{tree_url}?#{@credentials}")
				file_urls << crawl_tree(next_tree)
			end
		end
		return file_urls
	end

	def get_contents(file_urls)
		contents = []
		file_urls.each do |url|
			file = HTTParty.get("#{url}?#{@credentials}")
			contents << decode(file['content'])
		end
	end

	def decode(string)
		Base64.decode64(string)
	end

	def count_sins(user, strings)
		regex_hashes = Swearword.all.map { |sw| { id: sw.id, regex: Regexp.new("\\b#{sw.word}\\b") } }
		regex_hashes.each do |hash|
			strings.each do |string|
				count = string.scan(hash[:regex]).length
				sin = Sin.find_or_initialize_by(user_id: user.id, swearword_id: hash[:id])
				if count > 0
					sin.count += count
					sin.save
				end
			end
		end
	end
end