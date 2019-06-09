# frozen_string_literal: true

require 'drop_down_listable'
require 'localizable'

class PassageType < ApplicationRecord

  include DropDownListable
  include Localizable

  validates :code, presence: { length: { within: 1..6 }, allow_nil: false }
  validates :code, uniqueness: { message: :already_exists }

  validates :length_in_meters, length: { maximum: 6 }
  # ----------------------------------------------------------------------------

end
