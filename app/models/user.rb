class User < ApplicationRecord
  has_many :sins
  has_many :swearwords, through: :sins

  after_commit :crawl_github

  def crawl_github
    if self.github_username && !self.crawler_started
      self.update(crawler_started: true)
      CrawlerWorker.perform_async(self.id)
    end
  end

  def self.top_ten
    arr = (User.all.sort { |x,y| x.total_owed <=> y.total_owed})[0..9]
  end

  def total_owed
    costs = self.sins.map { |sin| sin.total_cost }
    final_costs = costs.reduce(:+)
    final_costs ? final_costs : 0
  end
end
