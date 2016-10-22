class AddCrawlerStartedToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :crawler_started, :boolean, null: false, default: false
  end
end
