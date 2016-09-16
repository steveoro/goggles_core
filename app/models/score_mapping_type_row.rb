class ScoreMappingTypeRow < ApplicationRecord

  belongs_to :score_mapping_type
  validates_associated :score_mapping_type

  validates_presence_of   :position
  validates_length_of     :position, within: 1..6, allow_nil: false
  validates_uniqueness_of :position, message: :already_exists

  validates_presence_of     :score
  validates_numericality_of :score
  # ----------------------------------------------------------------------------
end
