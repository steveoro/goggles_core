# frozen_string_literal: true

require 'drop_down_listable'
require 'localizable'

class SwimmerLevelType < ApplicationRecord

  include DropDownListable
  include Localizable

  validates :code, presence: { length: { within: 1..5 }, allow_nil: false }
  validates :code, uniqueness: { message: :already_exists }
  validates :level, presence: { length: { within: 1..3 }, allow_nil: false }
  validates :level, numericality: true
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
