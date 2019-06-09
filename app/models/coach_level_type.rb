# frozen_string_literal: true

require 'drop_down_listable'
require 'localizable'

class CoachLevelType < ApplicationRecord

  include DropDownListable
  include Localizable

  validates :code, presence: { length: { within: 1..5 }, allow_nil: false }
  validates :code, uniqueness: { message: :already_exists }
  validates :level, presence: { length: { within: 1..3 }, allow_nil: false }
  validates :level, numericality: true
  # ----------------------------------------------------------------------------

end
