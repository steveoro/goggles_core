# frozen_string_literal: true

# require 'data_importable'

class DataImportMeetingSession < ApplicationRecord

  include DataImportable

  belongs_to :user # [Steve, 20120212] Do not validate associated user!

  belongs_to :meeting_session, foreign_key: 'conflicting_id', optional: true

  validates :import_text, presence: true

  belongs_to :data_import_meeting, optional: true
  belongs_to :meeting, optional: true
  belongs_to :swimming_pool, optional: true
  belongs_to :day_part_type, optional: true
  # [Steve, 20131028] Cannot enable validation on :swimming_pool, :day_part_type, since they can be null
  # [Steve, 20131114] Cannot enable validation on :meeting, :data_import_meeting, since they can be null (not both)

  has_many :meeting_programs
  has_many :data_import_meeting_programs

  has_many :meeting_individual_results,             through: :meeting_programs
  has_many :data_import_meeting_individual_results, through: :data_import_meeting_programs

  validates :session_order, presence: true
  validates :session_order, length: { within: 1..2, allow_nil: false }

  validates :scheduled_date, presence: true

  validates :description, presence: true
  validates :description, length: { maximum: 100, allow_nil: false }

  #  attr_accessible :data_import_session_id, :import_text, :conflicting_id,
  #                  :user, :user_id,
  #                  :session_order, :scheduled_date, :warm_up_time, :begin_time,
  #                  :notes,
  #                  :data_import_meeting_id, :meeting_id, :swimming_pool_id, :description,
  #                  :day_part_type_id

  scope :sort_by_user,          ->(dir) { order("users.name #{dir}, data_import_meeting_sessions.scheduled_date #{dir}") }
  scope :sort_by_meeting,       ->(dir) { order("meetings.description #{dir}, data_import_meeting_sessions.session_order #{dir}") }
  scope :sort_by_swimming_pool, ->(dir) { order("swimming_pools.nick_name #{dir}, data_import_meeting_sessions.scheduled_date #{dir}") }

  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------

  # Computes a shorter description for the name associated with this data
  def get_full_name
    "#{get_meeting_name} (#{Format.a_date(scheduled_date)})"
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "#{get_meeting_verbose_name} (#{session_order} @ #{Format.a_date(scheduled_date)})"
  end

  # Retrieves the user name associated with this instance
  def user_name
    user ? user.name : ''
  end
  # ----------------------------------------------------------------------------

  # Retrieves the Meeting short name
  def get_meeting_name
    meeting ? meeting.get_short_name : (data_import_meeting ? data_import_meeting.get_short_name : '?')
  end

  # Retrieves the Meeting verbose name
  def get_meeting_verbose_name
    meeting ? meeting.get_verbose_name : (data_import_meeting ? data_import_meeting.get_verbose_name : '?')
  end
  # ----------------------------------------------------------------------------

end
