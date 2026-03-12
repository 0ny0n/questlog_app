class CreateQuests < ActiveRecord::Migration[8.1]
  def change
    create_table :quests do |t|
      t.string :title
      t.text :description
      t.integer :xp_reward
      t.boolean :completed, default: false, null: false

      t.timestamps
    end
  end
end
