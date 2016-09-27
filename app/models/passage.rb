require 'wrappers/timing'


#
# == Passage
#
# Model class
#
# @author   Leega, Steve A.
# @version  4.00.811
#
class Passage < ApplicationRecord
  include SwimmerRelatable
  include TimingGettable
  include TimingValidatable

  belongs_to :user                                  # [Steve, 20120212] Do not validate associated user!

  belongs_to :meeting_program
  belongs_to :passage_type
  belongs_to :team
  validates_associated :meeting_program
  validates_associated :passage_type
  validates_associated :team

  belongs_to :meeting_entry
  belongs_to :meeting_individual_result

  has_one :meeting,         through: :meeting_program
  has_one :event_type,      through: :meeting_program
  has_one :pool_type,       through: :meeting_program
#  has_one :badge,           through: :meeting_entry

  validates_presence_of     :minutes
  validates_length_of       :minutes, within: 1..3, allow_nil: false
  validates_numericality_of :minutes
  validates_presence_of     :seconds
  validates_length_of       :seconds, within: 1..2, allow_nil: false
  validates_numericality_of :seconds
  validates_presence_of     :hundreds
  validates_length_of       :hundreds, within: 1..2, allow_nil: false
  validates_numericality_of :hundreds
  #validates_presence_of     :reaction_time
  #validates_numericality_of :reaction_time
  #validates_presence_of     :stroke_cycles
  #validates_length_of       :stroke_cycles, within: 1..3, allow_nil: true
  #validates_numericality_of :stroke_cycles
  #validates_presence_of     :breath_number
  #validates_length_of       :breath_number, within: 1..3, allow_nil: true
  #validates_numericality_of :breath_number
  #validates_presence_of     :position
  #validates_length_of       :position, within: 1..4, allow_nil: true
  #validates_numericality_of :position
  #validates_presence_of     :not_swam_kick_number
  #validates_length_of       :not_swam_kick_number, within: 1..3, allow_nil: true
  #validates_numericality_of :not_swam_kick_number
  #validates_presence_of     :not_swam_part_seconds
  #validates_length_of       :not_swam_part_seconds, within: 1..2, allow_nil: true
  #validates_numericality_of :not_swam_part_seconds
  #validates_presence_of     :not_swam_part_hundreds
  #validates_length_of       :not_swam_part_hundreds, within: 1..2, allow_nil: true
  #validates_numericality_of :not_swam_part_hundreds

  scope :sort_by_user,       ->(dir) { order("users.name #{dir.to_s}, swimmer_id #{dir.to_s}") }
  scope :sort_by_distance,   -> { joins(:passage_type).order('passage_types.length_in_meters') }

  scope :for_event_type,     ->(event_type) { joins(:event_type).where(['event_types.id = ?', event_type.id]) }
