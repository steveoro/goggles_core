# frozen_string_literal: true

require 'wrappers/timing'

#
# == MeetingRelayResult
#
# Model class
#
# @author   Steve A.
# @version  6.332
#
class MeetingRelayResult < ApplicationRecord

  include TimingGettable
  include TimingValidatable

  belongs_to :user # [Steve, 20120212] Do not validate associated user!

  belongs_to :meeting_program
  belongs_to :team
  belongs_to :team_affiliation
  belongs_to :entry_time_type
  belongs_to :disqualification_code_type

  validates_associated :meeting_program
  validates_associated :team
  validates_associated :team_affiliation
  validates_associated :entry_time_type

  has_one  :meeting_event,    through: :meeting_program
  has_one  :meeting_session,  through: :meeting_program
  has_one  :meeting,          through: :meeting_program
  has_one  :season,           through: :meeting_program

  has_one  :pool_type,      through: :meeting_program
  has_one  :season_type,    through: :meeting_program
  has_one  :event_type,     through: :meeting_program
  has_one  :category_type,  through: :meeting_program
  has_one  :gender_type,    through: :meeting_program

  has_many :meeting_relay_swimmers, dependent: :delete_all

  validates     :relay_header, presence: { length: { maximum: 60 }, allow_blank: true }

  validates     :rank, presence: true
  validates :rank, length: { within: 1..4, allow_nil: false }
  validates :rank, numericality: true

  validates :standard_points, presence: true
  validates :standard_points, numericality: true
  validates :meeting_points, presence: true
  validates :meeting_points, numericality: true

  validates :reaction_time, presence: true
  validates :reaction_time, numericality: true

  # FIXME: for Rails 4+, move required/permitted check to the controller using the model
  #  attr_accessible :rank, :is_play_off, :is_out_of_race, :is_disqualified, :standard_points,
  #                  :meeting_points, :minutes, :seconds, :hundreds,
  #                  :meeting_program_id, :team_id, :user_id,
  #                  :disqualification_code_type_id, :relay_header, :reaction_time,
  #                  :entry_minutes, :entry_seconds, :entry_hundreds, :team_affiliation_id,
  #                  :entry_time_type_id

  scope :is_valid,               -> { where(is_out_of_race: false, is_disqualified: false) }
  scope :is_not_disqualified,    -> { where(is_disqualified: false) }
  scope :is_disqualified,        -> { where(is_disqualified: true) }

  scope :has_rank,               ->(rank_filter) { where(rank: rank_filter) }
  scope :has_points,             ->(score_sym = 'standard_points') { where("#{score_sym} > 0") }

  # [Steve, 20180613] Do not change the scope below with a composite check on each field joined by 'AND's, because it does not work
  scope :has_time,               -> { where('(minutes + seconds + hundreds > 0)') }

  scope :sort_by_user,           ->(dir)         { order("users.name #{dir}, meeting_program_id #{dir}, rank #{dir}") }
  scope :sort_by_meeting_relay,  ->(dir)         { order("meeting_program_id #{dir}, rank #{dir}") }
  scope :sort_by_timing,         ->(dir = 'ASC') { order(is_disqualified: :asc, minutes: dir.to_s.downcase.to_sym, seconds: dir.to_s.downcase.to_sym, hundreds: dir.to_s.downcase.to_sym) }
  scope :sort_by_rank,           ->(dir = 'ASC') { order("is_disqualified, rank #{dir}") }
  scope :for_team,               ->(team)        { where(team_id: team.id) }
  scope :sort_by_category,       ->(dir = 'ASC') { joins(:category_type, :gender_type).order("gender_types.code, category_types.code #{dir}") }
  scope :for_over_that_score,    ->(score_sym = 'standard_points', points = 800) { where("#{score_sym} > #{points}") }

  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------

  # Computes a shorter description for the name associated with this data
  def get_full_name
    "#{get_scheduled_date}, #{get_event_type}: #{rank}) #{get_team_name}, #{get_timing}"
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "#{get_meeting_program_verbose_name}: #{rank}) #{get_team_name}, #{get_timing}"
  end

  # Retrieves the user name associated with this instance
  def user_name
    user ? user.name : ''
  end
  # ----------------------------------------------------------------------------

  # Check if this result is valid for the ranking system.
  def is_valid_for_ranking
    !(
      (meeting_event && meeting_event.is_out_of_race) ||
      (meeting_program && meeting_program.is_out_of_race) ||
      is_out_of_race ||
      is_disqualified
    )
  end

  # Retrieves the associated Team full name
  def get_team_name
    team ? team.get_full_name : '?'
  end

  # Retrieves the localized Event Type code
  def get_event_type
    meeting_program ? meeting_program.event_type.i18n_short : '?'
  end

  # Retrieves the scheduled_date of this result
  def get_scheduled_date # The following ActiveRecord chain is granted in existence by validation assertions: (even the first check could be avoided)
    meeting_program ? meeting_program.get_scheduled_date : '?'
  end

  # Retrieves the Meeting Program short name
  def get_meeting_program_name
    meeting_program ? meeting_program.get_meeting_program_name : '?'
  end

  # Retrieves the Meeting Program verbose name
  def get_meeting_program_verbose_name
    meeting_program ? meeting_program.get_meeting_program_verbose_name : '?'
  end

  # Retrieves the relay header if present
  # If not present gets the team name
  def get_relay_name
    relay_header && relay_header != '' ? relay_header : get_team_name
  end

  # Retrieves the complete names of relay swimmers if present
  def get_short_relay_swimmers
    if meeting_relay_swimmers.exists?
      "(#{meeting_relay_swimmers.map { |mrs| mrs.swimmer.get_full_name }.join('-')})"
    else
      ''
    end
  end

  # Retrieves a complete relay name
  # The complete relay name consists in the relay header (or team name)
  # followed by swimmer's complete names (if stored)
  def get_complete_relay_name
    "#{get_relay_name} #{get_short_relay_swimmers}"
  end
  # ----------------------------------------------------------------------------

  # Counts the query results for a specified <tt>meeting_id</tt>, <tt>team_id</tt> and
  # minimum result score.
  #
  def self.count_team_results_for(meeting_id, team_id, min_meeting_score)
    includes(:meeting).where(
      ['meetings.id = ? AND meeting_relay_results.team_id = ? AND ' \
        'meeting_relay_results.meeting_points >= ?',
       meeting_id, team_id, min_meeting_score]
    ).count
  end

  # Counts the query results for a specified <tt>meeting_id</tt>, <tt>team_id</tt> and <tt>rank</tt>.
  #
  def self.count_team_ranks_for(meeting_id, team_id, rank)
    includes(:meeting).where(
      ['meetings.id = ? AND meeting_relay_results.team_id = ? AND ' \
        'meeting_relay_results.rank = ? AND ' \
        'meeting_relay_results.meeting_points > 0',
       meeting_id, team_id, rank]
    ).count
  end
  # ----------------------------------------------------------------------------

end
