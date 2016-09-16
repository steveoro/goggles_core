class ScoreComputationTypeRow < ApplicationRecord

  belongs_to :score_computation_type
  belongs_to :score_mapping_type
  validates_associated :score_computation_type
  validates_associated :score_mapping_type

  validates_presence_of   :class_name
  validates_length_of     :class_name, within: 1..20, allow_nil: false
  validates_uniqueness_of :class_name, message: :already_exists
  validates_presence_of   :method_name
  validates_length_of     :method_name, within: 1..20, allow_nil: false
  validates_uniqueness_of :method_name, message: :already_exists

  validates_presence_of     :default_score
  validates_numericality_of :default_score
  # ----------------------------------------------------------------------------
end
