# frozen_string_literal: true

require 'wrappers/timing'

#
# = TimeStandard model
#
#  Stores a standard timing recorded for a specific event, upon which IndividualRecords
#  are computed in score.
#
class TimeStandard < ApplicationRecord

  include TimingGettable
  include TimingValidatable

  belongs_to :user # [Steve, 20120212] Do not validate associated user!

  belongs_to :season
  belongs_to :gender_type
  belongs_to :pool_type
  belongs_to :event_type
  belongs_to :category_type
  validates_associated :season
  validates_associated :gender_type
  validates_associated :pool_type
  validates_associated :event_type
  validates_associated :category_type

  has_one  :season_type, through: :season

  delegate :name, to: :user, prefix: true

  # FIXME: for Rails 4+, move required/permitted check to the controller using the model
  #  attr_accessible :season_id, :event_type_id, :category_type_id, :gender_type_id,
  #                  :pool_type_id, :minutes, :seconds, :hundreds

  scope :sort_by_user,            ->(dir) { order("users.name #{dir}, seasons.code #{dir}") }
  scope :sort_by_season,          ->(dir) { order("seasons.code #{dir}") }
  scope :sort_by_gender_type,     ->(dir) { order("seasons.code #{dir}, gender_types.code #{dir}") }
  scope :sort_by_pool_type,       ->(dir) { order("seasons.code #{dir}, pool_types.code #{dir}") }
  scope :sort_by_event_type,      ->(dir) { order("seasons.code #{dir}, event_types.code #{dir}") }
  scope :sort_by_category_type,   ->(dir) { order("seasons.code #{dir}, category_types.code #{dir}") }

  #-- -------------------------------------------------------------------------
  #++

  # Computes a shorter description for the name associated with this data
  def get_full_name
    "#{season.get_season_type}, #{get_event_type} #{get_category_type} #{get_gender_type_code}: #{get_timing}"
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "#{season.get_season_type} #{get_pool_type}, #{get_event_type}: #{get_category_type} #{get_gender_type_code} => #{get_timing}"
  end
  #-- -------------------------------------------------------------------------
  #++

  # Retrieves the localized Event Type code
  def get_event_type
    event_type ? event_type.i18n_short : '?'
  end

  # Retrieves the localized Gender Type single-char code
  def get_gender_type_code
    gender_type ? gender_type.i18n_alternate : '?'
  end

  # Retrieves the localized Pool Type code
  def get_pool_type
    pool_type ? pool_type.i18n_short : '?'
  end

  # Retrieves the localized Category Type code
  def get_category_type
    category_type ? category_type.short_name : '?'
  end
  #-- -------------------------------------------------------------------------
  #++

  # Checks if exists a standard time for a given season-pool_type-event_type-gender_type-category_type
  #
  def self.has_standard?(season_id, pool_type_id, event_type_id, gender_type_id, category_type_id)
    TimeStandard.where([
                         'season_id = ? AND pool_type_id = ? AND event_type_id = ? AND gender_type_id = ? AND category_type_id = ?',
                         season_id, pool_type_id, event_type_id, gender_type_id, category_type_id
                       ])
                .exists?
  end

  # Returns standard time for a given season-pool_typ-event_type-gender_type-category_type
  # or nil if not present
  #
  def self.get_standard(season_id, pool_type_id, event_type_id, gender_type_id, category_type_id)
    TimeStandard.where([
                         'season_id = ? AND pool_type_id = ? AND event_type_id = ? AND gender_type_id = ? AND category_type_id = ?',
                         season_id, pool_type_id, event_type_id, gender_type_id, category_type_id
                       ]).first
  end
  #-- -------------------------------------------------------------------------
  #++

end
