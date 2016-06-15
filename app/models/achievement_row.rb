class AchievementRow < ActiveRecord::Base
  belongs_to :achievement
  belongs_to :achievement_type

  validates_associated :achievement
  validates_associated :achievement_type

  validates_presence_of     :part_order, length: { within: 1..3 }, allow_nil: false
  validates_numericality_of :part_order

  scope :sort_by_part_order, -> { order('part_order') }
  # ----------------------------------------------------------------------------
end
