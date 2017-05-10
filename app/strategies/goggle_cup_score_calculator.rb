require 'wrappers/timing'

#
# == GoggleCupScoreCalculator
#
# Strategy Pattern implementation for Goggle Cup score calculations
#
# @author   Leega
# @version  4.00.444
#
class GoggleCupScoreCalculator
  include SqlConvertable

  # Initialization
  #
  # == Params:
  # An instance of goggle_cup
  # An instance of swimmer
  # An instance of pool_type
  # An instance of event_type
  #
  def initialize( goggle_cup, swimmer, pool_type, event_type )
    # Verify parameters
    unless goggle_cup && goggle_cup.instance_of?( GoggleCup )
      raise ArgumentError.new("Needs a valid Goggle Cup")
    end
    unless swimmer && swimmer.instance_of?( Swimmer )
      raise ArgumentError.new("Needs a valid swimmer")
    end
    unless pool_type && pool_type.instance_of?( PoolType )
      raise ArgumentError.new("Needs a valid pool type")
    end
    unless event_type && event_type.instance_of?( EventType )
      raise ArgumentError.new("Needs a valid event type")
    end

    @goggle_cup = goggle_cup
    @swimmer = swimmer
    @pool_type = pool_type
    @event_type = event_type
    @standards_updated = false
  end
  #-- --------------------------------------------------------------------------
  #++

  def get_goggle_cup_standard
    @current_goggle_cup_standard ||= retrieve_goggle_cup_standard
  end

  def get_goggle_cup_score( time_swam )
    @goggle_cup_score ||= compute_goggle_cup_score( time_swam )
  end
  #-- --------------------------------------------------------------------------
  #++

  # Return true if calculation has determinated the standard time update
  def are_goggle_cup_standards_updated?
    @standards_updated
  end
  #-- --------------------------------------------------------------------------
  #++

  # Sets the goggle cup standard from a time swam
  def set_goggle_cup_standard( time_swam )
    if GoggleCupStandard.has_standard?( @goggle_cup.id, @swimmer.id, @pool_type.id, @event_type.id )
      # Updates the standard
      get_goggle_cup_standard
      update_goggle_cup_standard( time_swam )
    else
      # Create e new goggle cup standard
      @current_goggle_cup_standard = new_goggle_cup_standard( time_swam )
      @current_goggle_cup_standard ? true : false
    end    
  end
  #-- --------------------------------------------------------------------------
  #++

  # Determinates swimmer modifiers
  # The modifiers should be applied to goggle cup scores
  # If swimmer age is less tha 20 modifier = -10
  # If swimmer age is more than 60 modifier = +5
  # The swimemr age is calculated at the end year of goggle_cup
  def get_swimmer_modifier
    modifier = 0.0
    age = @swimmer.get_swimmer_age( @goggle_cup.get_end_date )
    if age < @goggle_cup.age_for_negative_modifier
      modifier = @goggle_cup.negative_modifier
    else
      if age > @goggle_cup.age_for_positive_modifier
        modifier = @goggle_cup.positive_modifier
      end
    end
    modifier
  end

  private

  # Retrieves the standard goggle cup time for a given swimmer, pool_type and event_type
  #
  def retrieve_goggle_cup_standard
    GoggleCupStandard.get_standard( @goggle_cup.id, @swimmer.id, @pool_type.id, @event_type.id )
  end

  # Compute the goggle cup score for a time swan in a given event and pool type 
  # Goggle cup points is calculated with:
  # GoggleCupStandard : TimeSwam = x : GoggleCupMaxPoints
  # If no goggle cup standard, score equals to GoggleCupMaxPoints
  #
  # == Params:
  # time_swam: the time swam for calculation
  #
  def compute_goggle_cup_score( time_swam )
    # Without a correct time_swam always return 0
    goggle_cup_score = 0.0
    if time_swam && time_swam.to_hundreds > 0
      # Retrieves the time standard
      get_goggle_cup_standard
      if @current_goggle_cup_standard && @current_goggle_cup_standard.get_timing_instance.to_hundreds > 0
        # Calculate the score
        goggle_cup_score = @current_goggle_cup_standard.get_timing_instance.to_hundreds.to_f * @goggle_cup.max_points / time_swam.to_hundreds.to_f
        update_goggle_cup_standard( time_swam ) if goggle_cup_score > @goggle_cup.max_points && @goggle_cup.has_to_update_standards
        
        # Check if modifiers should be applied
        modifier = get_swimmer_modifier
        if modifier != 0.0
          goggle_cup_score = goggle_cup_score + ( goggle_cup_score * (modifier / 100) )
        end
      else
        # Without time standard the score is always GoggleCupMaxPoints
        goggle_cup_score = @goggle_cup.max_points
        @current_goggle_cup_standard = new_goggle_cup_standard( time_swam ) if @goggle_cup.has_to_create_standards
      end
    end
    
    # The score is always with 2 decimals fixed
    goggle_cup_score.round( 2 )
  end
  #-- --------------------------------------------------------------------------
  #++

  # Create the goggle cup standard from a time swam
  # Assumes the goggle cup standard doesn't exists
  #
  def new_goggle_cup_standard( time_swam )
    sql_diff_text_log << "-- Creating time standard for #{@swimmer.get_full_name}\r\n"

    goggle_cup_standard = GoggleCupStandard.new()
    goggle_cup_standard.goggle_cup_id = @goggle_cup.id
    goggle_cup_standard.swimmer_id    = @swimmer.id
    goggle_cup_standard.pool_type_id  = @pool_type.id
    goggle_cup_standard.event_type_id = @event_type.id
    goggle_cup_standard.minutes       = time_swam.minutes
    goggle_cup_standard.seconds       = time_swam.seconds
    goggle_cup_standard.hundreds      = time_swam.hundreds
    goggle_cup_standard.save

    comment = "#{@event_type.code}-#{@pool_type.code}: #{time_swam.to_s}"
    sql_diff_text_log << to_sql_insert( goggle_cup_standard, false, "\r\n", comment )
    @standards_updated = true

    goggle_cup_standard
  end

  # Updte the goggle cup standard from a time swam
  # Assumes the goggle cup standard exists
  #
  def update_goggle_cup_standard( time_swam )
    sql_attributes = {}
    sql_diff_text_log << "-- Updating time standard for #{@swimmer.get_full_name}\r\n"

    @current_goggle_cup_standard.minutes  = time_swam.minutes
    @current_goggle_cup_standard.seconds  = time_swam.seconds
    @current_goggle_cup_standard.hundreds = time_swam.hundreds

    sql_attributes['minutes']   = time_swam.minutes
    sql_attributes['seconds']   = time_swam.seconds
    sql_attributes['hundreds']  = time_swam.hundreds
    comment = "#{@event_type.code}-#{@pool_type.code}: #{time_swam.to_s}"
    sql_diff_text_log << to_sql_update( @current_goggle_cup_standard, false, sql_attributes, "\r\n", comment )   
    @standards_updated = true

    @current_goggle_cup_standard.save
  end
  #-- --------------------------------------------------------------------------
  #++
end
