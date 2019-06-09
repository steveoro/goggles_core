# frozen_string_literal: true

class ScoreMappingTypeRow < ApplicationRecord

  belongs_to :score_mapping_type
  validates_associated :score_mapping_type

  validates :position, presence: true
  validates :position, length: { within: 1..6, allow_nil: false }
  validates :position, uniqueness: { message: :already_exists }

  validates :score, presence: true
  validates :score, numericality: true
  # ----------------------------------------------------------------------------

end
