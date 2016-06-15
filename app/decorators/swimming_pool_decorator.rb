# encoding: utf-8
require 'draper'


=begin

= SwimmingPoolDecorator

  - version:  4.00.313.20140610
  - author:   Steve A.

  Decorator for the SwimmingPool model.
  Contains all presentation-logic centered methods.

=end
class SwimmingPoolDecorator < Draper::Decorator
  include Rails.application.routes.url_helpers
  delegate_all

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
    "#{city_name} #{get_pool_attributes}"
  end
  # ----------------------------------------------------------------------------

  # Computes the URL for the Google Maps API service, according to the current instance
  # address, if defined. Returns nil otherwise.
  #
  def get_maps_url
    full_address = get_full_address
    if full_address.size > 1
      full_address.gsub!(' ', '+')
      "https://www.google.com/maps/preview#!q=#{full_address}"
    else
      nil
    end
  end

  # Retrieves the swimming pool length in meters, or 0 if any
  # E.g.: 50
  #
  def get_pool_length_in_meters
    pool_type ? pool_type.length_in_meters : 0
  end

  # Retrieves the swimming pool lane number, or 0 if any
  # E.g.: 8
  #
  def get_pool_lanes_number
    lanes_number ? lanes_number : 0
  end

  # Compose the swimming pool attributes (lanes_numebr x length_in_meters)
  # E.g.: "(8x50)"
  #
  def get_pool_attributes
    pool_type ? "(#{self.get_pool_lanes_number}x#{self.get_pool_length_in_meters})" : '(?)'
  end
  # ----------------------------------------------------------------------------


  # Retrieves the Pool Type short name
  def get_pool_type
    self.pool_type ? self.pool_type.i18n_short : '?'
  end

  # Retrieves the Locker Cabinet Type full description
  def get_locker_cabinet_type
    self.locker_cabinet_type ? self.locker_cabinet_type.i18n_description : '?'
  end

  # Retrieves the Shower Type full description
  def get_shower_type
    self.shower_type ? self.shower_type.i18n_description : '?'
  end

  # Retrieves the Hair-drier Type full description
  def get_hair_dryer_type
    self.hair_dryer_type ? self.hair_dryer_type.i18n_description : '?'
  end
  # ----------------------------------------------------------------------------

  # Compute a swimming poll description with link to swimming pool path
  def get_linked_name( name_method = :get_verbose_name )
    h.link_to( self.send( name_method ), swimming_pool_path( id: object.id ) ).html_safe
  end
end
