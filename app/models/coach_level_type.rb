require 'drop_down_listable'
require 'localizable'


class CoachLevelType < ActiveRecord::Base
  include DropDownListable
  include Localizable

  validates_presence_of     :code,  length: { within: 1..5 }, allow_nil: false
  validates_uniqueness_of   :code,  message: :already_exists
  validates_presence_of     :level, length: { within: 1..3 }, allow_nil: false
  validates_numericality_of :level
  # ----------------------------------------------------------------------------
end
