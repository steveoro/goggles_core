require 'drop_down_listable'
require 'localizable'


class MovementType < ApplicationRecord
  include DropDownListable
  include Localizable

  # Commodity reference to a specific code stored in the DB; make sure this value is always correct
  CODE_FULL = 'C'                                   # If it's full or generic we may want to discriminate. (This code allows to avoid printing generic-type movements in some methods.)

  validates_presence_of   :code, length: { maximum: 1 }, allow_nil: false
  validates_uniqueness_of :code, message: :already_exists
  # ----------------------------------------------------------------------------
end
