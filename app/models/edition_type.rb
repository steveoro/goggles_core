# frozen_string_literal: true

require 'drop_down_listable'
require 'localizable'

class EditionType < ApplicationRecord

  include DropDownListable
  include Localizable

  validates :code, presence: { length: { maximum: 1 }, allow_nil: false }
  validates :code, uniqueness: { message: :already_exists }
  # ----------------------------------------------------------------------------

  # Unique code used inside the DB to address the "Ordinal"-type row
  ORDINAL_CODE = 'O'
  # Unique ID used inside the DB to address the "Ordinal"-type row
  ORDINAL_ID = 1

  # Unique code used inside the DB to address the "Roman"-type row
  ROMAN_CODE = 'R'
  # Unique ID used inside the DB to address the "Roman"-type row
  ROMAN_ID = 2

  # Unique code used inside the DB to address the "None"-type row
  NONE_CODE = 'N'
  # Unique ID used inside the DB to address the "None"-type row
  NONE_ID = 3

  # Unique code used inside the DB to address the "Yearly"-type row
  YEAR_CODE = 'A'
  # Unique ID used inside the DB to address the "Yearly"-type row
  YEAR_ID = 4

  # Unique code used inside the DB to address the "Seasonal"-type row
  SEASON_CODE = 'S'
  # Unique ID used inside the DB to address the "Seasonal"-type row
  SEASON_ID = 5
  # ----------------------------------------------------------------------------

end
