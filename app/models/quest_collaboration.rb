class QuestCollaboration < ApplicationRecord
  belongs_to :quest
  belongs_to :user

  validates :user_id, uniqueness: { scope: :quest_id }

  scope :completed, -> { where.not(completed_at: nil) }
  scope :pending, -> { where(completed_at: nil) }
end
