#require 'data_importable'


class DataImportMeetingSession < ApplicationRecord
  include DataImportable

  belongs_to :user                                  # [Steve, 20120212] Do not validate associated user!

  belongs_to :meeting_session, foreign_key: "conflicting_id"

  validates_presence_of :import_text

  belongs_to :data_import_meeting
  belongs_to :meeting
  belongs_to :swimming_pool
  belongs_to :day_part_type
  # [Steve, 20131028] Cannot enable validation on :swimming_pool, :day_part_type, since they can be null
  # [Steve, 20131114] Cannot enable validation on :meeting, :data_import_meeting, since they can be null (not both)

  has_many :meeting_programs
  has_many :data_import_meeting_programs

  has_many :meeting_individual_results,             through: :meeting_programs
  has_many :data_import_meeting_individual_results, through: :data_import_meeting_programs

  validates_presence_of :session_order
  validates_length_of   :session_order, within: 1..2, allow_nil: false

  validates_presence_of :scheduled_date

  validates_presence_of :description
  validates_length_of :description, maximum: 100, allow_nil: false

#  attr_accessible :data_import_session_id, :import_text, :conflicting_id,
#                  :user, :user_id,
#                  :session_order, :scheduled_date, :warm_up_time, :begin_time,
#                  :notes,
#                  :data_import_meeting_id, :meeting_id, :swimming_pool_id, :description,
#                  :day_part_type_id

  scope :sort_by_user,          ->(dir) { order("users.name #{dir.to_s}, data_import_meeting_sessions.scheduled_date #{dir.to_s}") }
  scope :sort_by_meeting,       ->(dir) { order("meetings.description #{dir.to_s}, data_import_meeting_sessions.session_order #{dir.to_s}") }
  scope :sort_by_swimming_pool, ->(dir) { order("swimming_pools.nick_name #{dir.to_s}, data_import_meeting_sessions.scheduled_date #{dir.to_s}") }


  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------


  # Computes a shorter description for the name associated with this data
  def get_full_name
    "#{get_meeting_name} (#{Format.a_date( self.scheduled_date )})"
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "#{get_meeting_verbose_name} (#{session_order} @ #{Format.a_date( self.scheduled_date )})"
  end

  # Retrieves the user name associated with this instance
  def user_name
    self.user ? self.user.name : ''
  end
  # ----------------------------------------------------------------------------

  # Retrieves the Meeting short name
  def get_meeting_name
    self.meeting ? self.meeting.get_short_name() : (self.data_import_meeting ? self.data_import_meeting.get_short_name() : '?')
  end

  # Retrieves the Meeting verbose name
  def get_meeting_verbose_name
    self.meeting ? self.meeting.get_verbose_name() : (self.data_import_meeting ? self.data_import_meeting.get_verbose_name() : '?')
  end
  # ----------------------------------------------------------------------------

end
