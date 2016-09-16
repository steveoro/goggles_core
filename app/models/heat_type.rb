require 'drop_down_listable'
require 'localizable'


class HeatType < ApplicationRecord
  include DropDownListable
  include Localizable

  validates_presence_of   :code, length: { within: 1..10 }, allow_nil: false
  validates_uniqueness_of :code, message: :already_exists

  # Unique IDs used inside the DB, the description will be retrieved using I18n.t() 
  HEAT_ID   = 1
  SEMI_ID   = 2
  FINALS_ID = 3
  # ----------------------------------------------------------------------------

  # Commodity Array used to enlist all defined IDs
  #
  TYPES_HASH = {
    HEAT_ID   => 'B',
    SEMI_ID   => 'S',
    FINALS_ID => 'F'
  }
  # ----------------------------------------------------------------------------
end
