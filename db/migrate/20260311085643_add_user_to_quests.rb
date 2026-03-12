class AddUserToQuests < ActiveRecord::Migration[8.1]
  def change
    add_reference :quests, :user, foreign_key: true
  end
end
