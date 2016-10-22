class CreateSwearwords < ActiveRecord::Migration[5.0]
  def change
    create_table :swearwords do |t|
      t.string :word
      t.integer :tier

      t.timestamps
    end
  end
end
