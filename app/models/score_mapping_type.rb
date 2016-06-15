require 'drop_down_listable'
require 'localizable'


class ScoreMappingType < ActiveRecord::Base
  include DropDownListable
  include Localizable

  has_many :score_mapping_type_rows

  validates_presence_of   :code, length: { within: 1..6 }, allow_nil: false
  validates_uniqueness_of :code, message: :already_exists
  # ----------------------------------------------------------------------------
end
