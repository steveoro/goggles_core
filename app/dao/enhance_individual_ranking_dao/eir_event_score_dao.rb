# frozen_string_literal: true

#
# = EnhanceIndividualRankingDAO::EIREventScoreDAO
#
#   - Goggles framework vers.:  4.00.857
#   - author: Leega
#
#  DAO class containing the structure for enhance individual ranking rendering.
#  Enhance individual ranking (EIR) is a method adopted by csi 2015-2016 season
#  in which individual scores are calculated considering placement,
#  performance value, personal enhancement and special bonuses.
#  performance value are calculated in relation of best season type results
#  Personal enhancement are referred to past seasons personal bests.
#  Special bonuses are obtained with multiple medals placement in the same meeting
#  or partecipation at particularly "hard" event types.
#  For each swimmer involved in season the DAO provides a collection of meeting results
#  (the championship takes)
#
class EnhanceIndividualRankingDAO

  class EIREventScoreDAO

    # These must be initialized on creation:
    attr_reader :meeting_individual_result

    # These can be edited later on:
    attr_accessor :event_date, :event_type,
                  :rank, :event_points,
                  :performance_points, :enhance_points,
                  :season, :pool_type, :event_type, :gender_type, :category_type, :swimmer
    #-- -------------------------------------------------------------------------
    #++

    # Creates a new instance from a meeting_individual_result.
    #
    def initialize(meeting_individual_result)
      unless meeting_individual_result&.instance_of?(MeetingIndividualResult)
        raise ArgumentError, 'Enhance individual ranking event score needs a meeting individual result'
      end

      @meeting_individual_result = meeting_individual_result
      @event_date                = meeting_individual_result.meeting_session.scheduled_date
      @event_type                = meeting_individual_result.event_type
      @rank                      = meeting_individual_result.rank
      @event_points              = meeting_individual_result.meeting_individual_points.to_i
      @season                    = meeting_individual_result.season
      @pool_type                 = meeting_individual_result.pool_type
      @event_type                = meeting_individual_result.event_type
      @gender_type               = meeting_individual_result.gender_type
      @category_type             = meeting_individual_result.category_type
      @swimmer                   = meeting_individual_result.swimmer

      # TODO: store on DB standard points score definition (100 with no decimals)
      # Should use calculation rules definition
      @performance_points = compute_performance_points(100, 0)

      @enhance_points = compute_enhance_points
    end
    #-- -------------------------------------------------------------------------
    #++

    # Calculate the performance points for the event
    # The performance points are calculated considering the time swam related to
    # the season type best performance (for event, category, gender and pool type)
    #
    # best_performance : time_swam = 100 : performance_points
    # If time swam is the same performance points are 100
    # If time swam is better performance points are greater than 100
    # If time swam is worst performance points are less than 100
    #
    def compute_performance_points(standard_points, decimals)
      score_calculator = ScoreCalculator.new(@season, @gender_type, @category_type, @pool_type, @event_type)
      score_calculator.get_custom_score(@meeting_individual_result.get_timing_instance, standard_points, decimals)
    end
    #-- -------------------------------------------------------------------------
    #++

    # Calculate the enhance points for the event
    # The enhance points are calculated considering the last season best performance
    #
    # If the time swam is worst or the same enhance points are 0
    # If this is the first time for that event for the swimmer enhance points are 0
    # If time swam is better enhance points are up to 10
    #
    def compute_enhance_points
      @enhance_points = 0
      if SeasonPersonalStandard.has_standard?(@season.id, @swimmer.id, @pool_type.id, @event_type.id)
        past_season_event_best = SeasonPersonalStandard.get_standard(@season.id, @swimmer.id, @pool_type.id, @event_type.id)
        return 0 if past_season_event_best.get_timing_instance.to_hundreds <= @meeting_individual_result.get_timing_instance.to_hundreds

        @enhance_points = (100 * past_season_event_best.get_timing_instance.to_hundreds / meeting_individual_result.get_timing_instance.to_hundreds).to_i - 100
      else
        return 0
      end
      @enhance_points > 10 ? 10 : @enhance_points
    end
    #-- -----------------------------------------------------------------------
    #++

    # Get the total points for the event
    # Totale point is the sum of event, performance value and enhanchement
    def get_total_points
      @event_points + @performance_points + @enhance_points
    end
    #-- -----------------------------------------------------------------------
    #++

  end

end
#-- ---------------------------------------------------------------------------
#++
