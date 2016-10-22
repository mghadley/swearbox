class User < ApplicationRecord
	include GithubApi

	def count_sins(strings)
		regex_hashes = Swearword.all.map { |sw| { id: sw.id, regex: Regexp.new("\\b#{sw.word}\\b") } }
		regex_hashes.each do |hash|
			strings.each do |string|
				count = string.scan(hash[:regex]).length
				sin = Sin.find_or_initialize_by(user_id: self.id, swearword_id: hash[:id])
				if count > 0
					sin.count += count
					sin.save
				end
			end
		end
	end
end
