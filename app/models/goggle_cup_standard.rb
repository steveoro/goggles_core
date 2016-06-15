require 'wrappers/timing'
require 'timing_gettable'
require 'timing_validatable'


class GoggleCupStandard < ActiveRecord::Base
  include SwimmerRelatable
  include TimingGettable
  include TimingValidatable

  belongs_to :user                                  # [Steve, 20120212] Do not validate associated user!

  belongs_to :goggle_cup
  belongs_to :event_type
  belongs_to :pool_type
  validates_associated :goggle_cup
  validates_associated :event_type
  validates_associated :pool_type
  
  has_one :team,  through: :goggle_cup

  scope :sort_by_user,        ->(dir) { order("users.name #{dir.to_s}, goggle_cups.season_year #{dir.to_s}, pool_types.code #{dir.to_s}, event_types.code #{dir.to_s}, swimmers.complete_name #{dir.to_s}") }
  scope :sort_by_goggle_cup,  ->(dir) { order("goggle_cups.season_year #{dir.to_s}, pool_types.code #{dir.to_s}, event_types.code #{dir.to_s}, swimmers.complete_name #{dir.to_s}") }
  scope :sort_by_swimmer,     ->(dir) { order("swimmers.complete_name #{dir.to_s}, goggle_cups.season_year #{dir.to_s}, pool_types.code #{dir.to_s}, event_types.code #{dir.to_s}") }
  scope :sort_by_event_type,  ->(dir) { order("event_types.code #{dir.to_s}, goggle_cups.season_year #{dir.to_s}, pool_types.code #{dir.to_s}, swimmers.complete_name #{dir.to_s}") }
  scope :sort_by_pool_type,   ->(dir) { order("pool_types.code #{dir.to_s}, goggle_cups.season_year #{dir.to_s}, event_types.code #{dir.to_s}, swimmers.complete_name #{dir.to_s}") }

  scope :for_goggle_cup,      ->(goggle_cup) { where(goggle_cup_id: goggle_cup.id) }
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
    "#{goggle_cup.get_full_name} - #{get_swimmer_name}, #{get_pool_type} - #{get_event_type} : #{get_timing}"
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "#{goggle_cup.get_verbose_name} - #{get_swimmer_name}, #{get_pool_type} - #{get_event_type} : #{get_timing}"
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

  # Checks if exists a standard goggle cup for a given goggle_cup-swimmer-pool_typ-event_type
  #
  def self.has_standard?( goggle_cup_id, swimmer_id, pool_type_id, event_type_id )
    GoggleCupStandard.where([
      'goggle_cup_id = ? AND swimmer_id = ? AND pool_type_id = ? AND event_type_id = ?', 
      goggle_cup_id, swimmer_id, pool_type_id, event_type_id])
      .count > 0  
  end

  # Returns standard goggle cup for a given goggle_cup-swimmer-pool_typ-event_type
  # or nil if not present
  #
  def self.get_standard( goggle_cup_id, swimmer_id, pool_type_id, event_type_id )
    GoggleCupStandard.where([
      'goggle_cup_id = ? AND swimmer_id = ? AND pool_type_id = ? AND event_type_id = ?', 
      goggle_cup_id, swimmer_id, pool_type_id, event_type_id]).first
  end
  # ----------------------------------------------------------------------------
end
