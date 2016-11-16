class CrawlerWorker
	include Sidekiq::Worker
	require 'base64'


	def perform(user_id)
		@@base_uri = "https://api.github.com"
		@@credentials = "client_id=#{ENV['GITHUB_CLIENT_ID']}&client_secret=#{ENV['GITHUB_CLIENT_SECRET']}"
		user = User.find_by(id: user_id)
		puts "******************************************************************************************", user
		repos = get_repos(user.github_username)
		commits = get_commits(user.github_username, repos.map { |r| r[:name] })
		count_sins(user, commits.flatten.map { |c| c[:message] })
		# file_urls = get_file_urls(commits.map { |c| c.last[:tree_url] })
		# file_contents = get_contents(file_urls)
		repos.each do |repo|
			path = [Rails.root, "/tmp/#{user.github_username}-#{repo[:name]}/"].join
			`git clone #{repo[:clone_url]} #{path}`
			count_code_sins(user, path)
			`rm -rf #{path}`
		end
		user.update(crawler_done: true)
	end

	private

	def get_repos(username)
		repos = []
		puts "=======================================================================================", "trying to get repos from #{@@base_uri}"
		response = HTTParty.get("#{@@base_uri}/users/#{username}/repos?#{@@credentials}")
		puts "=======================================================================================", "got repos"
		response.each do |repo|
			repos << { name: repo['name'], clone_url: repo['clone_url'] }
		end
		if response.headers['Link']
			page_count = 1
			headers_array = response.headers['Link'].split","
			hash = Hash[headers_array.map { |el| el.split '; '}]
			hash.each do |key, value|
				if value == "rel=\"last\""
					page_count = (key.match(/page=(\d+).*$/)[1]).to_i
				end
			end
			if page_count > 1
				(2..page_count).each do |i|
					paginated_response = HTTParty.get("#{@@base_uri}/users/#{username}/repos?#{@@credentials}&page=#{i}")
					paginated_response.each do |repo|
						repos << { name: repo['name'], clone_url: repo['clone_url'] }
					end
				end
			end
		end
		return repos
	end

	# def get_repos_ssh(username)
	# 	repos = []
	# 	# TODO change to dynamic usernames
	# 	puts "=======================================================================================", "trying to get repos from #{@@base_uri}"
	# 	response = HTTParty.get("#{@@base_uri}/users/#{username}/repos?#{@@credentials}")
	# 	puts "=======================================================================================", "got repos"
	# 	response.each do |repo|
	# 		repos << repo['name']
	# 	end
	# 	puts repos
	# 	return repos
	# end

	def get_commits(username, repos)
		commits = []
		puts "=======================================================================================", "trying to get commits from #{@@base_uri}"
		repos.each do |repo|
			repo_commits = []
			puts "=======================================================================================", "making call to #{@@base_uri}/repos/#{username}/#{repo}/commits?#{@@credentials} to get commits for repo"
			response = HTTParty.get("#{@@base_uri}/repos/#{username}/#{repo}/commits?#{@@credentials}")
			response.each do |commit|
				# repo_commits << { message: commit['commit']['message'], tree_url: commit['commit']['tree']['url'] }
				unless commit.class == [1,2].class
					repo_commits << { message: commit['commit']['message'], tree_url: 'not currently used' }
				end
			end
			commits << repo_commits
		end
		return commits
	end

	# def get_file_urls(tree_urls)
	# 	puts "=======================================================================================", "getting file urls"
	# 	file_urls = []
	# 	tree_urls.each do |tu|
	# 		puts "=======================================================================================", "making call to #{tu} to get file urls"
	# 		root = HTTParty.get("#{tu}?#{@@credentials}")
	# 		file_urls << crawl_tree(root['tree'])
	# 	end
	# 	return file_urls
	# end

	# def crawl_tree(tree)
	# 	puts "=======================================================================================", "crawling a tree"
	# 	file_urls = []
	# 	tree.each do |object|
	# 		puts "=======================================================================================", "#{object.class}"
	# 		puts(tree.class, tree) if object.class == [1,2].class
	# 		if object['type'] == "blob"
	# 			file_urls << object['url']
	# 		else
	# 			tree_url = object['url']
	# 			next_tree = HTTParty.get("#{tree_url}?#{@@credentials}")
	# 			file_urls << crawl_tree(next_tree)
	# 		end
	# 	end
	# 	return file_urls
	# end

	# def get_contents(file_urls)
	# 	puts "=======================================================================================", "getting contents"
	# 	contents = []
	# 	file_urls.each do |url|
	# 		file = HTTParty.get("#{url}?#{@@credentials}")
	# 		contents << decode(file['content'])
	# 	end
	# end

	def decode(string)
		Base64.decode64(string)
	end

	def count_code_sins(user, path)
		puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$", "counting sins for #{path}"
		Swearword.all.each do |sw|
			count = (`egrep -irI "\\b#{sw.word}\\b" #{path} | wc -l`).to_i
			puts("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!", "Found #{count} #{sw.word}") if count > 0
			if count > 0
				sin = Sin.find_or_initialize_by(user_id: user.id, swearword_id: sw.id)
				sin.count += count
				sin.save
			end
		end
	end

	def count_sins(user, strings)
		puts "=======================================================================================", "counting sins for #{user}"
		regex_hashes = Swearword.all.map { |sw| { id: sw.id, regex: Regexp.new("\\b#{sw.word}\\b") } }
		regex_hashes.each do |hash|
			strings.each do |string|
				count = string.scan(hash[:regex]).length
				if count > 0
					sin = Sin.find_or_initialize_by(user_id: user.id, swearword_id: hash[:id])
					sin.count += count
					sin.save
				end
			end
		end
	end
end