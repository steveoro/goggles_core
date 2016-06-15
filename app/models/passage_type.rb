require 'drop_down_listable'
require 'localizable'


class PassageType < ActiveRecord::Base
  include DropDownListable
  include Localizable

  validates_presence_of   :code, length: { within: 1..6 }, allow_nil: false
  validates_uniqueness_of :code, message: :already_exists

  validates_length_of     :length_in_meters, maximum: 6
  # ----------------------------------------------------------------------------
end
