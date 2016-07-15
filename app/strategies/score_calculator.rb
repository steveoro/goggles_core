#
# == ScoreCalculator
#
# Strategy Pattern implementation for score calculations
#
# @author   Leega
# @version  4.00.393
#
class ScoreCalculator

  # Initialization within a swimmer
  #
  # == Params:
  # An instance of season
  # An instance of gender
  # An instance of category
  # An instance of pool_type
  # An instance of event_type
  #
  def initialize( season, swimmer_gender, swimmer_category, pool_type, event_type )
    @season           = season
    @swimmer_gender   = swimmer_gender
    @swimmer_category = swimmer_category
    @pool_type        = pool_type
    @event_type       = event_type
  end
  #-- --------------------------------------------------------------------------
  #++

  def get_time_standard
    @current_time_standard ||= retrieve_time_standard
  end

  def get_fin_score( time_swam )
    @fin_score ||= compute_fin_score( time_swam )
  end

  def get_custom_score( time_swam, standard_points = 1000, decimals = 2 )
    result = compute_fin_score( time_swam, standard_points, decimals )
# DEBUG
#    puts "\r\n- get_custom_score( #{time_swam}, #{standard_points}, #{decimals} ) = #{ result }"
#    puts "  #{ @event_type.i18n_description } #{@swimmer_gender.code}, #{@swimmer_category.code}, #{@pool_type.code} mt."
    result
  end

  def get_fin_timing( goal_score )
    @time_to_swim ||= desume_time_from_score( goal_score )
  end
  #-- --------------------------------------------------------------------------
  #++


  private

  # Retrieves the swimmer category for a given season
  #
  # == Params:
  # season_id: id of the interested season
  #
  def retrieve_time_standard
    # Retrieves category and gender through the swimmer
    # @swimmer_category = get_swimmer_category
    # @swimmer_gender = get_swimmer_gender
    TimeStandard.where(
        season_id:        @season           ? @season.id           : 0,
        gender_type_id:   @swimmer_gender   ? @swimmer_gender.id   : 0,
        category_type_id: @swimmer_category ? @swimmer_category.id : 0,
        pool_type_id:     @pool_type        ? @pool_type.id        : 0,
        event_type_id:    @event_type       ? @event_type.id       : 0
      ).first
  end

  # Compute the FIN standard score for a given event, pool type, gender, category, season
  # FIN standard points is calculated with:
  # TimeStandard : TimeSwam = x : 1000
  # If no time standard, FIN score equals to 1000
  #
  # == Params:
  # time_swam: the time swam for calculation
  #
  def compute_fin_score( time_swam, standard_points = 1000.00, decimals = 2 )
    # Without a correct time_swam always return 0
    fin_score = 0.0
    if time_swam && time_swam.to_hundreds > 0
      # Retrieves the time standard
      get_time_standard
      if @current_time_standard && @current_time_standard.get_timing_instance.to_hundreds > 0
        # Calculate the score with 2 decimals fixed
        fin_score = @current_time_standard.get_timing_instance.to_hundreds.to_f * standard_points / time_swam.to_hundreds.to_f
      else
        # Without time standard the score is always 1000
        fin_score = standard_points
      end
    end
    fin_score.round( decimals )
  end
  #-- --------------------------------------------------------------------------
  #++

  # Desume the timing necessary to obtain the given FIN standard score for an event, pool type, gender, category, season
  # FIN standard points is calculated with:
  # TimeStandard : TimeSwam = FINScore : 1000
  # so TimeToSwim = TimeStandard * 1000 / FINScore
  # If no time standard, claculation not possible
  #
  # == Params:
  # goal_score: the FIN standard time to obtain
  #
  def desume_time_from_score( goal_score )
    # Without a correct time_swam always return 0
    time_to_swim = Timing.new(0)
    if goal_score && goal_score > 0
      # Retrieves the time standard
      get_time_standard
      if @current_time_standard && @current_time_standard.get_timing_instance.to_hundreds > 0
        # If goal score 1000 returnm the time standard
        if goal_score.round(2) == 1000.00
          time_to_swim = @current_time_standard.get_timing_instance
        else
          # Calculate the score with 2 decimals fixed
          time_to_swim = Timing.new( ( @current_time_standard.get_timing_instance.to_hundreds.to_f * 1000.00 / goal_score.to_f ).to_i )
        end
      end
    end
    time_to_swim
  end
  #-- --------------------------------------------------------------------------
  #++
end
