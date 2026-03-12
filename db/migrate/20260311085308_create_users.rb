class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :username
      t.integer :xp, default: 0
      t.integer :level, default: 1

      t.timestamps
    end
  end
end
