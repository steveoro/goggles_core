# frozen_string_literal: true

require 'drop_down_listable'
require 'localizable'

class TimingType < ApplicationRecord

  include DropDownListable
  include Localizable

  validates :code, presence: { length: { maximum: 1 }, allow_nil: false }
  validates   :code, uniqueness: { message: :already_exists }
  # ----------------------------------------------------------------------------

  # Unique code used inside the DB to address the "MANUAL"-type row
  MANUAL_CODE = 'M'
  # Unique ID used inside the DB to address the "MANUAL"-type row
  MANUAL_ID = 1

  # Unique code used inside the DB to address the "SEMI-AUTOMATIC"-type row
  SEMIAUTO_CODE = 'S'
  # Unique ID used inside the DB to address the "SEMI-AUTOMATIC"-type row
  SEMIAUTO_ID = 2

  # Unique code used inside the DB to address the "AUTOMATIC"-type row
  AUTOMATIC_CODE = 'A'
  # Unique ID used inside the DB to address the "AUTOMATIC"-type row
  AUTOMATIC_ID = 3
  # ----------------------------------------------------------------------------

end
