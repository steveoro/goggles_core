# frozen_string_literal: true

require 'wrappers/timing'

#
# == MeetingRelaySwimmer
#
# Model class
#
# @author   Steve A.
# @version  4.00.341
#
class MeetingRelaySwimmer < ApplicationRecord

  include SwimmerRelatable
  include TimingGettable
  include TimingValidatable

  belongs_to :user # [Steve, 20120212] Do not validate associated user!

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

  validates :relay_order, presence: true
  validates :relay_order, length: { within: 1..3, allow_nil: false }
  validates :relay_order, numericality: true

  validates :reaction_time, presence: true
  validates :reaction_time, numericality: true

  scope :sort_by_user,            ->(dir) { order("users.name #{dir}") }
  scope :sort_by_swimmer_name,    ->(dir) { order("swimmer.last_name #{dir}, swimmer.first_name #{dir}") }
  scope :sort_by_badge,           ->(dir) { order("badge.number #{dir}") }
  scope :sort_by_stroke_type,     ->(dir) { order("stroke_type.code #{dir}") }
  scope :sort_by_order,           ->(dir = 'ASC') { order("relay_order #{dir}") }

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
    user ? user.name : ''
  end
  # ----------------------------------------------------------------------------

  # Retrieves the localized Event Type code
  def get_event_type
    meeting_program ? meeting_program.event_type.i18n_short : '?'
  end

  # Retrieves the Meeting Relay Swimmer name
  def get_swimmer_name
    swimmer ? swimmer.get_full_name : '?'
  end

  # Retrieves the localized Stroke Type code
  def get_stroke_type
    stroke_type ? stroke_type.i18n_short : '?'
  end
  # ----------------------------------------------------------------------------

end
