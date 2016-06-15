# encoding: utf-8
require 'drop_down_listable'
require 'wrappers/timing'


class ExerciseRow < ActiveRecord::Base
  include DropDownListable

  belongs_to :exercise
  belongs_to :base_movement
  belongs_to :training_mode_type
  belongs_to :execution_note_type
  validates_associated :exercise
  validates_associated :base_movement
  validates_associated :training_mode_type
  validates_associated :execution_note_type
  
  has_one :movement_type, through: :base_movement

  validates_presence_of     :part_order, length: { within: 1..3 }, allow_nil: false
  validates_numericality_of :part_order
  validates_presence_of     :percentage, length: { within: 1..3 }, allow_nil: false
  validates_numericality_of :percentage
  # [Steve, 20140128] An exercise_row may or may not have a pre-defined distance
  # When left == 0, distance is assumed to be specified either by training_row.distance
  # itself or computed from the percentage field applied to it (training_row.distance).
  validates_presence_of     :distance, length: { within: 1..4 }, allow_nil: false
  validates_numericality_of :distance
  validates_presence_of     :start_and_rest, length: { within: 1..4 }, allow_nil: false
  validates_numericality_of :start_and_rest
  validates_presence_of     :pause, length: { within: 1..4 }, allow_nil: false
  validates_numericality_of :pause

  delegate :code, :i18n_short,     to: :base_movement,      prefix: true
  delegate :code, :i18n_alternate, to: :training_mode_type, prefix: true

  scope :sort_by_part_order, -> { order('part_order') }
  #-- -------------------------------------------------------------------------
  #++


  # Commodity shortcut to ExerciseRowDecorator#get_full_name().
  #
  # In the default invocation by self.to_dropdown() all parameters are omitted and
  # their defaults are used.
  #
  # === Params:
  # - total_distance: can be 0 if it must be obtained from each component
  # - verbose_level: either :short, :full or :verbose; default: :full
  # - swimmer_level_type_id: the id of the user's swimmer level type (or its preferred swimmer level type ID); NOT the code, NOT the level: the *ID*; it can be 0 if it must be ignored
  # - show_also_ordinal_part: true to show also the part_order; defaults to false.
  #
  def get_full_name( total_distance = 0, verbose_level = :short, swimmer_level_type_id = 0, show_also_ordinal_part = false )
    ExerciseRowDecorator.decorate( self ).get_full_name( total_distance, verbose_level, swimmer_level_type_id, show_also_ordinal_part )
  end
  #-- -------------------------------------------------------------------------
  #++


  # Label symbol corresponding to either a column name or a model method to be used
  # mainly in generating DropDown option lists.
  #
  # @overload inherited from DropDownListable
  #
  def self.get_label_symbol
    :get_full_name
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the esteemed total seconds of execution for the specified distance
  # in metres.
  #
  def self.esteem_time_in_seconds( distance_in_mt, mt_per_sec = 1.2 )
    distance_in_mt.to_i > 0 ? (distance_in_mt.to_f * mt_per_sec).to_i : 0
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns a displayable (string) computed distance for this exercise row.
  # Parameter total_distance is assumed to refer to the external (training row) distance
  # set by the entity that is referring this exercise row.
  #
  # If the total "external" distance is specified but the percentage of this row is 100%,
  # an empty string is returned, assuming the total_distance will be displayed elsewhere
  # (since it is externally provided).
  #
  # Note that if the member distance is set to this row, it will take
  # precedence over the computed distance (obtained applying the percentage field
  # to the "external" total_distance).
  #
  def compute_displayable_distance( total_distance = 0 )
# DEBUG
#    puts "-- compute_displayable_distance( #{total_distance.inspect} ) called."
    if ( distance > 0 )
      distance.to_s
    else
      if ( total_distance > 0 )
        ( percentage < 100 ? "#{sprintf("%02s", total_distance * percentage / 100)}" : '' )
      else
        ( percentage < 100 ? "#{sprintf("%02s", self.percentage)}%" : '' )
      end
    end
  end


  # Returns the esteemed total seconds of expected duration for this exercise row.
  #
  # Field start_and_rest has the precedence on everything else.
  # When the internal row distance is set, it returns an esteemed duration (based on a slow-pace).
  #
  # In case the distance or the start_and_rest member are not set,
  # returns 0 or the pause member, if with_pause parameter is set to true .
  #
  def compute_total_seconds( with_pause = false )
    if start_and_rest > 0
      start_and_rest
    else                                            # Compute expected duration based on distance:
      result = ExerciseRow.esteem_time_in_seconds( distance )
      with_pause ? result + pause : result
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
