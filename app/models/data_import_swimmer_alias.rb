# frozen_string_literal: true

class DataImportSwimmerAlias < ApplicationRecord

  belongs_to :swimmer, optional: true

  validates :complete_name, presence: true
  validates :complete_name, length: { within: 1..100, allow_nil: false }

  #  attr_accessible :complete_name, :swimmer_id
  #-- -------------------------------------------------------------------------
  #++

end
