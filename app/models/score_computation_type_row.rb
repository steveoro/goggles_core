# frozen_string_literal: true

class ScoreComputationTypeRow < ApplicationRecord

  belongs_to :score_computation_type
  belongs_to :score_mapping_type
  validates_associated :score_computation_type
  validates_associated :score_mapping_type

  validates :class_name, presence: true
  validates :class_name, length: { within: 1..20, allow_nil: false }
  validates :class_name, uniqueness: { message: :already_exists }
  validates :method_name, presence: true
  validates :method_name, length: { within: 1..20, allow_nil: false }
  validates :method_name, uniqueness: { message: :already_exists }

  validates :default_score, presence: true
  validates :default_score, numericality: true
  # ----------------------------------------------------------------------------

end
