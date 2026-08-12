class AddCreatorCompletedAtToQuests < ActiveRecord::Migration[8.1]
  def change
    add_column :quests, :creator_completed_at, :datetime
  end
end
