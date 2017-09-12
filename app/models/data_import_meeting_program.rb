require 'wrappers/timing'
require 'timing_gettable'
#require 'data_importable'


class DataImportMeetingProgram < ApplicationRecord
  include TimingGettable                            # (Base timing may not be available)
  include DataImportable

  belongs_to :user                                  # [Steve, 20120212] Do not validate associated user!

  belongs_to :meeting_program, foreign_key: "conflicting_id"

  validates_presence_of :import_text

  belongs_to :meeting_session
  belongs_to :data_import_meeting_session
  belongs_to :category_type
  belongs_to :gender_type
  belongs_to :event_type
  belongs_to :heat_type
  belongs_to :time_standard

  validates_associated :category_type
  validates_associated :gender_type
  validates_associated :event_type
  validates_associated :heat_type

  has_one  :stroke_type, through: :event_type

  has_many :meeting_individual_results
  has_many :data_import_meeting_individual_results

  has_many :meeting_relay_results
  has_many :data_import_meeting_relay_results

  has_many :meeting_relay_swimmers
  has_many :data_import_meeting_relay_swimmers

  # This is used as an helper for the factory tests:
  has_one  :meeting, through: :meeting_session

  validates_presence_of :event_order
  validates_length_of   :event_order, within: 1..3, allow_nil: false

#  attr_accessible :data_import_session_id, :import_text, :conflicting_id,
#                  :user, :user_id,
#                  :event_order, :begin_time,
#                  :data_import_meeting_session_id, :meeting_session_id,
#                  :event_type_id, :category_type_id, :gender_type_id,
#                  :minutes, :seconds, :hundreds,
#                  :is_out_of_race, :heat_type_id, :time_standard_id

  scope :only_relays,             -> { includes(:event_type).where('event_types.is_a_relay' => true) }
  scope :are_not_relays,          -> { includes(:event_type).where('event_types.is_a_relay' => false) }

  scope :sort_by_user,            ->(dir) { order("users.name #{dir.to_s}") }
  scope :sort_by_event_type,      ->(dir) { order("event_types.code #{dir.to_s}") }
  scope :sort_by_category_type,   ->(dir) { order("category_types.code #{dir.to_s}") }
  scope :sort_by_gender_type,     ->(dir) { order("gender_type.code #{dir.to_s}") }


  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------


  # Computes a short description of just the event name for this row, without dates.
  def get_event_name
    "(#{event_order}) #{event_type.i18n_short} #{get_category_type_code} #{gender_type.i18n_short}"
  end

  # Computes a verbose description of just the event name for this row, without dates.
  def get_verbose_event_name
    "(#{I18n.t(:event)} #{event_order}) #{event_type.i18n_description} #{get_category_type_name} #{gender_type.i18n_description}"
  end

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

  # Retrieves the user name associated with this instance
  def user_name
    self.user ? self.user.name : ''
  end
  # ----------------------------------------------------------------------------

  # Getter for short display name of Category + Gender.
  def get_category_and_gender_short
    "#{get_category_type_name} #{gender_type.i18n_short}"
  end

  # Retrieves the Category Type code
  def get_category_type_code
    self.category_type ? self.category_type.code : '?'
  end

  # Retrieves the Category Type short name
  def get_category_type_name
    self.category_type ? self.category_type.short_name : '?'
  end

  # Retrieves the Meeting Session scheduled_date
  def get_scheduled_date
    self.meeting_session ? self.meeting_session.scheduled_date : (self.data_import_meeting_session ? self.data_import_meeting_session.scheduled_date : '?')
  end

  # Retrieves the Meeting Session short name (includes Meeting name)
  def get_meeting_session_name
    self.meeting_session ? self.meeting_session.get_full_name() : (self.data_import_meeting_session ? self.data_import_meeting_session.get_full_name() : '?')
  end

  # Retrieves the Meeting Session verbose name (includes Meeting name)
  def get_meeting_session_verbose_name
    self.meeting_session ? self.meeting_session.get_verbose_name() : (self.data_import_meeting_session ? self.data_import_meeting_session.get_verbose_name() : '?')
  end
  # ----------------------------------------------------------------------------

end
