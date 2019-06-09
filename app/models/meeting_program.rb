# frozen_string_literal: true

#
# == MeetingProgram
#
# Model class
#
# @author   Steve A.
# @version  6.177
#
class MeetingProgram < ApplicationRecord

  include MeetingAccountable

  belongs_to :user
  # [Steve, 20120212] Validating on User fails always because of validation requirements inside User (password & salt)
  #  validates_associated :user                       # (Do not enable this for User)

  belongs_to :meeting_event
  belongs_to :category_type
  belongs_to :gender_type
  belongs_to :pool_type
  belongs_to :time_standard
  validates_associated :meeting_event
  validates_associated :category_type
  validates_associated :gender_type

  has_many :meeting_entries,            dependent: :delete_all
  has_many :meeting_individual_results, dependent: :delete_all
  has_many :meeting_relay_results,      dependent: :delete_all

  has_many :passages
  has_many :meeting_relay_swimmers,     through: :meeting_relay_results

  has_one  :meeting_session,            through: :meeting_event
  has_one  :event_type,                 through: :meeting_event
  has_one  :stroke_type,                through: :event_type

  has_one  :meeting,                    through: :meeting_session
  has_one  :season,                     through: :meeting_session
  has_one  :season_type,                through: :meeting_session

  validates :event_order, presence: true
  validates :event_order, length: { within: 1..3, allow_nil: false }

  # FIXME: for Rails 4+, move required/permitted check to the controller using the model
  #  attr_accessible :event_order, :category_type_id, :gender_type_id, :user_id,
  #                  :is_autofilled, :is_out_of_race, :begin_time, :meeting_event_id,
  #                  :pool_type_id, :time_standard_id

  scope :only_relays,        -> { joins(:event_type).includes(:event_type).where('event_types.is_a_relay' => true) }
  scope :are_not_relays,     -> { joins(:event_type).includes(:event_type).where('event_types.is_a_relay' => false) }

  scope :sort_meeting_program_by_user,            ->(dir) { order("users.name #{dir}, meeting_sessions.scheduled_date #{dir}, meeting_programs.event_order #{dir}") }
  scope :sort_meeting_program_by_event_type,      ->(dir) { order("event_types.code #{dir}") }
  scope :sort_meeting_program_by_category_type,   ->(dir) { order("category_types.code #{dir}") }
  scope :sort_meeting_program_by_gender_type,     ->(dir) { order("gender_type.code #{dir}") }
  scope :sort_by_date,                            ->(dir = 'ASC') { order("meeting_sessions.scheduled_date #{dir}, meeting_programs.event_order #{dir}") }

  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------

  # Computes the shortest description for the name associated with this data
  def get_short_name
    "(#{get_scheduled_date}, #{event_order}) #{event_type.i18n_short} #{get_category_type_code} #{gender_type.i18n_short}"
  end

  # Computes a shorter description for the name associated with this data
  def get_full_name
    "#{get_meeting_session_name} #{get_event_name}"
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "#{get_meeting_session_verbose_name} #{get_event_name}"
  end
  # ----------------------------------------------------------------------------

  # Computes a short description of just the event name for this row, without dates.
  def get_complete_event_name
    "#{event_type.i18n_description} #{get_category_type_name} #{gender_type.i18n_description}"
  end

  # Computes a short description of just the event name for this row, without dates.
  def get_event_name
    "(#{event_order}) #{event_type.i18n_short} #{get_category_type_code} #{gender_type.i18n_short}"
  end

  # Computes a verbose description of just the event name for this row, without dates.
  def get_verbose_event_name
    "(#{I18n.t(:event)} #{event_order}) #{event_type.i18n_description} #{get_category_type_name} #{gender_type.i18n_description}"
  end
  # ----------------------------------------------------------------------------

  # Retrieves the user name associated with this instance
  def user_name
    user ? user.name : ''
  end
  # ----------------------------------------------------------------------------

  # Getter for short display name of Category + Gender.
  def get_category_and_gender_short
    "#{get_category_type_name} #{gender_type.i18n_short}"
  end

  # Retrieves the Category Type id
  def get_category_type_id
    category_type ? category_type.id : '?'
  end

  # Retrieves the Category Type code
  def get_category_type_code
    category_type ? category_type.code : '?'
  end

  # Retrieves the Category Type short name
  def get_category_type_name
    category_type ? category_type.short_name : '?'
  end
  # ----------------------------------------------------------------------------

  # Check if this meeting program is valid for the ranking system.
  def is_valid_for_ranking
    !(
      (meeting_event && meeting_event.is_out_of_race) ||
      (meeting_program && meeting_program.is_out_of_race)
    )
  end
  # ----------------------------------------------------------------------------

  # Retrieves the Meeting Session scheduled_date
  def get_scheduled_date
    meeting_session ? meeting_session.scheduled_date : '?'
  end
  # ----------------------------------------------------------------------------

  # Retrieves the Meeting Session short name (includes Meeting name)
  def get_meeting_session_name
    meeting_session ? meeting_session.get_full_name : '?'
  end

  # Retrieves the Meeting Session verbose name (includes Meeting name)
  def get_meeting_session_verbose_name
    meeting_session ? meeting_session.get_verbose_name : '?'
  end
  # ----------------------------------------------------------------------------

end
