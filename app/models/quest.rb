class Quest < ApplicationRecord
  belongs_to :user
  has_rich_text :description
  validates :title, presence: true
  validates :xp_reward, presence: true, numericality: { greater_than: 0 }
end
