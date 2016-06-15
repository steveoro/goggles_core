# encoding: utf-8


=begin

= MeetingSession

  - version:  4.00.399
  - author:   Steve A., Leega

=end
class MeetingSession < ActiveRecord::Base
  include MeetingAccountable

  belongs_to :user
  # [Steve, 20120212] Validating on User fails always because of validation requirements inside User (password & salt)
#  validates_associated :user                       # (Do not enable this for User)

  belongs_to :meeting
  belongs_to :swimming_pool
  belongs_to :day_part_type
  validates_associated :meeting
  # [Steve, 20131028] Cannot enable validation on :swimming_pool, since it can be null
  # [Steve, 20131028] Cannot enable validation on :day_part_type, since it can be null

  has_one  :pool_type,   through: :swimming_pool
  has_one  :season,      through: :meeting
  has_one  :season_type, through: :meeting

  has_many :meeting_events, dependent: :delete_all
  has_many :meeting_programs, through: :meeting_events, dependent: :delete_all
  has_many :meeting_entries, through: :meeting_events, dependent: :delete_all
  has_many :meeting_individual_results, through: :meeting_programs, dependent: :delete_all

  validates_presence_of :session_order
  validates_length_of   :session_order, within: 1..2, allow_nil: false

  validates_presence_of :scheduled_date

  validates_presence_of :description
  validates_length_of :description, maximum: 100, allow_nil: false


  attr_accessible :session_order, :scheduled_date, :warm_up_time, :begin_time,
                  :notes, :meeting_id, :swimming_pool_id, :user_id, :description,
                  :is_autofilled, :day_part_type_id


  scope :sort_meeting_session_by_user,          ->(dir) { order("users.name #{dir.to_s}, meeting_sessions.scheduled_date #{dir.to_s}") }
  scope :sort_meeting_session_by_meeting,       ->(dir) { order("meetings.description #{dir.to_s}, meeting_sessions.session_order #{dir.to_s}") }
  scope :sort_meeting_session_by_swimming_pool, ->(dir) { order("swimming_pools.nick_name #{dir.to_s}, meeting_sessions.scheduled_date #{dir.to_s}") }
  scope :sort_by_order,                         ->(dir = 'ASC') { order("meeting_sessions.session_order #{dir.to_s}") }


  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------
  #++

  # Computes a short description for the meeting session comprehensive of short day part and event list
  # Eg MNG: 200SL, 100FA, 50DO, 4x50MX
  #
  def get_short_name
    "#{get_day_part_type(:i18n_short)}: #{get_short_events}"
  end

  # Computes a full description for the meeting session comprehensive of date, day part and event list
  # Eg 25/05/2014 MORNING: 200SL, 100FA, 50DO, 4x50MX FINALS
  #
  def get_full_name
    "#{get_scheduled_date} #{get_day_part_type}: #{get_short_events} #{description}"
  end

  # Computes a full description for the meeting session comprehensive of date, day part, time schedule and event list
  # Eg 25/05/2014 - 9.30[8.30]: 200SL, 100FA, 50DO, 4x50MX FINALS
  #
  def get_verbose_name
    "#{get_scheduled_date} -  #{get_day_part_type} #{get_begin_time}[#{get_warm_up_time}]: #{get_short_events} #{description}"
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the formatted scheduled date for the session.
  # Scheduled date can't be blank.
  #
  def get_scheduled_date
    Format.a_date(scheduled_date)
  end

  # Retrieve the warm_up time for the session, if any
  # If no warm_up time defined returns international 'nd'
  #
  def get_warm_up_time
    warm_up_time && Format.a_time(warm_up_time) != '00:00' ? Format.a_time(warm_up_time) : ''
  end

  # Retrieve the begin time for the session, if any
  # If no begin time defined returns international 'nd'
  #
  def get_begin_time
    begin_time && Format.a_time(begin_time) != '00:00' ? Format.a_time(begin_time) : ''
  end
  #-- -------------------------------------------------------------------------
  #++

  # Retrieves the Meeting session swimming pool length in meters, or 0 if any
  # E.g.: 50
  #
  def get_pool_length_in_meters
    SwimmingPoolDecorator.decorate(swimming_pool).get_pool_length_in_meters
  end

  # Retrieves the Meeting session swimming pool lane number, or 0 if any
  # E.g.: 8
  #
  def get_pool_lanes_number
    SwimmingPoolDecorator.decorate(swimming_pool).get_pool_lanes_number
  end

  # Compose the swimming pool attributes (lanes_number x length_in_meters)
  # E.g.: "(8x50)"
  #
  def get_pool_attributes
    SwimmingPoolDecorator.decorate(swimming_pool).get_pool_attributes
  end

  # Retrieves the Meeting session swimming pool full description
  # E.g.: "Comunale Reggio Emilia (8x50)"
  #
  def get_pool_full_description
    SwimmingPoolDecorator.decorate(swimming_pool).get_full_address
  end
  #-- -------------------------------------------------------------------------
  #++

  # Computes a shorter description for the name associated with this data
  # Used by import steps to identify session
  #
  def get_order_with_date
    "n.#{session_order} (#{get_scheduled_date})"
  end
  #-- -------------------------------------------------------------------------
  #++

  # Retrieves the user name associated with this instance
  #
  def user_name
    user ? user.name : ''
  end
  #-- -------------------------------------------------------------------------
  #++

  # Safety getter for the DayPartType name
  #
  def get_day_part_type( label_method = :i18n_description )
    day_part_type.respond_to?( label_method ) ? day_part_type.send(label_method) : ''
  end

  # Retrieves the Meeting short name
  # Used by import steps to identify session
  #
  def get_meeting_name
    meeting ? meeting.get_short_name : '?'
  end

  # Retrieves the Meeting verbose name
  # Used by import steps to identify session
  #
  def get_meeting_verbose_name
    meeting ? meeting.get_verbose_name : '?'
  end
  #-- -------------------------------------------------------------------------
  #++


  # Retrieves the meeting EventType list as an Array.
  # E.g.: 200FS, 100BF, 50BS, 4x50IM
  #
  def get_event_types
    meeting_events ? meeting_events.sort_by_order.includes(:event_type).joins(:event_type).map{ |row| row.event_type } : []
  end

  # Retrieves the meeting event list, each as a customizable separated short description.
  # E.g.: '200FS, 100BF, 50BS, 4x50IM'
  # Returns an empty string for no event list.
  #
  def get_short_events( separator = ', ')
    get_event_types.map{ |event_type| event_type.i18n_compact }.join( separator )
  end
  #-- -------------------------------------------------------------------------
  #++
end