#  scope :sort_by_program,    ->(dir) { order("meeting_programs.begin_time #{dir.to_s}, swimmers.last_name #{dir.to_s}, swimmers.first_name #{dir.to_s}") }
#  scope :sort_by_swimmer,    ->(dir) { order("swimmers.last_name #{dir.to_s}, swimmers.first_name #{dir.to_s}") }
#  scope :sort_by_type,       ->(dir) { order("passage_types.code #{dir.to_s}, swimmers.last_name #{dir.to_s}, swimmers.first_name #{dir.to_s}") }

  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------


  # Computes a shorter description for the name associated with this data
  def get_short_name
    "#{get_passage_distance}: #{get_timing}"
  end

  # Computes a full description for the name associated with this data
  def get_full_name
    "#{get_event_type}, #{get_passage_distance}: #{get_timing}"
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "#{get_swimmer_full_name} - #{get_scheduled_date} #{get_event_type}, #{get_passage_distance}: #{get_timing}"
  end

  # Retrieves the user name associated with this instance
  def get_user_name
    user ? user.name : ''
  end
  # ----------------------------------------------------------------------------

  # Retrieves the associated Swimmer full name
  def get_swimmer_full_name
    swimmer ? swimmer.get_full_name : '?'
  end

  ## Retrieves the associated Badge number
  #def get_badge_code
  #  self.badge ? self.badge.number : '?'
  #end

  # Retrieves the distance swam in the passage
  def get_passage_distance
    passage_type ? passage_type.length_in_meters : 0
  end

  # Retrieves the localized Event Type code
  def get_event_type
    meeting_program ? meeting_program.event_type.i18n_short : '?'
  end

  # Retrieves the scheduled_date of this result
  def get_scheduled_date                            # The following ActiveRecord chain is granted in existence by validation assertions: (even the first check could be avoided)
    meeting_program ? meeting_program.meeting_session.scheduled_date : '?'
    # [Steve, 20130710]
    # Provided the "has_one :meeting_session, through: :meeting_program" above, this should also work:
    # => return meeting_session.scheduled_date
  end

  # Retrieves the total event distance
  def get_total_distance
    meeting_program ? meeting_program.event_type.length_in_meters : 0
  end
  #-- -------------------------------------------------------------------------
  #++

  # Safe getter for the associated list of passages.
  # Returns an empty array when none are found.
  # (User #get_passages.count to get the total number of passages.)
  # Returns the list of Passage rows found.
  #
  def get_passages
    meeting_individual_result ? meeting_individual_result.get_passages : []
  end

  # Memoized getter for the complete list of previous passages
  #
  def get_all_previous_passages
    if get_total_distance > 400
      @all_previous_passages ||= get_passages.count > 0 ?
        get_passages.where( 'length_in_meters < ? and length_in_meters > 50', get_passage_distance ) :
        get_passages
    else
      @all_previous_passages ||=  get_passages.count > 0 ?
        get_passages.where( 'length_in_meters < ?', get_passage_distance ) :
        get_passages
    end
  end

  # Memoized getter for the previous passage instance
  #
  def get_previous_passage
    @previous_passage ||= get_all_previous_passages.last
  end
  #-- -------------------------------------------------------------------------
  #++

  # Get final time from meeting_individual_result
  # Differs from #compute_final_time, in that it computes the final time
  # by evaluating each passage.
  #
  def get_final_time
    meeting_individual_result ? meeting_individual_result.get_timing_instance : "#{compute_final_time} ***"
  end

  # Computes the distance swam for the passage.
  # The distance swam is the difference between the passage length in meters and
  # the previous passage length in meters.
  #
  def compute_distance_swam
    passage_distance = get_passage_distance
    previous_passage = get_previous_passage
    previous_passage ? passage_distance - previous_passage.get_passage_distance : passage_distance
  end

  # Computes the final time starting from the passages for a given result (event).
  # The final time is the sum of each single passage time among the list of associated
  # passages.
  #
  # Assumes passage times are correctly set.
  # Returns a Timing instance.
  #
  def compute_final_time
    passages_list = get_passages
    total_hundreds = passages_list.sum(:hundreds) + ( passages_list.sum(:seconds) * 100 ) + (passages_list.sum(:minutes) * 6000 )
    Timing.new( total_hundreds )
  end

  # Computes the total time for this passage, starting from the beginning of a given result (event).
  # This method returns the incremental time by summing all associated passages preceeding this one.
  # Assumes passage times are correctly set.
  # Returns a Timing instance.
  #
  def compute_incremental_time
    passages_list = get_all_previous_passages
    total_hundreds = passages_list.sum(:hundreds) + ( passages_list.sum(:seconds) * 100 ) + (passages_list.sum(:minutes) * 6000 ) + hundreds + ( seconds * 100 ) + ( minutes * 6000 )
    Timing.new( total_hundreds )
  end
  #-- --------------------------------------------------------------------------
  #++

  # Check if final time from meeting individual result correponds to calculated final time
  # If result not present always return true
  def is_passage_total_correct
    if meeting_individual_result
      (meeting_individual_result.get_timing_instance == compute_final_time) ? true : false
    else
      true
    end
  end
  #-- --------------------------------------------------------------------------
  #++
end
