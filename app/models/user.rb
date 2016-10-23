class User < ApplicationRecord
  include GithubApi
  after_save :crawl_github

  def crawl_github
    if self.github_username && !self.crawler_started
      self.update(crawler_started: true)
      CrawlerWorker.perform_async(self.id)
    end
  end
end
