require 'wrappers/timing'
require 'swimmer_relatable'
require 'timing_gettable'
require 'timing_validatable'


#
# == MeetingRelaySwimmer
#
# Model class
#
# @author   Steve A.
# @version  4.00.341
#
class MeetingRelaySwimmer < ActiveRecord::Base
  include SwimmerRelatable
  include TimingGettable
  include TimingValidatable

  belongs_to :user                                  # [Steve, 20120212] Do not validate associated user!

  belongs_to :meeting_relay_result
  belongs_to :badge
  belongs_to :stroke_type

  validates_associated :meeting_relay_result
  validates_associated :badge
  validates_associated :stroke_type

  has_one  :meeting,          through: :meeting_relay_result
  has_one  :meeting_session,  through: :meeting_relay_result
  has_one  :meeting_event,    through: :meeting_relay_result
  has_one  :meeting_program,  through: :meeting_relay_result
  has_one  :team,             through: :badge

  has_one  :event_type,       through: :meeting_relay_result

  validates_presence_of     :relay_order
  validates_length_of       :relay_order, within: 1..3, allow_nil: false
  validates_numericality_of :relay_order

  validates_presence_of     :reaction_time
  validates_numericality_of :reaction_time

  scope :sort_by_user,            ->(dir) { order("users.name #{dir.to_s}") }
  scope :sort_by_swimmer_name,    ->(dir) { order("swimmer.last_name #{dir.to_s}, swimmer.first_name #{dir.to_s}") }
  scope :sort_by_badge,           ->(dir) { order("badge.number #{dir.to_s}") }
  scope :sort_by_stroke_type,     ->(dir) { order("stroke_type.code #{dir.to_s}") }
  scope :sort_by_order,           ->(dir = 'ASC') { order("relay_order #{dir.to_s}") }


  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------


  # Computes a shorter description for the name associated with this data
  def get_full_name
    "#{get_event_type}: #{relay_order}, #{get_swimmer_name}"
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "#{get_event_type}: #{relay_order} (#{get_stroke_type}) #{get_swimmer_name}"
  end

  # Retrieves the user name associated with this instance
  def user_name
    self.user ? self.user.name : ''
  end
  # ----------------------------------------------------------------------------

  # Retrieves the localized Event Type code
  def get_event_type
    self.meeting_program ? self.meeting_program.event_type.i18n_short : '?'
  end

  # Retrieves the Meeting Relay Swimmer name
  def get_swimmer_name
    self.swimmer ? self.swimmer.get_full_name() : '?'
  end

  # Retrieves the localized Stroke Type code
  def get_stroke_type
    self.stroke_type ? self.stroke_type.i18n_short : '?'
  end
  # ----------------------------------------------------------------------------
end
