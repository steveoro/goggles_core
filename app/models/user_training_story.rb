# frozen_string_literal: true

#
# = UserTrainingStory model
#
#   - version:  4.00.523
#   - author:   Steve A.
#
class UserTrainingStory < ApplicationRecord

  after_create    UserContentLogger.new('user_training_stories')
  after_update    UserContentLogger.new('user_training_stories')
  before_destroy  UserContentLogger.new('user_training_stories')

  include TrainingSharable # (This adds also a belongs_to :user clause)

  belongs_to :user_training
  belongs_to :swimmer_level_type
  belongs_to :swimming_pool
  validates_associated :user_training
  validates_associated :swimmer_level_type
  validates_associated :swimming_pool

  validates :swam_date, presence: true

  validates :total_training_time, presence: true
  validates :total_training_time, length: { within: 1..6, allow_nil: false }
  validates :total_training_time, numericality: true

  delegate :name, to: :user, prefix: true

  # FIXME: for Rails 4+, move required/permitted check to the controller using the model
  #  attr_accessible :swam_date, :total_training_time, :notes,
  #                  :user_training_id, :swimming_pool_id, :swimmer_level_type_id

  scope :sort_by_date,        -> { order('swam_date') }
  scope :sort_by_duration,    -> { order('total_training_time') }
  #-- -------------------------------------------------------------------------
  #++

  # Retrieves the User short name (the owner of this UserTrainingStory)
  # @ deprecated
  def get_user_name
    user ? user.name : ''
  end
  #-- -------------------------------------------------------------------------
  #++

end
