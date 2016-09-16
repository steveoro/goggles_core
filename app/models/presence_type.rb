require 'drop_down_listable'
require 'localizable'


class PresenceType < ApplicationRecord
  include DropDownListable
  include Localizable

  validates_presence_of   :code, length: { maximum: 1 }, allow_nil: false
  validates_uniqueness_of :code, message: :already_exists

  validates_length_of     :value, maximum: 3

  # Unique IDs used inside the DB, the description will be retrieved using I18n.t() 
  PRESENT_ID    = 1
  LATE_ID       = 2
  EARLY_OUT_ID  = 3
  ABSENT_ID     = 4
  # ----------------------------------------------------------------------------

  # Commodity Array used to enlist all defined IDs
  #
  TYPES_HASH = {
    PRESENT_ID    => 'P',
    LATE_ID       => 'R',
    EARLY_OUT_ID  => 'U',
    ABSENT_ID     => 'A'
  }
  # ----------------------------------------------------------------------------
end
