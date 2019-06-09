# frozen_string_literal: true

require 'drop_down_listable'
require 'localizable'

class ScoreMappingType < ApplicationRecord

  include DropDownListable
  include Localizable

  has_many :score_mapping_type_rows

  validates :code, presence: { length: { within: 1..6 }, allow_nil: false }
  validates :code, uniqueness: { message: :already_exists }
  # ----------------------------------------------------------------------------

end
