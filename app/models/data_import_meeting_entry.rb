# frozen_string_literal: true

require 'wrappers/timing'
# require 'swimmer_relatable'
require 'timing_gettable'
# require 'timing_validatable'
# require 'data_importable'

#
# == DataImportMeetingEntry
#
# Model class
#
# @author   Steve A.
# @version  4.00.811
#
class DataImportMeetingEntry < ApplicationRecord

  include SwimmerRelatable
  include TimingGettable
  include EventTypeRelatable
  include DataImportable

  belongs_to :user # [Steve, 20120212] Do not validate associated user!
  belongs_to :meeting_entry, foreign_key: 'conflicting_id', optional: true

  validates :import_text, presence: true

  belongs_to :data_import_meeting_program,  optional: true
  belongs_to :data_import_swimmer,          optional: true
  belongs_to :data_import_team,             optional: true
  belongs_to :data_import_badge,            optional: true

  belongs_to :meeting_program,              optional: true
  belongs_to :team,                         optional: true
  belongs_to :team_affiliation,             optional: true
  belongs_to :badge,                        optional: true
  belongs_to :entry_time_type,              optional: true

  validates :athlete_name, presence: true
  validates :athlete_name, length: { within: 1..100, allow_nil: false }
  validates :team_name, presence: true
  validates :team_name, length: { within: 1..50, allow_nil: false }

  validates :athlete_badge_number, length: { maximum: 40 }
  validates :team_badge_number, length: { maximum: 40 }

  validates :year_of_birth, presence: true
  validates :year_of_birth, length: { within: 2..4, allow_nil: false }
  validates :year_of_birth, numericality: true

  #  attr_accessible :data_import_session_id, :import_text, :conflicting_id,
  #                  :user, :user_id,
  #                  :athlete_name, :team_name, :athlete_badge_number, :team_badge_number,
  #                  :data_import_meeting_program_id, :data_import_swimmer_id,
  #                  :data_import_team_id, :data_import_badge_id,
  #                  :year_of_birth, :minutes, :seconds, :hundreds, :is_no_time,
  #                  :start_list_number, :lane_number, :heat_number, :heat_arrival_order,
  #                  :meeting_program_id, :swimmer_id, :team_id, :team_affiliation_id,
  #                  :badge_id, :entry_time_type_id

  #-- ----------------------------------------------------------------------------
  # Base methods:
  #-- ----------------------------------------------------------------------------
  #++

  # Computes a shorter description for the name associated with this data.
  def get_full_name
    "#{get_meeting_program_name}: #{start_list_number}) #{get_swimmer_name}, #{get_timing}"
  end

  # Computes a verbose or formal description for the name associated with this data.
  def get_verbose_name
    "#{get_meeting_program_verbose_name}: #{start_list_number}) #{get_swimmer_name} (#{get_year_of_birth}), #{get_timing}"
  end
  # ----------------------------------------------------------------------------

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
