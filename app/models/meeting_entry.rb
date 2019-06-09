# frozen_string_literal: true

require 'wrappers/timing'

class MeetingEntry < ApplicationRecord

  include SwimmerRelatable

  include TimingGettable
  include EventTypeRelatable

  belongs_to :user # [Steve, 20120212] Do not validate associated user!

  belongs_to :meeting_program
  validates_associated :meeting_program

  has_one  :meeting_event,    through: :meeting_program
  has_one  :meeting_session,  through: :meeting_program
  has_one  :meeting,          through: :meeting_program
  has_one  :season,           through: :meeting_program

  has_one  :pool_type,      through: :meeting_program
  has_one  :season_type,    through: :meeting_program
  has_one  :event_type,     through: :meeting_program
  has_one  :category_type,  through: :meeting_program
  has_one  :gender_type,    through: :meeting_program
  # These reference fields may be filled-in later (thus not validated upon creation):
  belongs_to :team
  belongs_to :team_affiliation
  belongs_to :badge
  validates_associated :team
  validates_associated :team_affiliation
  validates_associated :badge

  belongs_to :swimmer
  belongs_to :entry_time_type

  # FIXME: for Rails 4+, move required/permitted check to the controller using the model
  #  attr_accessible :start_list_number, :lane_number, :heat_number, :heat_arrival_order, :meeting_program_id,
  #                  :swimmer_id, :team_id, :team_affiliation_id, :badge_id, :entry_time_type_id,
  #                  :minutes, :seconds, :hundreds, :is_no_time, :user_id

  scope :is_male,               -> { joins(:swimmer).where(['swimmers.gender_type_id = ?', GenderType::MALE_ID]) }
  scope :is_female,             -> { joins(:swimmer).where(['swimmers.gender_type_id = ?', GenderType::FEMALE_ID]) }

  scope :for_gender,            ->(gender_type_id)  { joins(:meeting_program).where(['meeting_programs.gender_type_id = ?', gender_type_id]) }
  scope :for_team,              ->(team_id)         { where(['team_id = ?', team_id]) }
  scope :for_category_type,     ->(category_type)   { joins(:category_type).where(['category_types.id = ?', category_type.id]) }
  scope :for_event_type,        ->(event_type)      { joins(:event_type).where(['event_types.id = ?', event_type.id]) }

  scope :sort_by_number,        -> { order('start_list_number ASC, is_no_time DESC, (minutes*6000+seconds*100+hundreds) DESC ') }
  scope :sort_by_gender_number, -> { joins(:meeting_program).order('meeting_programs.gender_type_id DESC, start_list_number ASC, is_no_time DESC, (minutes*6000+seconds*100+hundreds) DESC ') }
  scope :sort_by_swimmer,       -> { joins(:swimmer).order('swimmers.complete_name') }

  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------
  #++

  # Computes a shorter description for the name associated with this data.
  def get_full_name
    "#{get_scheduled_date} #{get_event_type}: #{start_list_number}) #{swimmer.get_full_name}, #{get_timing}"
  end

  # Computes a verbose or formal description for the name associated with this data.
  def get_verbose_name
    "#{get_meeting_program_verbose_name}: #{start_list_number}) #{swimmer.get_full_name} (#{swimmer.year_of_birth}), #{get_timing}"
  end
  # ----------------------------------------------------------------------------

  # Leega. Have to repat those method that are equal to those in meeting_individual_results?
  # Retrieves the user name associated with this instance
  def user_name
    user ? user.name : ''
  end

  # Retrieves the associated Team full name
  def get_team_name
    team ? team.get_full_name : '?'
  end
  # ----------------------------------------------------------------------------

  # Retrieves the Category Type id as it is; returns 0 in case of an invalid record
  def get_category_type_id
    category_type ? category_type.id : 0
  end

  # Retrieves the Category Type code as it is; returns '?' in case of an invalid record
  def get_category_type_code
    category_type ? category_type.code : '?'
  end

  # Retrieves the Category Type short name as it is; returns '?' in case of an invalid record
  def get_category_type_short_name
    category_type ? category_type.short_name : '?'
  end
  # ----------------------------------------------------------------------------

  # Retrieves the Season id as it is; returns 0 in case of an invalid record
  def get_season_id
    season ? season.id : 0
  end

  # Retrieves the Gender Type id as it is; returns 0 in case of an invalid record
  def get_gender_type_id
    gender_type ? gender_type.id : 0
  end

  # Retrieves the Pool Type id as it is; returns 0 in case of an invalid record
  def get_pool_type_id
    pool_type ? pool_type.id : 0
  end
  # ----------------------------------------------------------------------------

  # Getter for short display name of Category + Gender.
  def get_category_and_gender_short
    meeting_program ? meeting_program.get_category_and_gender_short : '?'
  end

  # Retrieves the scheduled_date of this result
  def get_scheduled_date # The following ActiveRecord chain is granted in existence by validation assertions: (even the first check could be avoided)
    meeting_program ? meeting_program.meeting_session.scheduled_date : '?'
  end

  # Retrieves the Meeting Program short name
  def get_meeting_program_name
    meeting_program ? meeting_program.get_full_name : '?'
  end

  # Retrieves the Meeting Program verbose name
  def get_meeting_program_verbose_name
    meeting_program ? meeting_program.get_verbose_name : '?'
  end
  # ----------------------------------------------------------------------------

end
