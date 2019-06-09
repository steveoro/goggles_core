# frozen_string_literal: true

require 'wrappers/timing'

#
# = UserResult model
#
#   - version:  6.069
#   - author:   Steve A.
#
class UserResult < ApplicationRecord

  # XXX [Steve, 20170130] We don't care anymore (so much) about these updates: commented out
  #  after_create    UserContentLogger.new('user_results')
  #  after_update    UserContentLogger.new('user_results')
  #  before_destroy  UserContentLogger.new('user_results')

  include TimingGettable
  include TimingValidatable

  belongs_to :user # [Steve, 20120212] Do not validate associated user!

  belongs_to :swimmer
  belongs_to :category_type
  belongs_to :pool_type
  belongs_to :event_type
  belongs_to :meeting_individual_result
  validates_associated :swimmer
  validates_associated :category_type
  validates_associated :pool_type
  validates_associated :event_type
  validates_associated :meeting_individual_result

  belongs_to :disqualification_code_type
  # Duplicate (shortcut) reference that may be filled-in at a later stage:
  validates :description, presence: true
  validates :description, length: { within: 1..60, allow_nil: false }

  validates :standard_points, presence: true
  validates :standard_points, numericality: true
  validates :meeting_points, presence: true
  validates :meeting_points, numericality: true

  validates :rank, presence: true
  validates :rank, length: { within: 1..5, allow_nil: false }
  validates :rank, numericality: true

  validates     :is_disqualified, presence: true

  validates     :reaction_time, presence: true
  validates :reaction_time, numericality: true

  # FIXME: for Rails 4+, move required/permitted check to the controller using the model
  #  attr_accessible :user_id, :swimmer_id, :category_type_id, :pool_type_id,
  #                  :event_type_id, :meeting_individual_result_id,
  #                  :disqualification_code_type_id,
  #                  :description, :standard_points, :meeting_points, :rank,
  #                  :is_disqualified, :reaction_time

  delegate :name, to: :user, prefix: true

  scope :sort_by_user,          ->(dir) { order("users.name #{dir}, meetings.description #{dir}, swimmers.last_name #{dir}, swimmers.first_name #{dir}") }
  scope :sort_by_category_type, ->(dir) { order("category_types.code #{dir},swimmers.last_name #{dir}, swimmers.first_name #{dir}") }
  scope :sort_by_swimmer,       ->(dir) { order("swimmers.last_name #{dir}, swimmers.first_name #{dir}, meeting_individual_results.rank #{dir}") }
  #-- -------------------------------------------------------------------------
  #++

  # Computes a shorter description for the name associated with this data
  def get_full_name
    "#{get_scheduled_date} #{get_event_type}: #{rank}) #{swimmer.get_full_name}, #{get_timing}"
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "#{description}: #{rank}) #{swimmer.get_verbose_name}), #{minutes}'#{seconds}""#{hundreds}"
  end
  #-- -------------------------------------------------------------------------
  #++

  # Retrieves the localized Event Type code
  def get_event_type
    event_type ? event_type.i18n_short : '?'
  end

  # Retrieves the scheduled_date of this result
  def get_scheduled_date
    event_date ? Format.a_date(event_date) : '?'
  end
  #-- -------------------------------------------------------------------------
  #++

end
