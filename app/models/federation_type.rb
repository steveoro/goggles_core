# encoding: utf-8
require 'drop_down_listable'


=begin

= FederationType

  - version:  4.00.369
  - author:   Steve A.

=end
class FederationType < ActiveRecord::Base
  include DropDownListable

  validates_presence_of   :code, length: { within: 1..4 }, allow_nil: false
  validates_uniqueness_of :code, message: :already_exists

  validates_length_of     :description, maximum: 100
  validates_length_of     :short_name, maximum: 10
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
    self.short_name
  end
  
  # Computes the shortest possible description for the name associated with this data
  def get_full_name
    self.description
  end
  #-- -------------------------------------------------------------------------
  #++
end
