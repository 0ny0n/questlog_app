class User < ApplicationRecord
  has_many :quests

  def gain_xp(amount)
    self.xp += amount
    check_level_up
    save
  end

  def check_level_up
    while xp >= xp_required_for_next_level
      self.xp -= xp_required_for_next_level
      self.level += 1
    end
  end

  def xp_required_for_next_level
    base_xp = 100
    milestone = (level - 1) / 5
    growth_rate = 0.10 + (milestone * 0.03)

    (base_xp * ((1 + growth_rate) ** (level - 1))).to_i
  end
end
