class AddPaidToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :paid, :boolean, null: false, default: false
  end
end
