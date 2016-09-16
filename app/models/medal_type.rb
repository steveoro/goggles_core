require 'drop_down_listable'
require 'localizable'


class MedalType < ApplicationRecord
  include DropDownListable
  include Localizable

  validates_presence_of   :code, length: { maximum: 1 }, allow_nil: false
  validates_uniqueness_of :code, message: :already_exists

  # Filtering by record type scopes
  scope :are_not_jokes,   -> { where('weigth > 0') }

  scope :sort_by_rank,    -> { order(:rank) }
  # ----------------------------------------------------------------------------

  # Returns the image tag corresponding to the medal symbol
  #
  def get_medal_tag()
    case rank
    when 1
      "medal_gold_3.png"
    when 2
      "medal_silver_3.png"
    when 3
      "medal_bronze_3.png"
    else
      ''
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
