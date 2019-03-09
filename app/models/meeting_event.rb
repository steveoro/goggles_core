#
# == MeetingEvent
#
# Model class
#
# @author   Steve A.
# @version  6.111
#
class MeetingEvent < ApplicationRecord
  include MeetingAccountable

  belongs_to :user
  # [Steve, 20120212] Validating on User fails always because of validation requirements inside User (password & salt)
#  validates_associated :user                       # (Do not enable this for User)

  belongs_to :meeting_session
  belongs_to :event_type
  belongs_to :heat_type
  validates_associated :meeting_session
  validates_associated :event_type
  validates_associated :heat_type

  validates_presence_of :event_order
  validates_length_of   :event_order, within: 1..3, allow_nil: false

# [Steve, 20170718] The has_one association w/ meeting breaks the reflection chain
# in ActiveRecord, invalidating actions like "meeting.destroy" due to the fallback
# failure, so it should be avoided at all cost:
#  has_one  :meeting,      through: :meeting_session
  has_one  :season,       through: :meeting_session
  has_one  :season_type,  through: :meeting_session
  has_one  :stroke_type,  through: :event_type

  has_many :meeting_programs, dependent: :delete_all
  has_many :meeting_entries,            through: :meeting_programs
  has_many :meeting_individual_results, through: :meeting_programs
  has_many :meeting_relay_results,      through: :meeting_programs

  has_many :meeting_event_reservations, dependent: :delete_all
  has_many :meeting_relay_reservations, dependent: :delete_all

  has_many :category_types, through: :meeting_programs


# For Rails 4+, move required/permitted check to the controller using the model
#  attr_accessible :event_order, :begin_time, :is_out_of_race, :is_autofilled, :notes,
#                  :meeting_session_id, :event_type_id, :heat_type_id, :has_separate_gender_start_list,
#                  :has_separate_category_start_list, :user_id

  scope :sort_by_order,    ->(dir = 'ASC') { order("event_order #{dir.to_s}") }

  scope :only_relays,      -> { joins(:event_type).includes(:event_type).where('event_types.is_a_relay' => true) }
  scope :are_not_relays,   -> { joins(:event_type).includes(:event_type).where('event_types.is_a_relay' => false) }

  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------

  # Computes a shorter description for the name associated with this data
  def get_full_name
    "#{event_type.i18n_short} (#{get_scheduled_date})"
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "#{event_type.i18n_description} (#{event_order} @ #{get_scheduled_date})"
  end
  # ----------------------------------------------------------------------------

  # Retrieves the user name associated with this instance
  def user_name
    self.user ? self.user.name : ''
  end
  # ----------------------------------------------------------------------------

  # Retrieves the Meeting Session scheduled_date
  def get_scheduled_date
    self.meeting_session ? self.meeting_session.scheduled_date : '?'
  end
  # ----------------------------------------------------------------------------

  # Retrieves the Meeting Session short name (includes Meeting name)
  def get_meeting_session_name
    self.meeting_session ? self.meeting_session.get_full_name() : '?'
  end

  # Retrieves the Meeting Session verbose name (includes Meeting name)
  def get_meeting_session_verbose_name
    self.meeting_session ? self.meeting_session.get_verbose_name() : '?'
  end
  # ----------------------------------------------------------------------------
end
