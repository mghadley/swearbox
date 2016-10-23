class AddCrawlerDoneToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :crawler_done, :boolean, null: false, default: false
  end
end
