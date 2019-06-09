# frozen_string_literal: true

#
# == ChampionshipHistoryManager
#
# Strategy Pattern implementation for Championship history management
#
# @author   Leega
# @version  4.00.729
#
class ChampionshipHistoryManager

  # Initialization
  #
  # == Params:
  # An instance of season_type
  #
  def initialize(season_type)
    @season_type = season_type
  end
  #-- --------------------------------------------------------------------------
  #++

  # Get closed seasons
  #
  def get_closed_seasons
    @closed_seasons ||= retrieve_closed_seasons
  end

  # Get stored ranking for the given sesasons
  #
  # Parameters
  # rank_position => Number of rank positions to save (default first 3)
  #
  def get_season_ranking_history(rank_position = 3)
    @seasons_ranking_history ||= retrieve_season_ranking_history(rank_position)
  end
  #-- --------------------------------------------------------------------------
  #++

  # Get teams involved in season ranking history (hall of fame)
  #
  def get_involved_teams
    @involved_teams ||= retrieve_involved_teams
  end

  # Get the hall of fame (per team) of given seasons
  #
  def get_season_hall_of_fame
    @seasons_hall_of_fame ||= retrieve_season_hall_of_fame
  end
  #-- --------------------------------------------------------------------------
  #++

  private

  # Retrieves season closed
  # The season closed are those with... ?!?
  # TODO Decide when a season is closed. Should be different from season end date
  #      Has to indicate where season championship is over.
  #      Maybe should store closed championship final ranking in a delegate structure
  # TODO Make it a scope of season
  #
  def retrieve_closed_seasons
    @season_type.seasons.where(['end_date < ?', Date.today])
                .sort_season_by_begin_date('DESC')
  end
  #-- --------------------------------------------------------------------------
  #++

  # Retrieves closed season ranking history
  # and stores in an array of hashes
  # with season and ranking keys
  #
  # Parameters
  # rank_position => Number of rank positions to save
  #
  def retrieve_season_ranking_history(rank_position)
    seasons_ranking_history = []
    get_closed_seasons unless @closed_seasons

    @closed_seasons.each do |season|
      season_ranking_history = {}
      season_ranking_history[:season] = season
      season_ranking_history[:ranking] = season.computed_season_ranking
                                               .includes(:team)
                                               .sort_by_rank
                                               .limit(rank_position)
      # [Steve, 20150129] Check against possible 'uncomputed' (yet) seasons:
      max_computed_season_rank = season.computed_season_ranking.select(:updated_at).max
      season_ranking_history[:max_updated_at] = max_computed_season_rank ?
                                                max_computed_season_rank.updated_at.to_i :
                                                0
      seasons_ranking_history << season_ranking_history
    end
    seasons_ranking_history
  end
  #-- --------------------------------------------------------------------------
  #++

  # Retrieves teams involved in season ranking history
  # The teams involved are those with at least one ranking in
  # computed season ranking /closed season hall of fame) of
  # the given season type
  #
  def retrieve_involved_teams
    Team.joins(computed_season_ranking: :season).where("seasons.season_type_id = #{@season_type.id}").distinct
  end
  #-- --------------------------------------------------------------------------
  #++

  # Retrieves closed season hall of fame (per team)
  # and stores in an array of hashes
  # with team and palces keys
  #
  def retrieve_season_hall_of_fame
    seasons_hall_of_fame = []
    get_involved_teams unless @involved_teams

    @involved_teams.each do |team|
      team_placement = {}
      team_placement[:team] = team
      %w[first_place second_place third_place].each_with_index do |rank, index|
        placement = index + 1
        team_placement[rank.to_sym] = team.computed_season_ranking.joins(:season).where("seasons.season_type_id = #{@season_type.id} AND computed_season_rankings.rank = #{placement}").count
      end
      seasons_hall_of_fame << team_placement
    end
    seasons_hall_of_fame.sort { |p, n| (n[:first_place] * 10_000 + n[:second_place] * 100 + n[:third_place]) <=> (p[:first_place] * 10_000 + p[:second_place] * 100 + p[:third_place]) }
  end
  #-- --------------------------------------------------------------------------
  #++

end
