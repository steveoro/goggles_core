# frozen_string_literal: true

class DataImportTeamAlias < ApplicationRecord

  belongs_to :team

  validates :name, presence: true
  validates :name, length: { within: 1..60, allow_nil: false }

  #  attr_accessible :name, :team_id
  #-- -------------------------------------------------------------------------
  #++

end
