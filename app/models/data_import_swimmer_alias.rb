class DataImportSwimmerAlias < ApplicationRecord
  belongs_to :swimmer

  validates_presence_of :complete_name
  validates_length_of :complete_name, within: 1..100, allow_nil: false

#  attr_accessible :complete_name, :swimmer_id
  #-- -------------------------------------------------------------------------
  #++
end
