# frozen_string_literal: true

#
# = SwimmingPool model
#
#   - version:  6.327
#   - author:   Steve A., Leega
#
class SwimmingPool < ApplicationRecord

  include DropDownListable

  belongs_to :user
  # [Steve, 20120212] Validating on User fails always because of validation requirements inside User (password & salt)
  #  validates_associated :user                       # (Do not enable this for User)

  belongs_to :city
  belongs_to :pool_type
  belongs_to :shower_type
  belongs_to :hair_dryer_type
  belongs_to :locker_cabinet_type

  validates_associated :city
  validates_associated :pool_type

  validates :name, presence: true
  validates :name, length: { within: 1..100, allow_nil: false }
  validates :nick_name, presence: true
  validates :nick_name, length: { within: 1..100, allow_nil: false }

  validates :address,       length: { maximum: 100 }
  validates :phone_number,  length: { maximum:  40 }
  validates :fax_number,    length: { maximum:  40 }
  validates :e_mail,        length: { maximum: 100 }
  validates :contact_name,  length: { maximum: 100 }

  validates :lanes_number, presence: true
  validates :lanes_number, length: { within: 1..2, allow_nil: false }
  validates :lanes_number, numericality: true

  # validates :has_multiple_pools,      :inclusion => { :in => [true, false] }
  # validates :has_open_area,           :inclusion => { :in => [true, false] }
  # validates :has_bar,                 :inclusion => { :in => [true, false] }
  # validates :has_restaurant_service,  :inclusion => { :in => [true, false] }
  # validates :has_gym_area,            :inclusion => { :in => [true, false] }
  # validates :has_children_area,       :inclusion => { :in => [true, false] }
  # validates :do_not_update,           :inclusion => { :in => [true, false] }

  scope :sort_swimming_pool_by_user,                ->(dir) { order("users.name #{dir}, swimming_pools.name #{dir}") }
  scope :sort_swimming_pool_by_city,                ->(dir) { order("cities.name #{dir}, swimming_pools.name #{dir}") }
  scope :sort_swimming_pool_by_pool_type,           ->(dir) { order("pool_types.code #{dir}, swimming_pools.name #{dir}") }
  scope :sort_swimming_pool_by_shower_type,         ->(dir) { order("shower_types.code #{dir}, swimming_pools.name #{dir}") }
  scope :sort_swimming_pool_by_hair_dryer_type,     ->(dir) { order("hair_dryer_types.code #{dir}, swimming_pools.name #{dir}") }
  scope :sort_swimming_pool_by_locker_cabinet_type, ->(dir) { order("locker_cabinet_types.code #{dir}, swimming_pools.name #{dir}") }

  acts_as_taggable_on :tags_by_users
  acts_as_taggable_on :tags_by_teams

  delegate :name, to: :user, prefix: true, allow_nil: true
  delegate :name, to: :city, prefix: true, allow_nil: true
  #-- -------------------------------------------------------------------------
  #++

  # Outputs a short description for the name associated with this data
  def get_full_name
    name
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "'#{get_full_name}' #{get_pool_attributes}, #{get_full_address}"
  end

  # Retrieves just the city name
  def get_city_full_name
    city ? city.get_full_name : ''
  end

  # Retrieves the full address
  def get_full_address
    "#{address} #{get_city_full_name}"
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_city_and_attributes
    "#{city ? city_name : '(?)'} #{get_pool_attributes}"
  end
  #-- -------------------------------------------------------------------------
  #++

  alias i18n_short get_full_name
  alias i18n_description get_verbose_name

  # Retrieves the Meeting session swimming pool length in meters, or 0 if any
  # E.g.: 50
  #
  def get_pool_length_in_meters
    pool_type ? pool_type.length_in_meters : 0
  end

  # Retrieves the Meeting session swimming pool lane number, or 0 if any
  # E.g.: 8
  #
  def get_pool_lanes_number
    lanes_number || 0
  end

  # Compose the swimming pool attributes (lanes_number x length_in_meters)
  # E.g.: "(8x50)"
  #
  def get_pool_attributes
    pool_type ? "(#{get_pool_lanes_number}x#{get_pool_length_in_meters})" : '(?)'
  end
  #-- -------------------------------------------------------------------------
  #++

end
