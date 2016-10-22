class CreateSins < ActiveRecord::Migration[5.0]
  def change
    create_table :sins do |t|
      t.belongs_to :user, foreign_key: true, index: true
      t.belongs_to :swearword, foreign_key: true, index: true
      t.integer :count, null: false, default: 0

      t.timestamps
    end
  end
end
