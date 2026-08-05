class AddDescriptionToQuests < ActiveRecord::Migration[8.1]
  def change
    add_column :quests, :description, :text
  end
end
