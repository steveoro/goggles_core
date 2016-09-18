require 'wrappers/timing'

#
# == ChampionshipRankingCalculator
#
# Strategy Pattern implementation for Championship ranking calculations
#
# @author   Leega
# @version  4.00.534
#
class ChampionshipRankingCalculator

  # Initialization
  #
  # == Params:
  # An instance of season
  #
  def initialize( season )
    @season = season    
  end
  #-- --------------------------------------------------------------------------
  #++

  # Get teams involved in season ranking
  # 
  def get_involved_teams
    @involved_teams ||= retrieve_involved_teams
  end

  # Get meetings involved in season ranking
  # 
  def get_involved_meetings
    @involved_meetings ||= retrieve_involved_meetings
  end

  # Get season score columns (point types) 
  # 
  def get_columns
    @columns ||= retrieve_columns
  end

  # Get season ranking
  # 
  def get_season_ranking
    @championship_ranking ||= compute_season_ranking
  end
  #-- --------------------------------------------------------------------------
  #++

  # Saves/persists the season ranking first postions
  # Returns true on no errors
  #
  # Parameters
  # rank_position => Number of rank positions to save (default first 3)
  #
  def save_computed_season_rank( rank_position = 3 )
    persisted_ok = 0

    # If scroes not computed, compute
    get_season_ranking if not @championship_ranking
    
    # If ranked teams less than rank_position, adeguates rank_position
    max_ranked = @championship_ranking.team_scores.count
    rank_position = max_ranked if rank_position > max_ranked 

    @championship_ranking.team_scores.each_with_index do |team_score,index|
      rank = index + 1

      # Search existing data row for update
      computed_season_ranking = ComputedSeasonRanking.where(
        season_id: @season.id,
        rank: rank
      ).first
      
      # Verify if data already exist
      if not computed_season_ranking
        # Create new data row
        computed_season_ranking = ComputedSeasonRanking.new(
          season_id: @season.id,
          team_id: team_score.team.id
        )
      end
      
      # Save calculated attributes
      computed_season_ranking.rank         = rank
      computed_season_ranking.total_points = team_score.total_points
      persisted_ok += 1 if computed_season_ranking.save
      break if rank == rank_position
    end
    
    (rank_position == persisted_ok)
  end
  #-- --------------------------------------------------------------------------
  #++


  private

  # Retrieves teams involved in season ranking
  # The teams involved are those with affiliation for the given season
  # and at least one valid seasonal result
  #
  def retrieve_involved_teams
    @season.teams.joins(:meeting_team_scores).distinct
  end

  # Retrieves meetings involved in season ranking
  # The meetings involved are those with at least one valid seasonal result
  #
  def retrieve_involved_meetings
    @season.meetings.sort_by_date.joins(:meeting_team_scores).distinct
  end

  # Retrieves meetings involved in season ranking
  # The meetings involved are those with at least one valid seasonal result
  #
  def retrieve_columns
    # TODO determinate columns depending on season formulas and/or details
    #[:season_individual_points, :season_relay_points]
    
    # To find significant columns, for now, consider columns
    # which have at least one score
    # Cycle between three season point columns
    # to check if score is stored
    columns = []
    [:season_individual_points, :season_relay_points, :season_team_points].each do |column|
      columns << column if @season.meeting_team_scores.where("#{column} > 0").count > 0
    end
    columns
  end
  #-- --------------------------------------------------------------------------
  #++


  # Retrieves the teams points for season meetings 
  #
  def retrieve_season_points
    @season.meeting_team_scores.has_season_points.select('team_id, meeting_id, season_team_points, season_individual_points, season_relay_points')
  end

  # Computes the season total points for a given team 
  #
  # Params
  # team    => Team to collect scores
  #
  def compute_season_team_points(team)
    # Sum team points among season meetings
    @season.meeting_team_scores.has_season_points.for_team(team).select('(sum(season_team_points) + sum(season_individual_points) + sum(season_relay_points)) as total_pts').first.total_pts.to_i
  end
  #-- --------------------------------------------------------------------------
  #++


  # Retrieves the teams points for a given meeting 
  #
  # Params
  # team    => Team to collect scores
  # meeting => Meeting to collect scores for the team
  # columns => Array of columns to collect
  #
  def retrieve_meeting_team_points(team, meeting, columns)
    meeting.meeting_team_scores.for_team(team).select(columns).first
  end

  # Computes the teams points for a certain meeting 
  #
  # Params
  # team    => Team to collect scores
  # meeting => Meeting to collect scores for the team
  # columns => Array of columns to collect
  #
  def compute_meeting_team_points(meeting_season_points, columns)
    total_meeting_points = 0
    columns.each do |column|
      total_meeting_points += meeting_season_points[column]
    end
    total_meeting_points
  end
  #-- --------------------------------------------------------------------------
  #++
  
  
  def compute_season_ranking
    # Sets championship characteristics
    get_columns
    get_involved_meetings
    get_involved_teams    
    team_scores = []
    
    @involved_teams.each do |team|
      # Create team scores
      team_score = ChampionshipDAO::TeamScoreDAO.new(team)
      @involved_meetings.each do |meeting|
        # TODO Should perform a unique read from DB and cycle on data red
        meeting_team_points = retrieve_meeting_team_points(team, meeting, @columns)
        team_score.add_meeting( meeting_team_points, @columns )
      end
      team_scores << team_score 
    end
    ChampionshipDAO.new( @columns, @involved_meetings, team_scores )
  end
  #-- --------------------------------------------------------------------------
  #++
end
