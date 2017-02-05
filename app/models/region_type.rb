require 'drop_down_listable'
require 'localizable'

class RegionType < ApplicationRecord
  include DropDownListable
  include Localizable

  validates_presence_of   :code, length: { maximum: 3 }, allow_nil: false
  validates_uniqueness_of :code, message: :already_exists
end
