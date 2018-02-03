# encoding: utf-8

=begin

= BalancedIndividualRankingDAO

  - Goggles framework vers.:  4.00.777
  - author: Leega

 DAO class containing the structure for balanced individual ranking rendering.
 Balanced individual ranking (BIR) is a method adopted by csi 2014-2015 season
 in which individual scores are calculated considering placement, seasonal ranking
 and special bonuses
 For each swimmer involved in season the DAO provides a collection of meeting results
 (the championship takes) 

=end
class BalancedIndividualRankingDAO
  
  class BIREventScoreDAO
    # These must be initialized on creation:
    #attr_reader :meeting

    # These can be edited later on:
    attr_accessor :event_date, :event_type, 
                  :rank, :event_points, 
                  :ranking_points
    #-- -------------------------------------------------------------------------
    #++
  
    # Creates a new instance from a meeting_individual_result.
    #
    def initialize( meeting_individual_result, seasonal_event_best, time_converted = nil )
      unless meeting_individual_result && meeting_individual_result.instance_of?( MeetingIndividualResult )
        raise ArgumentError.new("Balanced individual ranking event score needs a meeting individual result")
      end

      @event_date     = meeting_individual_result.meeting_session.scheduled_date
      @event_type     = meeting_individual_result.event_type
      @rank           = meeting_individual_result.rank
      @event_points   = meeting_individual_result.meeting_individual_points.to_i
      @ranking_points = 0 
      
      # Calculate ranking points
      time_to_use = time_converted ? time_converted : meeting_individual_result.get_timing_instance 
      @ranking_points = 100 * seasonal_event_best.time_swam.to_hundreds / time_to_use.to_hundreds 
    end
    #-- -------------------------------------------------------------------------
    #++
    
    # Get the total points for the event
    def get_total_points
      @event_points + @ranking_points
    end
    #-- -------------------------------------------------------------------------
    #++
  end

  class BIRMeetingScoreDAO
    # These must be initialized on creation:
    attr_reader :meeting

    # These can be edited later on:
    attr_accessor :meeting, :header_date, 
                  :event_bonus_points, :medal_bonus_points,
                  :event_points, :ranking_points, 
                  :event_results 
    #-- -------------------------------------------------------------------------
    #++
  
    # Creates a new instance from a ameeting_indivudla_result.
    #
    def initialize( meeting, meeting_individual_results, seasonal_event_bests )
      unless meeting && meeting.instance_of?( Meeting )
        raise ArgumentError.new("Balanced individual ranking meeting score needs a meeting")
      end

      @meeting            = meeting
      @header_date        = meeting.header_date
      @event_bonus_points = 0
      @medal_bonus_points = 0
      @event_points       = 0
      @ranking_points     = 0
      
      @event_results = []
      rank_first     = 0
      rank_second    = 0
      rank_third     = 0
      meeting_individual_results.each do |meeting_individual_result|
        # Get seasonal event best
        seasonal_event_best = seasonal_event_bests.get_best_for_gender_category_and_event( meeting_individual_result.gender_type, meeting_individual_result.category_type, meeting_individual_result.event_type )
        
        # Check conversion to short course needed
        time_converted = nil
        if meeting_individual_result.pool_type.code == '50'
          time_converted = seasonal_event_bests.timing_converter.convert_time_to_short( meeting_individual_result.get_timing_instance, meeting_individual_result.gender_type, meeting_individual_result.event_type ) 
        end
        
        @event_results << BIREventScoreDAO.new( meeting_individual_result, seasonal_event_best, time_converted )
        
        # Store each rank for rank bonus
        rank_first  = rank_first + 1 if meeting_individual_result.rank == 1
        rank_second = rank_second + 1 if meeting_individual_result.rank == 2
        rank_third  = rank_third + 1 if meeting_individual_result.rank == 3

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
        @event_results.sort!{|p,n| n.get_total_points <=> p.get_total_points}
  
        # Find out best event points
        @event_points   = @event_results.first.event_points
        @ranking_points = @event_results.first.ranking_points
      end
    end
    #-- -------------------------------------------------------------------------
    #++
    
    # Get the total points for the meeting
    def get_total_points
      @event_points + @ranking_points + @event_bonus_points + @medal_bonus_points
    end
    #-- -------------------------------------------------------------------------
    #++

    # Get the meetings results detail description for the swimmer
    def get_meeting_scores_detail
      "#{@event_points}+#{@ranking_points}+#{@event_bonus_points}+#{@medal_bonus_points}"
    end
    #-- -------------------------------------------------------------------------
    #++
  end

  # Each swimmer has a gender and a category
  # Each swimmer has a collection of meetings (results)
  class BIRSwimmerScoreDAO
    # These must be initialized on creation:
    attr_reader :swimmer

    # These can be edited later on:
    attr_accessor :swimmer, :category_type, :gender_type, :meetings, :total_best_5_on_6 
    #-- -------------------------------------------------------------------------
    #++
  
    # Creates a new instance from a ameeting_indivudla_result.
    #
    def initialize( swimmer, season, seasonal_event_bests )
      unless swimmer && swimmer.instance_of?( Swimmer )
        raise ArgumentError.new( "Balanced individual ranking swimmer needs a swimmer" )
      end
      unless season && season.instance_of?( Season )
        raise ArgumentError.new( "Balanced individual ranking swimmer needs a season" )
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
          @meetings << BIRMeetingScoreDAO.new( meeting, meeting_individual_results, seasonal_event_bests )
        end
      end
      
      # Sort meetings by total points
      @meetings.sort!{|p,n| n.get_total_points <=> p.get_total_points}
      
      # Calculate best 5 on 6 results
      @meetings.each_with_index do |meeting,index|
        @total_best_5_on_6 = @total_best_5_on_6 + meeting.get_total_points if index < 5 
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

  # Each swimmer has a gender and a category
  # Each swimmer has a collection of meetings (results)
  class BIRGenderCategoryRankingDAO
    # These must be initialized on creation:
    attr_reader :gender_type, :category_type

    # These can be edited later on:
    attr_accessor :swimmers, :gender_type, :category_type
    #-- -------------------------------------------------------------------------
    #++
  
    # Creates a new instance from a ameeting_indivudla_result.
    #
    def initialize( season, gender_type, category_type, seasonal_event_bests )
      unless season && season.instance_of?( Season )
        raise ArgumentError.new("Balanced individual ranking needs a season")
      end
      unless gender_type && gender_type.instance_of?( GenderType )
        raise ArgumentError.new( "Balanced individual ranking for gender and category needs a gender type" )
      end
      unless category_type && category_type.instance_of?( CategoryType )
        raise ArgumentError.new( "Balanced individual ranking for gender and category needs a category type" )
      end

      @gender_type   = gender_type
      @category_type = category_type
      @swimmers      = []
      
    
      # Search swimmers for the season, gender and category
      season.badges.for_gender_type( gender_type ).for_category_type( category_type ).each do |badge|
        @swimmers << BIRSwimmerScoreDAO.new( badge.swimmer, season, seasonal_event_bests ) if badge.meeting_individual_results.exists?
      end
      
      # Sort swimmers by total points
      @swimmers.sort!{|p,n| n.total_best_5_on_6 <=> p.total_best_5_on_6}
    end
    #-- -------------------------------------------------------------------------
    #++
  end

  # These must be initialized on creation:
  attr_reader :season
  #-- -------------------------------------------------------------------------
  #++

  # These can be edited later on:
  attr_accessor :season, :gender_and_categories, :meetings_with_results, :seasonal_event_bests

  # Creates a new instance.
  #
  # Needs to  be sure team_scores is an instance of TeamScoreDAO
  # to perform correcto sorting
  #
  def initialize( season )
    unless season && season.instance_of?( Season )
      raise ArgumentError.new("Balanced individual ranking needs a season")
    end
    @season                = season
    @meetings_with_results = season.meetings.has_results
    @gender_and_categories = []
    @seasonal_event_bests  = SeasonalEventBestDAO.new( season )
  end
  #-- -------------------------------------------------------------------------
  #++
    
  # Get the total ranking for gender and category
  def get_ranking_for_gender_and_category( gender_type, category_type )
    @gender_and_categories.select{|element| element.gender_type == gender_type and element.category_type == category_type }.first
  end
  #-- -------------------------------------------------------------------------
  #++

  # Calculate the total ranking for all genders and categories
  def scan_for_gender_and_category
    GenderType.individual_only.sort_by_courtesy.each do |gender_type|
      @season.category_types.are_not_relays.sort_by_age.each do |category_type|
        set_ranking_for_gender_and_category( gender_type, category_type )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Calculate the ranking for given gender and category
  def calculate_ranking( gender_type, category_type )
    BIRGenderCategoryRankingDAO.new( @season, gender_type, category_type, @seasonal_event_bests )
  end
  #-- -------------------------------------------------------------------------
  #++
    
  # Set the ranking for given gender and category
  def set_ranking_for_gender_and_category( gender_type, category_type )
    @gender_and_categories << calculate_ranking( gender_type, category_type )
  end
  #-- -------------------------------------------------------------------------
  #++
    
  # Set the ranking for given gender and category
  # TODO Localize and store on DB
  def get_html_ranking_description
    'La classifica finale è calcolata considerando le 5 migliori prove su 6.<br>Per ogni prova vengono totalizzati i punti in base a:<ul><li>piazzamento</li><li>valore della prestazione rapportata al ranking stagionale</li><li>doppio podio nella manifestazione</li><li>premio gare impegnative</li></ul>'.html_safe
  end
  #-- -------------------------------------------------------------------------
  #++
end
