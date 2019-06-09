# frozen_string_literal: true

require 'wrappers/timing'
require 'timing_gettable'
# require 'timing_validatable'
# require 'data_importable'

class DataImportMeetingRelayResult < ApplicationRecord

  include TimingGettable
  include TimingValidatable
  include DataImportable

  belongs_to :user # [Steve, 20120212] Do not validate associated user!

  belongs_to :meeting_relay_result, foreign_key: 'conflicting_id', optional: true

  validates :import_text, presence: true

  belongs_to :data_import_meeting_program, optional: true
  belongs_to :meeting_program, optional: true

  belongs_to :data_import_team, optional: true
  belongs_to :team, optional: true

  belongs_to :team_affiliation, optional: true
  belongs_to :disqualification_code_type, optional: true

  belongs_to :entry_time_type
  validates_associated :entry_time_type

  # This is used as an helper for the factory tests:
  has_one :meeting, through: :data_import_meeting_program

  validates :relay_header, presence: true
  validates :relay_header, length: { within: 1..60, allow_nil: false }

  validates :rank, presence: true
  validates :rank, length: { within: 1..4, allow_nil: false }
  validates :rank, numericality: true

  validates :standard_points, presence: true
  validates :standard_points, numericality: true
  validates :meeting_points, presence: true
  validates :meeting_points, numericality: true

  validates :reaction_time, presence: true
  validates :reaction_time, numericality: true

  #  attr_accessible :data_import_session_id, :import_text, :conflicting_id,
  #                  :user, :user_id,
  #                  :rank, :is_play_off, :is_out_of_race, :is_disqualified, :standard_points,
  #                  :meeting_points, :minutes, :seconds, :hundreds,
  #                  :data_import_team_id, :data_import_meeting_program_id,
  #                  :meeting_program_id, :team_id,
  #                  :disqualification_code_type_id, :relay_header, :reaction_time,
  #                  :entry_minutes, :entry_seconds, :entry_hundreds, :team_affiliation_id,
  #                  :entry_time_type_id

  scope :is_valid, -> { where(is_out_of_race: false, is_disqualified: false) }

  scope :sort_by_user,                 ->(dir) { order("users.name #{dir}, meeting_program_id #{dir}") }
  scope :sort_by_meeting,              ->(dir) { order("meeting_program_id #{dir}, rank #{dir}") }
  scope :sort_by_data_import_meeting,  ->(dir) { order("data_import_meeting_program_id #{dir}, rank #{dir}") }

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

  # Retrieves the team name
  def get_team_name
    team ? team.get_full_name : (data_import_team ? data_import_team.get_full_name : '?')
  end

  # Retrieves the localized Event Type code
  def get_event_type
    meeting_program ? meeting_program.event_type.i18n_short : (data_import_meeting_program ? data_import_meeting_program.event_type.i18n_short : '?')
  end

  # Retrieves the scheduled_date of this result
  def get_scheduled_date
    meeting_program ? meeting_program.get_scheduled_date : (data_import_meeting_program ? data_import_meeting_program.get_scheduled_date : '?')
  end

  # Retrieves the Meeting Program short name
  def get_meeting_program_name
    meeting_program ? meeting_program.get_meeting_program_name : (data_import_meeting_program ? data_import_meeting_program.get_meeting_program_name : '?')
  end

  # Retrieves the Meeting Program verbose name
  def get_meeting_program_verbose_name
    meeting_program ? meeting_program.get_meeting_program_verbose_name : (data_import_meeting_program ? data_import_meeting_program.get_meeting_program_verbose_name : '?')
  end
  # ----------------------------------------------------------------------------

end
