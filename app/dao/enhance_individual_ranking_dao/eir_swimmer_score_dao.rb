# encoding: utf-8

=begin

= EnhanceIndividualRankingDAO::EIRSwimmerScoreDAO

  - Goggles framework vers.:  4.00.857
  - author: Leega

 DAO class containing the structure for enhance individual ranking rendering.
 Enhance individual ranking (EIR) is a method adopted by csi 2015-2016 season
 in which individual scores are calculated considering placement,
 performance value, personal enhancement and special bonuses.
 performance value are calculated in relation of best season type results
 Personal enhancement are referred to past seasons personal bests.
 Special bonuses are obtained with multiple medals placement in the same meeting
 or partecipation at particularly "hard" event types.
 For each swimmer involved in season the DAO provides a collection of meeting results
 (the championship takes)

=end
class EnhanceIndividualRankingDAO

  # Each swimmer has a gender and a category
  # Each swimmer has a collection of meetings (results)
  class EIRSwimmerScoreDAO
    # These must be initialized on creation:
    attr_reader :swimmer

    # These can be edited later on:
    attr_accessor :swimmer, :category_type, :gender_type, :meetings, :total_best_5_on_6
    #-- -------------------------------------------------------------------------
    #++

    # Creates a new instance from a ameeting_indivudla_result.
    #
    def initialize( swimmer, season, total_meetings = season.meetings.count )
      unless swimmer && swimmer.instance_of?( Swimmer )
        raise ArgumentError.new( "Enhance individual ranking swimmer needs a swimmer" )
      end
      unless season && season.instance_of?( Season )
        raise ArgumentError.new( "Enhance individual ranking swimmer needs a season" )
      end

      @swimmer           = swimmer
      @gender_type       = swimmer.gender_type
      @category_type     = swimmer.get_category_type_for_season( season.id )
      @meetings          = []
      @total_best_5_on_6 = 0

      # Search meetings for he swimmer in the season
      season.meetings.each do |meeting|
        meeting_individual_results = meeting.meeting_individual_results.is_valid.where(["meeting_individual_results.swimmer_id = ?", @swimmer.id])
        if meeting_individual_results.exists?
          # The swimmer has results for that meeting
          @meetings << EIRMeetingScoreDAO.new( meeting, meeting_individual_results )
        end
      end

      # Sort meetings by total points
      @meetings.sort!{|p,n| n.get_total_points <=> p.get_total_points}

      # Calculate best 5 on 6 results
      @meetings.each_with_index do |meeting,index|
        @total_best_5_on_6 = @total_best_5_on_6 + meeting.get_total_points if index < total_meetings
      end
    end
    #-- -------------------------------------------------------------------------
    #++

    # Get the meetings results for the swimmer
    def get_meeting_scores( meeting )
      @meetings.select{|element| element.meeting == meeting }.first
    end
    #-- -------------------------------------------------------------------------
    #++
  end

end
#-- ---------------------------------------------------------------------------
#++
