# encoding: utf-8
require 'wrappers/timing'


=begin

= UserTrainingRow

  - version:  4.00.523
  - author:   Steve A., Leega

=end
class UserTrainingRow < ApplicationRecord
  after_create    UserContentLogger.new('user_training_rows')
  after_update    UserContentLogger.new('user_training_rows')
  before_destroy  UserContentLogger.new('user_training_rows')

  belongs_to :user_training
  belongs_to :exercise
  belongs_to :training_step_type
  belongs_to :arm_aux_type
  belongs_to :kick_aux_type
  belongs_to :body_aux_type
  belongs_to :breath_aux_type
  validates_associated :user_training
  validates_associated :exercise
  validates_associated :training_step_type
  validates_associated :arm_aux_type
  validates_associated :kick_aux_type
  validates_associated :body_aux_type
  validates_associated :breath_aux_type

  has_many :exercise_rows,      through: :exercise
  has_many :base_movements,     through: :exercise_rows
  has_many :training_mode_type, through: :exercise_rows

  validates_presence_of     :group_id
  validates_length_of       :group_id, within: 1..3, allow_nil: false
  validates_numericality_of :group_id
  validates_presence_of     :group_times
  validates_length_of       :group_times, within: 1..3, allow_nil: false
  validates_numericality_of :group_times
  validates_presence_of     :group_start_and_rest
  validates_length_of       :group_start_and_rest, within: 1..4, allow_nil: false
  validates_numericality_of :group_start_and_rest
  validates_presence_of     :group_pause
  validates_length_of       :group_pause, within: 1..4, allow_nil: false
  validates_numericality_of :group_pause

  validates_presence_of     :part_order
  validates_length_of       :part_order, within: 1..3, allow_nil: false
  validates_numericality_of :part_order
  validates_presence_of     :times
  validates_length_of       :times, within: 1..3, allow_nil: false
  validates_numericality_of :times
  validates_presence_of     :distance
  validates_length_of       :distance, within: 1..4, allow_nil: false
  validates_numericality_of :distance
  validates_presence_of     :start_and_rest
  validates_length_of       :start_and_rest, within: 1..4, allow_nil: false
  validates_numericality_of :start_and_rest
  validates_presence_of     :pause
  validates_length_of       :pause, within: 1..4, allow_nil: false
  validates_numericality_of :pause

  delegate :code, to: :training_step_type, prefix: true

# FIXME for Rails 4+, move required/permitted check to the controller using the model
#  attr_accessible :part_order,
#                  :group_id, :group_times, :group_start_and_rest, :group_pause,
#                  :times, :distance, :start_and_rest, :pause,
#                  :user_training_id, :exercise_id, :training_step_type_id,
#                  :arm_aux_type_id, :kick_aux_type_id, :body_aux_type_id, :breath_aux_type_id

  scope :sort_by_part_order,    -> { order('part_order') }
  scope :with_groups,           -> { where('group_id > 0').order('part_order') }
  scope :without_groups,        -> { where('(group_id is null) or (group_id = 0)').order('part_order') }
  scope :for_training_step_code, ->(training_step_code) { includes(:training_step_type).where(['training_step_types.code = ?', training_step_code]) }


  # Overload constructor for setting default values
  #
  def initialize( options = {} )
    super( options )
    self.part_order = 1 unless self.part_order.to_i != 0
    self.times = 1      unless self.times.to_i > 0
    self.distance = 50  unless self.distance.to_i > 0
  end
  #-- -------------------------------------------------------------------------
  #++


  # Memoized (lazy-loaded & cached) value of #compute_distance()
  def full_row_distance
    @full_row_distance ||= compute_distance()
  end

  # Computes the value of the total distance in metres for this training row
  # For this method, the result value does *NOT* include the times multiplier.
  #
  # Note also that this method will not consider any additional multiplier given by
  # any training_group linked by this row.
  # Training groups should be checked for existance and managed elsewhere, for example
  # during ouput formatting or in other parent entities.
  #
  def compute_distance
    if exercise_rows
      exercise_rows.sort_by_part_order.inject(0){ |sum, row|
        actual_row_distance = row.compute_displayable_distance( distance ).to_i
        actual_row_distance = distance if actual_row_distance == 0
        sum + actual_row_distance
      }
    else
      distance
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  # Memoized (lazy-loaded & cached) value of #compute_total_seconds()
  def full_row_seconds
    @full_row_seconds ||= compute_total_seconds()
  end

  # Computes the esteemed total seconds of expected duration for this training row.
  # For this method, the result value *ALREADY* includes the times multiplier.
  #
  # Field start_and_rest has the precedence on everything else, unless pre-defined
  # exercise_row distances or start_and_rest values are specified.
  #
  # When the internal row distance is set, it returns an esteemed duration (based on a slow-pace).
  # In case the distance or the start_and_rest member are not set, returns the pause member.
  #
  # Note also that this method will not consider any additional multiplier given by
  # any training_group linked by this row.
  # Training groups should be checked for existance and managed elsewhere, for example
  # during ouput formatting or in other parent entities.
  #
  def compute_total_seconds
    exercise_seconds = exercise_rows.inject(0){ |sum, row|
      sum + row.compute_total_seconds()             # (default: exclude pause from sum)
    }
    if ( exercise_seconds == 0 )                    # Found zero esteemed duration (excluding pause) ?
      if ( start_and_rest > 0 )
        start_and_rest * times + (pause * times)
      elsif ( distance > 0 )
        ( pause + ExerciseRow.esteem_time_in_seconds(distance) ) * times
      else
        pause * times
      end
    else
      exercise_rows.inject(0){ |sum, row|
        sum + row.compute_total_seconds(true)       # (include pause)
      } * times + (pause * times)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Generic group-oriented implementation for <tt>compute_total_seconds</tt>
  # for a bunch of TrainingRow instances.
  #
  # Computes the esteemed total seconds of expected duration for the
  # specified array of training rows.
  #
  # For this method, the result value *ALREADY* includes the group_times
  # multiplier.
  # This can be used, for instance, with arrays of grouped or filtered training rows.
  #
  # === Params:
  # - training_rows: the array of TrainingRow instances to be processed.
  #
  def self.compute_total_seconds( training_rows )
    # [Steve, 20140203] ASSUMES grouping information comes only from the first row
    group_times = training_rows.first.group_times   # Extract grouping information
    group_start_and_rest = training_rows.first.group_start_and_rest
    group_pause = training_rows.first.group_pause

    group_secs = training_rows.inject(0){ |sum, row|
        sum + row.full_row_seconds
    } * group_times
                                                    # Zero esteemed computation on exercise rows?
    if ( group_secs == 0 )
      if ( group_start_and_rest > 0 )
        group_start_and_rest * group_times + (group_pause * group_times)
      else
        group_pause * group_times
      end
    else
      group_secs + (group_pause * group_times)
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
