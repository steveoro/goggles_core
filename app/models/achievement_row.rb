# frozen_string_literal: true

class AchievementRow < ApplicationRecord

  belongs_to :achievement
  belongs_to :achievement_type

  validates_associated :achievement
  validates_associated :achievement_type

  validates :part_order, presence: { length: { within: 1..3 }, allow_nil: false }
  validates :part_order, numericality: true

  scope :sort_by_part_order, -> { order('part_order') }
  # ----------------------------------------------------------------------------

end
