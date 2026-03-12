class Quest < ApplicationRecord
  belongs_to :user
  validates :title, presence: true
  validates :xp_reward, presence: true, numericality: { greater_than: 0 }
end
