require 'drop_down_listable'
require 'localizable'


class DisqualificationCodeType < ActiveRecord::Base
  include DropDownListable
  include Localizable

  validates_presence_of   :code, length: { within: 1..4 }, allow_nil: false
  validates_uniqueness_of :code, message: :already_exists

  belongs_to :stroke_type                           # it can be null (no foreign key thus)
  validates_associated :stroke_type                 # check index/key integrity

  # Shortcut-unique ID/CODE for commonly used disqualification codes 
  DSQ_FALSE_START_ID    = 1                         # NOTE: check migration AddDisqualificationCodeTypes for confirmation of this ID
  DSQ_FALSE_START_CODE  = 'GA'

  # Shortcut-unique ID for commonly used disqualification codes 
  DSQ_RETIRED_ID        = 11                        # NOTE: check migration AddDisqualificationCodeTypes for confirmation of this ID
  DSQ_RETIRED_CODE      = 'GK'
  # ----------------------------------------------------------------------------
end
