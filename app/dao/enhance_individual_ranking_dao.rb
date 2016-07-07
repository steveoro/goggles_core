# encoding: utf-8

=begin

= EnhanceIndividualRankingDAO

  - Goggles framework vers.:  4.00.857
  - author: Leega

 DAO class containing the structure for enhance individual ranking rendering.
 Enhance individual ranking (EIR) is a method adopted by csi 2015-2016 season
 in which individual scores are calculated considering placement, 
 prestation value, personal enhancement and special bonuses. 
 prestation value are calculated in relation of best season type results
 Personal enhancement are referred to past seasons personal bests.
 Special bonuses are obtained with multiple medals placement in the same meeting
 or partecipation at particularly "hard" event types.  
 For each swimmer involved in season the DAO provides a collection of meeting results
 (the championship takes) 

=end
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
    def initialize( meeting_individual_result )
      unless meeting_individual_result && meeting_individual_result.instance_of?( MeetingIndividualResult )
        raise ArgumentError.new("Enhance individual ranking event score needs a meeting individual result")
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

      # TODO store on DB standard points score definition (100 with no decimals)
      # Should use calculation rules definition
      @performance_points = compute_performance_points( 100, 0 )

      @enhance_points    = compute_enhance_points
    end
    #-- -------------------------------------------------------------------------
    #++
    
    # Calculate the prestation points for the event
    # The prestation points are calculated considering the time swam related to
    # the season type best performance (for event, category, gender and pool type)
    # 
    # best_performance : time_swam = 100 : performance_points
    # If time swam is the same prestation points are 100
    # If time swam is better prestation points are greater than 100
    # If time swam is worst prestation points are less than 100
    #
    def compute_performance_points( standard_points, decimals )
      score_calculator = ScoreCalculator.new( @season, @gender_type, @category_type, @pool_type, @event_type )
      score_calculator.get_custom_score( @meeting_individual_result.get_timing_instance, standard_points, decimals )
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
      if SeasonPersonalStandard.has_standard?( @season.id, @swimmer.id, @pool_type.id, @event_type.id )
        past_season_event_best = SeasonPersonalStandard.get_standard( @season.id, @swimmer.id, @pool_type.id, @event_type.id )
        if past_season_event_best.get_timing_instance.to_hundreds <= @meeting_individual_result.get_timing_instance.to_hundreds
          @enhance_points = 0
        else
          @enhance_points = (100 * past_season_event_best.get_timing_instance.to_hundreds / meeting_individual_result.get_timing_instance.to_hundreds).to_i - 100
        end
      else 
        @enhance_points = 0
      end
      @enhance_points > 10 ? 10 : @enhance_points 
    end
    #-- -------------------------------------------------------------------------
    #++

    # Get the total points for the event
    # Totale point is the sum of event, prestation value and enhanchement 
    def get_total_points
      @event_points + @performance_points + @enhance_points
    end
    #-- -------------------------------------------------------------------------
    #++
  end

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
    def initialize( meeting, meeting_individual_results )
      unless meeting && meeting.instance_of?( Meeting )
        raise ArgumentError.new("Enhance individual ranking meeting score needs a meeting")
      end

      @meeting            = meeting
      @header_date        = meeting.header_date
      @event_bonus_points = 0
      @medal_bonus_points = 0
      @event_points       = 0
      @performance_points  = 0
      @enhance_points     = 0
      
      @event_results = []
      rank_first     = 0
      rank_second    = 0
      rank_third     = 0
      meeting_individual_results.each do |meeting_individual_result|
        @event_results << EIREventScoreDAO.new( meeting_individual_result )
        
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
        @event_points      = @event_results.first.event_points
        @performance_points = @event_results.first.performance_points
        @enhance_points    = @event_results.first.enhance_points
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
    def initialize( swimmer, season )
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
        if meeting_individual_results.count > 0
          # The swimmer has results for that meeting
          @meetings << EIRMeetingScoreDAO.new( meeting, meeting_individual_results )
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
  class EIRGenderCategoryRankingDAO
    # These must be initialized on creation:
    attr_reader :gender_type, :category_type

    # These can be edited later on:
    attr_accessor :swimmers, :gender_type, :category_type
    #-- -------------------------------------------------------------------------
    #++
  
    # Creates a new instance
    #
    def initialize( season, gender_type, category_type )
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
        @swimmers << EIRSwimmerScoreDAO.new( badge.swimmer, season ) if badge.meeting_individual_results.count > 0
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
  attr_accessor :season, :gender_and_categories, :meetings_with_results

  # Creates a new instance.
  #
  # Needs to  be sure team_scores is an instance of TeamScoreDAO
  # to perform correcto sorting
  #
  def initialize( season )
    unless season && season.instance_of?( Season )
      raise ArgumentError.new("Enhance individual ranking needs a season")
    end
    @season                = season
    @meetings_with_results = season.meetings.has_results
    @gender_and_categories = []
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
    EIRGenderCategoryRankingDAO.new( @season, gender_type, category_type )
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
    'La classifica finale è calcolata considerando le 5 migliori prove su 6.<br>Per ogni prova vengono totalizzati i punti in base a:<ul><li>piazzamento</li><li>valore della prestazione rapportata ai record regionali</li><li>miglioramento personale</li><li>doppio podio nella manifestazione</li><li>premio gare impegnative</li></ul>'.html_safe
  end
  #-- -------------------------------------------------------------------------
  #++
end
