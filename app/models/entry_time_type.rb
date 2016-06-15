require 'drop_down_listable'
require 'localizable'

=begin

= EntryTimeType model

  - version:  4.00.409
  - author:   Steve A.

=end
class EntryTimeType < ActiveRecord::Base
  include DropDownListable
  include Localizable

  validates_presence_of   :code, length: { maximum: 1 }, allow_nil: false
  validates_uniqueness_of :code, message: :already_exists

  # Unique IDs used inside the DB, the description will be retrieved using I18n.t()
  MANUAL_ID     = 1
  PERSONAL_ID   = 2
  OBERCUP_ID    = 3
  PREC_YEAR_ID  = 4
  LAST_RACE_ID  = 5
  #-- -------------------------------------------------------------------------
  #++

  # Commodity Array used to enlist all defined IDs
  #
  TYPES_HASH = {
    MANUAL_ID     => 'M',
    PERSONAL_ID   => 'P',
    OBERCUP_ID    => 'O',
    PREC_YEAR_ID  => 'A',
    LAST_RACE_ID  => 'U'
  }
  #-- -------------------------------------------------------------------------
  #++
end
