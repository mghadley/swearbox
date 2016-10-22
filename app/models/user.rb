class User < ApplicationRecord
	after_save :crawl_github

	# may not need will test tomorrow
  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["info"]["name"]
    end
  end

  def crawl_github
  	if self.github_username && !self.crawler_started
	  	self.update(crawler_started: true)
	  	CrawlerWorker.perform_async(self.id)
	  end
  end
end