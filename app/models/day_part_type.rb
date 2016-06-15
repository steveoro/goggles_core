require 'drop_down_listable'
require 'localizable'


class DayPartType < ActiveRecord::Base
  include DropDownListable
  include Localizable

  validates_presence_of   :code, length: { maximum: 1 }, allow_nil: false
  validates_uniqueness_of :code, message: :already_exists
  # ----------------------------------------------------------------------------

  # Unique ID used inside the DB to address a "morning" DayPartType instance 
  MORNING_ID = 1

  # Unique ID used inside the DB to address an "afternoon" DayPartType instance 
  AFTERNOON_ID = 2

  # Unique ID used inside the DB to address an "evening" DayPartType instance 
  EVENING_ID = 3

  # Unique ID used inside the DB to address a nighty DayPartType instance 
  NIGHT_ID = 4
  # ----------------------------------------------------------------------------


  # Commodity Hash used to enlist all defined IDs and their corresponding codes.
  #
  TYPES_HASH = {
    MORNING_ID    => 'M',
    AFTERNOON_ID  => 'P',
    EVENING_ID    => 'S',
    NIGHT_ID      => 'N'
  }
  # ----------------------------------------------------------------------------
end
