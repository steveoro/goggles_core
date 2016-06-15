require 'wrappers/timing'
require 'timing_gettable'
require 'timing_validatable'


class SeasonPersonalStandard < ActiveRecord::Base
  include SwimmerRelatable
  include TimingGettable
  include TimingValidatable

  belongs_to :user                                  # [Steve, 20120212] Do not validate associated user!

  belongs_to :season
  belongs_to :event_type
  belongs_to :pool_type
  validates_associated :season
  validates_associated :event_type
  validates_associated :pool_type
  
  scope :for_season,          ->(season)     { where(season_id: season.id) }
  scope :for_swimmer,         ->(swimmer)    { where(swimmer_id: swimmer.id) }
  scope :for_event_type,      ->(event_type) { where(event_type_id: event_type.id) }
  scope :for_pool_type,       ->(pool_type)  { where(pool_type_id: pool_type.id) }
  scope :for_event_and_pool,  ->(event_by_pool_type) { where(event_type_id: event_by_pool_type.event_type_id, pool_type_id: event_by_pool_type.pool_type_id) }

  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------

  # Computes a shorter description for the name associated with this data
  def get_short_name
    "#{get_swimmer_name},  #{get_event_type} : #{get_timing}"
  end

  # Computes a shorter description for the name associated with this data
  def get_full_name
    "#{season.get_full_name} - #{get_swimmer_name}, #{get_pool_type} - #{get_event_type} : #{get_timing}"
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "#{season.get_verbose_name} - #{get_swimmer_name}, #{get_pool_type} - #{get_event_type} : #{get_timing}"
  end

  # Retrieves the user name associated with this instance
  def user_name
    self.user ? self.user.name : ''
  end
  # ----------------------------------------------------------------------------

  # Retrieves the localized Event Type code
  def get_event_type
    self.event_type ? self.event_type.i18n_short : '?'
  end

  # Retrieves the localized Pool Type code
  def get_pool_type
    self.pool_type ? self.pool_type.i18n_short : '?'
  end
  # ----------------------------------------------------------------------------

  # Checks if exists a standard time for a given season-swimmer-pool_typ-event_type
  #
  def self.has_standard?( season_id, swimmer_id, pool_type_id, event_type_id )
    SeasonPersonalStandard.where([
      'season_id = ? AND swimmer_id = ? AND pool_type_id = ? AND event_type_id = ?', 
      season_id, swimmer_id, pool_type_id, event_type_id])
      .count > 0  
  end

  # Returns standard time for a given season-swimmer-pool_typ-event_type
  # or nil if not present
  #
  def self.get_standard( season_id, swimmer_id, pool_type_id, event_type_id )
    SeasonPersonalStandard.where([
      'season_id = ? AND swimmer_id = ? AND pool_type_id = ? AND event_type_id = ?', 
      season_id, swimmer_id, pool_type_id, event_type_id]).first
  end
  # ----------------------------------------------------------------------------
end
