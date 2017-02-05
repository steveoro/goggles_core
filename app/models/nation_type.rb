require 'drop_down_listable'
require 'localizable'


class NationType < ApplicationRecord
  include DropDownListable
  include Localizable

  validates_presence_of   :code, length: { within: 1..3 }, allow_nil: false
  validates_uniqueness_of :code, message: :already_exists
  
end
