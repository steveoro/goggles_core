require 'drop_down_listable'

=begin

= City model

  - version:  4.00.409
  - author:   Steve A.

=end
class City < ApplicationRecord
  include DropDownListable

  belongs_to :user                                  # [Steve, 20120212] Do not validate associated user!

  belongs_to :area_type

  validates_presence_of   :name, length: { within: 1..50 }, allow_nil: false
  validates_uniqueness_of :name, scope: :zip, message: :already_exists
  validates_length_of     :zip,  maximum: 6
  validates_presence_of   :area, length: { within: 1..50 }, allow_nil: false
  validates_presence_of   :country, length: { within: 1..50 }, allow_nil: false
  validates_presence_of   :country_code, length: { within: 1..10 }, allow_nil: false

  delegate :code,       to: :area_type, prefix: true

# FIXME for Rails 4+, move required/permitted check to the controller using the model
#  attr_accessible :name, :zip, :area, :country, :country_code, :user_id
  #-- -------------------------------------------------------------------------
  #++

  # Computes a shorter description for the name associated with this data
  def get_full_name
    [
      (name.empty? || (name == '?') ? nil : name),
      (area.empty? || (area == '?') || (area == name) ? nil : "(#{area})")
    ].compact.join(" ")
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    country_desc = (self.country_code.nil? || (self.country_code == "I")) ? "" :
                   " #{self.country} (#{self.country_code})"
    get_full_name + country_desc
  end
  #-- -------------------------------------------------------------------------
  #++

  # Label symbol corresponding to either a column name or a model method to be used
  # mainly in generating DropDown option lists.
  #
  # @overload inherited from DropDownListable
  #
  def self.get_label_symbol
    :get_full_name
  end
  #-- -------------------------------------------------------------------------
  #++
end
