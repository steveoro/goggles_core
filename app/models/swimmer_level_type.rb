require 'drop_down_listable'
require 'localizable'


class SwimmerLevelType < ApplicationRecord
  include DropDownListable
  include Localizable

  validates_presence_of     :code, length: { within: 1..5 }, allow_nil: false
  validates_uniqueness_of   :code, message: :already_exists
  validates_presence_of     :level, length: { within: 1..3 }, allow_nil: false
  validates_numericality_of :level
  # ----------------------------------------------------------------------------

  # Label symbol corresponding to either a column name or a model method to be used
  # mainly in generating DropDown option lists.
  #
  # @overload inherited from DropDownListable
  #
  def self.get_label_symbol
    :i18n_description
  end
  # ----------------------------------------------------------------------------
end
