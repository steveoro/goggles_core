# frozen_string_literal: true

class PoolType < ApplicationRecord

  include DropDownListable

  validates :code, presence: true
  validates :code, length: { within: 1..3, allow_nil: false }
  validates :code, uniqueness: { message: :already_exists }

  validates :length_in_meters, presence: true
  validates :length_in_meters, length: { maximum: 3, allow_nil: false }

  has_many :events_by_pool_types
  has_many :event_types, through: :events_by_pool_types

  scope :only_for_meetings, -> { where(is_suitable_for_meetings: true) }

  # Unique ID used inside the DB to address a 25 mt. PoolType instance
  MT25_ID = 1

  # Unique ID used inside the DB to address a 50 mt. PoolType instance
  MT50_ID = 2

  # Unique ID used inside the DB to address a 33 mt. PoolType instance
  MT33_ID = 3
  # ----------------------------------------------------------------------------

  # Commodity Hash used to enlist all defined IDs and their corresponding 'length_in_meters'
  # as integer value; the corresponding Code column is the 'length_in_meters' converted to String.
  #
  TYPES_HASH = {
    MT25_ID => 25,
    MT50_ID => 50,
    MT33_ID => 33
  }.freeze
  # ----------------------------------------------------------------------------

  # Computes a localized shorter description for the value/code associated with this data
  def i18n_short
    "#{length_in_meters} " + I18n.t(:meters_short)
  end

  # Computes a localized description for the value/code associated with this data
  def i18n_description
    "#{length_in_meters} " + I18n.t(:meters)
  end

  # Computes a localized verbose description for the value/code associated with this data
  def i18n_verbose
    I18n.t(:pool_type_des).gsub('{POOL_LENGTH}', length_in_meters.to_s)
  end
  # ----------------------------------------------------------------------------

end
