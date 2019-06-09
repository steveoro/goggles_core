# frozen_string_literal: true

require 'wrappers/timing'
require 'timing_gettable'
# require 'timing_validatable'
# require 'data_importable'

class DataImportMeetingIndividualResult < ApplicationRecord

  include TimingGettable
  include TimingValidatable
  include DataImportable

  belongs_to :user # [Steve, 20120212] Do not validate associated user!

  belongs_to :meeting_individual_result, foreign_key: 'conflicting_id'

  validates :import_text, presence: true

  belongs_to :data_import_meeting_program
  belongs_to :meeting_program
  # These reference fields may be filled-in later (thus not validated upon creation):
  belongs_to :data_import_swimmer
  belongs_to :data_import_team
  belongs_to :data_import_badge

  belongs_to :swimmer
  belongs_to :team
  belongs_to :team_affiliation
  belongs_to :badge
  belongs_to :disqualification_code_type

  validates :athlete_name, presence: true
  validates :athlete_name, length: { within: 1..100, allow_nil: false }
  validates :team_name, presence: true
  validates   :team_name, length: { within: 1..50, allow_nil: false }

  validates   :athlete_badge_number, length: { maximum: 40 }
  validates   :team_badge_number, length: { maximum: 40 }

  validates :year_of_birth, presence: true
  validates :year_of_birth, length: { within: 2..4, allow_nil: false }
  validates :year_of_birth, numericality: true
  validates :rank, presence: true
  validates :rank, length: { within: 1..4, allow_nil: false }
  validates :rank, numericality: true

  validates :standard_points, presence: true
  validates :standard_points, numericality: true
  validates :meeting_individual_points, presence: true
  validates :meeting_individual_points, numericality: true
  validates :goggle_cup_points, presence: true
  validates :goggle_cup_points, numericality: true
  validates :team_points, presence: true
  validates :team_points, numericality: true

  validates :reaction_time, presence: true
  validates :reaction_time, numericality: true

  #  attr_accessible :data_import_session_id, :import_text, :conflicting_id,
  #                  :user, :user_id,
  #                  :athlete_name, :team_name, :athlete_badge_number, :team_badge_number,
  #                  :year_of_birth,
  #                  :rank, :is_play_off, :is_out_of_race, :is_disqualified, :standard_points,
  #                  :data_import_meeting_program_id, :data_import_swimmer_id,
  #                  :data_import_team_id, :data_import_badge_id,
  #                  :meeting_individual_points, :minutes, :seconds, :hundreds,
  #                  :meeting_program_id, :swimmer_id, :team_id, :badge_id,
  #                  :disqualification_code_type_id, :goggle_cup_points, :reaction_time,
  #                  :team_points, :team_affiliation_id

  scope :sort_by_user,      ->(dir) { order("users.name #{dir}, meeting_programs.meeting_session_id #{dir}, swimmers.last_name #{dir}, swimmers.first_name #{dir}") }
  scope :sort_by_meeting,   ->(dir) { order("meeting_programs.meeting_session_id #{dir}, swimmers.last_name #{dir}, swimmers.first_name #{dir}") }
  scope :sort_by_swimmer,   ->(dir) { order("swimmers.last_name #{dir}, swimmers.first_name #{dir}, data_import_meeting_individual_results.rank #{dir}") }
  scope :sort_by_team,      ->(dir) { order("teams.name #{dir}, swimmers.last_name #{dir}, swimmers.first_name #{dir}") }
  scope :sort_by_badge,     ->(dir) { order("badges.number #{dir}") }

  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------

  # Computes a shorter description for the name associated with this data
  def get_full_name
    "#{get_scheduled_date} #{get_event_type}: #{rank}) #{athlete_name}, #{get_timing}"
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "#{get_meeting_program_verbose_name}: #{rank}) #{athlete_name} (#{year_of_birth}), #{get_timing}"
  end

  # Retrieves the user name associated with this instance
  def user_name
    user ? user.name : ''
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the more "accessible" or "definitive" Meeting instance associated with this row.
  # Precedence: 1) primary entity, 2) secondary entity.
  #
  # Returns either an instance of Meeting or DataImportMeeting, depending upon
  # what has been linked to this row through the hierarchy.
  def meeting
    meeting = nil
    session = nil
    program = meeting_program ? meeting_program.meeting : data_import_meeting_program
    if program.respond_to?(:meeting_session) && program.meeting_session
      session = program.meeting_session
    elsif program.respond_to?(:data_import_meeting_session) && program.data_import_meeting_session
      session = program.data_import_meeting_session
    end
    if session.respond_to?(:meeting) && session.meeting
      meeting = session.meeting
    elsif session.respond_to?(:data_import_meeting) && session.data_import_meeting
      meeting = session.data_import_meeting
    end
    meeting
  end
  #-- -------------------------------------------------------------------------
  #++

  # Retrieves the associated Swimmer full name
  def get_swimmer_name
    swimmer ? swimmer.get_full_name : (data_import_swimmer ? data_import_swimmer.get_full_name : '?')
  end

  # Retrieves the associated Team full name
  def get_team_name
    team ? team.get_full_name : (data_import_team ? data_import_team.get_full_name : '?')
  end

  # Retrieves the localized Event Type code
  def get_event_type
    meeting_program ? meeting_program.event_type.i18n_short : (data_import_meeting_program ? data_import_meeting_program.event_type.i18n_short : '?')
  end

  # Retrieves the scheduled_date of this result
  def get_scheduled_date # The following ActiveRecord chain is granted in existence by validation assertions: (even the first check could be avoided)
    meeting_program ? meeting_program.get_meeting_session_name : (data_import_meeting_program ? data_import_meeting_program.get_meeting_session_name : '?')
  end

  # Retrieves the Meeting Program short name
  def get_meeting_program_name
    meeting_program ? meeting_program.get_full_name :  (data_import_meeting_program ? data_import_meeting_program.get_full_name : '?')
  end

  # Retrieves the Meeting Program verbose name
  def get_meeting_program_verbose_name
    meeting_program ? meeting_program.get_verbose_name : (data_import_meeting_program ? data_import_meeting_program.get_verbose_name : '?')
  end
  # ----------------------------------------------------------------------------

end
