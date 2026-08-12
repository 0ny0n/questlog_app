class CreateQuestCollaborations < ActiveRecord::Migration[8.1]
  def change
    create_table :quest_collaborations do |t|
      t.references :quest, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.datetime :completed_at

      t.timestamps
    end

    add_index :quest_collaborations, [ :quest_id, :user_id ], unique: true
  end
end
