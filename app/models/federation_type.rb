# frozen_string_literal: true

require 'drop_down_listable'

#
# = FederationType
#
#   - version:  4.00.369
#   - author:   Steve A.
#
class FederationType < ApplicationRecord

  include DropDownListable

  validates :code, presence: { length: { within: 1..4 }, allow_nil: false }
  validates :code, uniqueness: { message: :already_exists }

  validates     :description, length: { maximum: 100 }
  validates     :short_name, length: { maximum: 10 }
  #-- -------------------------------------------------------------------------
  #++

  # Label symbol corresponding to either a column name or a model method to be used
  # mainly in generating DropDown option lists.
  #
  # @overload inherited from DropDownListable
  #
  def self.get_label_symbol
    :short_name
  end
  #-- -------------------------------------------------------------------------
  #++

  # Computes the shortest possible description for the name associated with this data
  def get_short_name
    short_name
  end

  # Computes the shortest possible description for the name associated with this data
  def get_full_name
    description
  end
  #-- -------------------------------------------------------------------------
  #++

end
