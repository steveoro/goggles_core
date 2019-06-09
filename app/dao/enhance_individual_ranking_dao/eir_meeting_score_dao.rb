# frozen_string_literal: true

#
# = EnhanceIndividualRankingDAO::EIRMeetingScoreDAO
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

  class EIRMeetingScoreDAO

    # These must be initialized on creation:
    attr_reader :meeting

    # These can be edited later on:
    attr_accessor :meeting, :header_date,
                  :event_bonus_points, :medal_bonus_points,
                  :event_points, :performance_points, :enhance_points,
                  :event_results
    #-- -------------------------------------------------------------------------
    #++

    # Creates a new instance from a meeting_individualresult.
    #
    def initialize(meeting, meeting_individual_results)
      raise ArgumentError, 'Enhance individual ranking meeting score needs a meeting' unless meeting&.instance_of?(Meeting)

      @meeting            = meeting
      @header_date        = meeting.header_date
      @event_bonus_points = 0
      @medal_bonus_points = 0
      @event_points       = 0
      @performance_points = 0
      @enhance_points     = 0

      @event_results = []
      rank_first     = 0
      rank_second    = 0
      rank_third     = 0
      meeting_individual_results.each do |meeting_individual_result|
        @event_results << EIREventScoreDAO.new(meeting_individual_result)

        # Store each rank for rank bonus
        rank_first  += 1 if meeting_individual_result.rank == 1
        rank_second += 1 if meeting_individual_result.rank == 2
        rank_third  += 1 if meeting_individual_result.rank == 3

        # Find out event bonus
        # TODO store bonus information on DB
        @event_bonus_points = 8 if @event_bonus_points < 8 && meeting_individual_result.event_type.code == '800SL'
        @event_bonus_points = 4 if @event_bonus_points < 4 && meeting_individual_result.event_type.code == '400SL'
        @event_bonus_points = 4 if @event_bonus_points < 4 && meeting_individual_result.event_type.code == '200MI'
        @event_bonus_points = 4 if @event_bonus_points < 4 && meeting_individual_result.event_type.code == '100FA'
      end

      if @event_results.count > 0
        # Find out rank bonus
        # TODO store bonus information on DB
        @medal_bonus_points = 10 if @medal_bonus_points < 10 && rank_first >= 2
        @medal_bonus_points = 8 if @medal_bonus_points < 8 && rank_first == 1 && rank_second >= 1
        @medal_bonus_points = 6 if @medal_bonus_points < 6 && rank_first == 1 && rank_third >= 1
        @medal_bonus_points = 4 if @medal_bonus_points < 4 && rank_second >= 2
        @medal_bonus_points = 2 if @medal_bonus_points < 2 && rank_second == 1 && rank_third >= 1
        @medal_bonus_points = 1 if @medal_bonus_points < 1 && rank_third >= 2

        # Sort events by total points
        @event_results.sort! { |p, n| n.get_total_points <=> p.get_total_points }

        # Find out best event points
        @event_points = @event_results.first.event_points
        @performance_points = @event_results.first.performance_points
        @enhance_points = @event_results.first.enhance_points
      end
    end
    #-- -------------------------------------------------------------------------
    #++

    # Get the total points for the meeting
    def get_total_points
      @event_points + @performance_points + @enhance_points + @event_bonus_points + @medal_bonus_points
    end
    #-- -------------------------------------------------------------------------
    #++

    # Get the meetings results detail description for the swimmer
    def get_meeting_scores_detail
      "#{@event_points}+#{@performance_points}+#{@enhance_points}+#{@event_bonus_points}+#{@medal_bonus_points}"
    end
    #-- -------------------------------------------------------------------------
    #++

  end

end
#-- ---------------------------------------------------------------------------
#++
