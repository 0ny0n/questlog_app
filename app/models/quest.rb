class Quest < ApplicationRecord
  belongs_to :user
  has_rich_text :description
  validates :title, presence: true
  validates :xp_reward, presence: true, numericality: { greater_than: 0 }
  has_many :quest_collaborations, dependent: :destroy
  has_many :collaborators, through: :quest_collaborations, source: :user

  scope :visible_to, ->(user) {
    left_outer_joins(:quest_collaborations)
      .where("quests.user_id = ? OR quest_collaborations.user_id = ?", user.id, user.id)
      .distinct
  }
  scope :created_by, ->(user) { where(user_id: user.id) }
  scope :collaborative, -> { joins(:quest_collaborations).distinct }

  after_save :sync_collaborators_from_description

  def completed_by?(user)
    if user.id == self.user_id
      self.creator_completed_at.present?
    else
      collaboration = quest_collaborations.find_by(user_id: user.id)
      collaboration&.completed_at.present?
    end
  end

  def total_participants_count
    1 + collaborators.count
  end

  def completed_participants_count
    count = 0
    count += 1 if self.creator_completed_at.present?
    count += quest_collaborations.completed.count
    count
  end

  def all_participants_completed?
    completed_participants_count == total_participants_count
  end

  def mark_participant_complete!(user)
    return if completed_by?(user)

    if user.id == self.user_id
      self.update(creator_completed_at: Time.current)
    else
      collaboration = quest_collaborations.find_by(user_id: user.id)
      collaboration&.update(completed_at: Time.current)
    end

    user.gain_xp(self.xp_reward)

    if all_participants_completed?
      self.update(completed: true)
    end
  end

  private

  def sync_collaborators_from_description
    return unless description.body

    html = description.body.to_s
    user_ids = []

    html.scan(/<a[^>]*(?:data-trix-mention="(\d+)"|href="\/users\/(\d+)")[^>]*>.*?<\/a>/m) do |match|
      user_ids << (match[0] || match[1]).to_i
    end

    collaborator_ids = user_ids.uniq - [ self.user_id ]

    current_collaborator_ids = self.collaborator_ids
    to_add = collaborator_ids - current_collaborator_ids
    to_remove = current_collaborator_ids - collaborator_ids

    to_add.each { |id| quest_collaborations.create(user_id: id) }
    quest_collaborations.where(user_id: to_remove).destroy_all
  end
end
