class DataImportTeamAlias < ApplicationRecord
  belongs_to :team

  validates_presence_of :name
  validates_length_of :name, within: 1..60, allow_nil: false

#  attr_accessible :name, :team_id
  #-- -------------------------------------------------------------------------
  #++
end
