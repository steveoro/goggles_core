# encoding: utf-8
require 'date'
require 'drop_down_listable'


=begin

= Season

  - version:  6.111
  - author:   Steve A., Leega

=end
class Season < ApplicationRecord
  include DropDownListable
  include UserRelatable

  belongs_to :season_type
  belongs_to :edition_type
  belongs_to :timing_type
  validates_associated :season_type
  validates_associated :edition_type
  validates_associated :timing_type

  has_one  :federation_type,            through: :season_type

  has_many :meetings
  has_many :goggle_cup_definitions
  has_many :badges
  has_many :team_affiliations
  has_many :meeting_team_scores
  has_many :teams,                      through: :team_affiliations
  has_many :swimmers,                   through: :badges
  has_many :meeting_individual_results, through: :meetings
  has_many :computed_season_ranking
  has_many :category_types
  has_many :time_standard

  has_many :meeting_sessions, through: :meetings
  has_many :meeting_events, through: :meeting_sessions

  # Returns the list of all EventType rows for all this Season's Meetings.
  # [Steve, 20170718] Hand-made has_many :event_types, through: :meetings (which can't work correctly)
  #
  def event_types
    self.meeting_events.includes(:event_type).map do |me|
      me.event_type
    end
  end

  validates_presence_of :header_year
  validates_length_of   :header_year, within: 1..9, allow_nil: false

  validates_presence_of :edition
  validates_length_of   :edition, within: 1..3, allow_nil: false

  validates_presence_of :description
  validates_length_of   :description, within: 1..100, allow_nil: false

  validates_presence_of :begin_date
  validates_presence_of :end_date

  scope :sort_season_by_begin_date,  ->(dir = 'ASC') { order("seasons.begin_date #{dir.to_s}") }
  scope :sort_season_by_end_date,    ->(dir = 'ASC') { order("seasons.end_date #{dir.to_s}") }
  scope :sort_season_by_season_type, ->(dir) { order("season_types.code #{dir.to_s}, seasons.begin_date #{dir.to_s}") }
  scope :sort_season_by_user,        ->(dir) { order("users.name #{dir.to_s}, seasons.begin_date #{dir.to_s}") }

  scope :is_not_ended,               -> { where('end_date is null or end_date >= curdate()') }
  scope :is_ended,                   -> { where('end_date is not null and end_date < curdate()') }
  scope :is_ended_before,            ->(end_date) { where(["end_date is not null and end_date < ?", end_date]) }
  scope :is_in_range,                ->(from_date, to_date) { where(["(begin_date is not null and begin_date <= ?) and (end_date is not null and end_date >= ?)", to_date, from_date]) }

  scope :for_season_type,            ->(season_type) { where(season_type_id: season_type.id) }
  scope :has_results,                -> { where("exists(select 1 from meetings where are_results_acquired)") }

# FIXME for Rails 4+, move required/permitted check to the controller using the model
#  attr_accessible :season_type_id, :edition_type_id, :timing_type_id,
#                  :header_year, :edition, :description, :begin_date, :end_date, :rules, :has_individual_rank
  #-- -------------------------------------------------------------------------
  #++

  # Computes a shorter description for the name associated with this data
  def get_full_name
    # [Steve, 20140725] Too long/repetitive: "#{description} #{header_year} - #{get_federation_type}"
    description
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    # [Steve, 20140725] This is surely excessively long/repetitive too:
    "#{edition} #{description} #{header_year} - #{get_federation_type} - (#{begin_date ? begin_date.strftime('%Y') : '?'}/#{end_date ? end_date.strftime('%y') : '?'}) "
  end
  #-- -------------------------------------------------------------------------
  #++

  # Retrieves the Season Type short name
  def get_season_type
    self.season_type ? self.season_type.short_name :  '?'
  end

  # Retrieves the Federation Type short name
  def get_federation_type
    self.federation_type ? self.federation_type.short_name :  '?'
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

  # Returns if the season is ended at a certain date
  #
  # == Parameters:
  #
  # - evauation_date: the date in which should verify if the seasons is terminated
  #
  # == Returns:
  # - TRUE if season is ended at the specified date
  # - FALSE if season is not ended at the date or there is no season end defined
  #
  def is_season_ended_at( evaluation_date = Date.today )
    if self.end_date
      ( self.end_date <= evaluation_date ) ? true : false
    else
      false
    end
  end

  # Returns if the season is started at a certain date
  #
  # == Parameters:
  #
  # - evauation_date: the date in which should verify if the seasons is started
  #
  # == Returns:
  # - +true+ if season is starting at the specified date
  # - +false+ if season has not started at the specified date
  #
  def is_season_started_at( evaluation_date = Date.today )
    ( self.begin_date <= evaluation_date ) ? true : false
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns a generic, usually valid +header_year+ string given the specified date.
  # (It may yield wrong values for certain Championships.)
  #
  def self.build_header_year_from_date( evaluation_date = Date.today )
    raise ArgumentError.new( "evaluation_date must be of a Date kind." ) unless evaluation_date.kind_of?( Date )
    year = evaluation_date.month < 10 ? evaluation_date.year - 1 : evaluation_date.year
    "#{year}/#{year+1}"
  end

  # Returns the exact +header_year+ string given the current instance of Season.
  #
  def build_header_year()
    "#{self.begin_date.year}/#{self.end_date.year}"
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the last defined season for a specific SeasonType code
  # considering the begin date
  #
  def self.get_last_season_by_type( season_type_code )
    Season.joins(:season_type).where(['season_types.code = ?', season_type_code]).sort_season_by_begin_date('ASC').last
  end

  # Returns the last defined season for a specific SeasonType code
  #
  def get_last_season_by_type( season_type_code )
    Season.get_last_season_by_type( season_type_code )
  end
  #-- -------------------------------------------------------------------------
  #++
end
