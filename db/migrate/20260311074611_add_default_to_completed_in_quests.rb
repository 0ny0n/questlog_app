class AddDefaultToCompletedInQuests < ActiveRecord::Migration[8.1]
  def change
    change_column :quests, :completed, :boolean, default: false, null: false
  end
end
