# frozen_string_literal: true

# require 'data_importable'

class DataImportSeason < ApplicationRecord

  include DataImportable

  belongs_to :user # [Steve, 20120212] Do not validate associated user!

  belongs_to :season, foreign_key: 'conflicting_id', optional: true

  validates :import_text, presence: true

  belongs_to :season_type
  belongs_to :edition_type
  belongs_to :timing_type
  validates_associated :season_type
  validates_associated :edition_type
  validates_associated :timing_type

  validates :header_year, presence: true
  validates :header_year, length: { within: 1..9, allow_nil: false }

  validates :edition, presence: true
  validates :edition, length: { within: 1..3, allow_nil: false }

  validates :description, length: { within: 1..100, allow_nil: false }

  validates :begin_date, presence: true

  #  attr_accessible :data_import_session_id, :import_text, :conflicting_id,
  #                  :description, :begin_date, :end_date,
  #                  :season_type_id, :edition_type_id, :timing_type_id,
  #                  :season_type, :edition_type, :timing_type,
  #                  :header_year, :edition

  scope :sort_by_conflicting_rows_id,  ->(dir) { order("conflicting_id #{dir}") }
  scope :sort_by_user,                 ->(dir) { order("users.name #{dir}, data_import_seasons.begin_date #{dir}") }
  scope :sort_by_season_type,          ->(dir) { order("season_types.code #{dir}, data_import_seasons.begin_date #{dir}") }

  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------

  # Computes a shorter description for the name associated with this data
  def get_full_name
    "#{begin_date ? begin_date.strftime('%Y') : '?'}/#{end_date ? end_date.strftime('%y') : '?'} #{get_season_type}"
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "(#{begin_date ? begin_date.strftime('%Y') : '?'}/#{end_date ? end_date.strftime('%y') : '?'}) #{description}"
  end

  # Retrieves the user name associated with this instance
  def user_name
    user ? user.name : ''
  end
  # ----------------------------------------------------------------------------

  # Retrieves the Season Type short name
  def get_season_type
    season_type ? season_type.short_name : '?'
  end
  # ----------------------------------------------------------------------------

end
