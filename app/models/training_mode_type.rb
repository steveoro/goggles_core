require 'drop_down_listable'
require 'localizable'


class TrainingModeType < ApplicationRecord
  include DropDownListable
  include Localizable

  validates_presence_of   :code, length: { within: 1..5 }, allow_nil: false
  validates_uniqueness_of :code, message: :already_exists
  # ----------------------------------------------------------------------------
end
