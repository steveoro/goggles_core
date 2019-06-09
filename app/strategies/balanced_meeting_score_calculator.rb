# frozen_string_literal: true

require 'wrappers/timing'

#
# == BalancedMeetingScoreCalculator
#
# Strategy Pattern implementation for csi 23014-2015 "balanced"
# meeting team score calculation
# The "balanced" method is the sum of:
# - all individual meeting points
# - best team relays (for category and gender)
# - bonus points for "missing" athlets
# - bonus points for "missing" relays
# The bonus points are calculated:
# - for athlets on the numeber of team athelts
#   to the number of athlets of the most numerous team
# - for relays on the number of team relays considederd
#   to the maximum number of relays considered for a team
#
# @author   Leega
# @version  6.093
#
class BalancedMeetingScoreCalculator

  include SqlConvertable

  # Initialization
  #
  # == Params:
  # An instance of season
  #
  def initialize(meeting)
    @meeting             = meeting
    @teams               = nil
    @meeting_team_scores = nil

    create_sql_diff_header("Team scores calculation for Meeting #{@meeting.get_full_name}")
  end
  #-- --------------------------------------------------------------------------
  #++

  # Get teams involved in season ranking
  #
  def get_teams
    @teams ||= retrieve_teams
  end

  #-- --------------------------------------------------------------------------
  #++

  # Get computed scores
  #
  def get_meeting_team_scores
    @teams ||= get_teams
    @meeting_team_scores ||= compute_team_scores
  end

  #-- --------------------------------------------------------------------------
  #++

  # Saves/persists the season ranking first postions
  # Returns true on no errors
  #
  # Parameters
  # rank_position => Number of rank positions to save (default first 3)
  #
  def save_computed_score!
    persisted_ok = 0
    sql_fields = {}
    @meeting_team_scores ||= get_meeting_team_scores
    @meeting_team_scores.each do |meeting_team_score|
      # Prepare SQL dff statement
      if meeting_team_score.id
        sql_fields['sum_individual_points']     = meeting_team_score.sum_individual_points
        sql_fields['sum_relay_points']          = meeting_team_score.sum_relay_points
        sql_fields['sum_team_points']           = meeting_team_score.sum_team_points
        sql_fields['meeting_individual_points'] = meeting_team_score.sum_individual_points
        sql_fields['meeting_relay_points']      = meeting_team_score.sum_relay_points
        sql_fields['meeting_team_points']       = meeting_team_score.sum_team_points
        sql_fields['season_individual_points']  = meeting_team_score.sum_individual_points
        sql_fields['season_relay_points']       = meeting_team_score.sum_relay_points
        sql_fields['season_team_points']        = meeting_team_score.sum_team_points

        # Save calculated scores
        if meeting_team_score.save
          persisted_ok += 1
          sql_diff_text_log << to_sql_update(meeting_team_score, false, sql_fields, "\r\n")
        end
      else
        # Save calculated scores
        if meeting_team_score.save
          persisted_ok += 1
          meeting_team_score.reload
          sql_diff_text_log << to_sql_insert(meeting_team_score, false, "\r\n")
        end
      end
    end
    create_sql_diff_footer("Team scores calculation for Meeting #{@meeting.get_full_name} done")
    persisted_ok
  end
  #-- --------------------------------------------------------------------------
  #++

  private

  # Retrieves teams which has partecipated to a meeting
  #
  def retrieve_teams
    @meeting.teams.distinct
  end
  #-- --------------------------------------------------------------------------
  #++

  # Retrieves maximum different swimmer resukts for team in the meeting
  #
  def retrieve_max_ranked_swimmers_for_team(team)
    @meeting.meeting_individual_results.is_valid.for_team(team).select('meeting_individual_results.swimmer_id').distinct.count
  end
  #-- --------------------------------------------------------------------------
  #++

  # Retrieves maximum different swimmer resukts for team in the meeting
  #
  def compute_individual_points_for_team(team)
    @meeting.meeting_individual_results.is_valid.for_team(team).sum('meeting_individual_results.team_points')
  end
  #-- --------------------------------------------------------------------------
  #++

  # Retrieves maximum considered relays for team in the meeting
  #
  def retrieve_max_considered_relays_for_team(team)
    @meeting.meeting_relay_results.is_valid.for_team(team).has_points('meeting_points').count
  end
  #-- --------------------------------------------------------------------------
  #++

  # Retrieves maximum considered relays for team in the meeting
  #
  def compute_relay_points_for_team(team)
    @meeting.meeting_relay_results.is_valid.for_team(team).sum('meeting_relay_results.meeting_points')
  end
  #-- --------------------------------------------------------------------------
  #++

  # Calculate team score for the meeting
  # Cycle teams and retrieve individuals and relays points
  # while finding out maximum swimmer and relays
  # Cycle again teams to set bonus points
  #
  def compute_team_scores
    team_scores         = []
    meeting_team_scores = []
    max_swimmers_count  = 0
    max_relays_count    = 0

    # Computes individuals and relays scores and swimmers and relays total per team
    @teams.each do |team|
      team_score = {}
      team_score[:team] = team
      team_score[:sum_individual_points] = compute_individual_points_for_team(team)
      team_score[:sum_relay_points] = compute_relay_points_for_team(team)
      team_score[:swimmers_count] = retrieve_max_ranked_swimmers_for_team(team)
      team_score[:relays_count] = retrieve_max_considered_relays_for_team(team)
      team_score[:swimmers_bonus] = 0
      team_score[:relays_bonus] = 0
      team_scores << team_score

      # Find out maximum swimmers and relays count
      max_swimmers_count = team_score[:swimmers_count] if team_score[:swimmers_count] > max_swimmers_count
      max_relays_count = team_score[:relays_count] if team_score[:relays_count] > max_relays_count
    end

    # Not necessary in rank not used
    # Computes bonuses
    # team_scores.each do |team_score|
    #  team_score[:swimmers_bonus] = max_swimmers_count - team_score[:swimmers_count]
    #  team_score[:relays_bonus] = max_relays_count - team_score[:relays_count]
    # end

    # Create meeting team score
    team_scores.each_with_index do |team_score, _index|
      # Verify if meeting team score already exixts
      meeting_team_score = @meeting.meeting_team_scores.where(['meeting_team_scores.team_id = ?', team_score[:team].id]).first
      unless meeting_team_score
        # Create a new tmeeting team score instance
        meeting_team_score = MeetingTeamScore.new
        meeting_team_score.meeting_id          = @meeting.id
        meeting_team_score.season_id           = @meeting.season_id
        meeting_team_score.team_id             = team_score[:team].id
        meeting_team_score.team_affiliation_id = team_score[:team].team_affiliations.where(['team_affiliations.season_id = ?', @meeting.season_id]).first.id
        # TODO: use current user
        meeting_team_score.user_id             = 2
      end

      # Not in use
      meeting_team_score.rank                      = 0

      # Assigns scores
      meeting_team_score.sum_individual_points     = team_score[:sum_individual_points]
      meeting_team_score.sum_relay_points          = team_score[:sum_relay_points]
      meeting_team_score.sum_team_points           = max_swimmers_count - team_score[:swimmers_count] + max_relays_count - team_score[:relays_count]
      meeting_team_score.meeting_individual_points = meeting_team_score.sum_individual_points
      meeting_team_score.meeting_relay_points      = meeting_team_score.sum_relay_points
      meeting_team_score.meeting_team_points       = meeting_team_score.sum_team_points
      meeting_team_score.season_individual_points  = meeting_team_score.sum_individual_points
      meeting_team_score.season_relay_points       = meeting_team_score.sum_relay_points
      meeting_team_score.season_team_points        = meeting_team_score.sum_team_points
      meeting_team_scores << meeting_team_score
    end

    meeting_team_scores
  end
  #-- --------------------------------------------------------------------------
  #++

end
