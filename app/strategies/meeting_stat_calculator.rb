# frozen_string_literal: true

#
# = MeetingStatCalculator
#   - Goggles framework vers.:  6.085
#   - author: Leega
#
#  Utility class to calculate meeting stats from meeting results or entries.
#
# === Members:
#  - <tt>:swimmer_male_count</tt> => Count of male swimmers with result
#
class MeetingStatCalculator

  # These must be initialized on creation:
  attr_reader :meeting

  # Creates a new instance.
  # Note the ascending precision of the parameters, which allows to skip
  # the rarely used ones.
  #
  def initialize(meeting)
    raise ArgumentError, 'Meeting stat needs a valid meeting' unless meeting&.instance_of?(Meeting)

    @meeting       = meeting
    @meeting_stats = MeetingStatDAO.new(meeting)
  end

  def get_meeting
    @meeting
  end
  # ---------------------------------------------------------------------------

  # Verify if meeting has results
  # Meeting should have are_results_acquired flag set to true
  # and some meeting_individual_results
  # and more than one team partecipating
  #
  def has_results?
    ((@meeting.are_results_acquired || @meeting.meeting_individual_results.exists?) && @meeting.teams.distinct.count > 1)
  end

  # Verify if meeting has relays
  # Meeting should have results
  # and some meeting_relay_results
  #
  def has_relays?
    (has_results? && @meeting.meeting_relay_results.exists?)
  end

  # Verify if meeting has entries
  # Meeting should have some meeting_entries
  # and more than one entered team
  #
  def has_entries?
    (@meeting.meeting_entries.exists? && @meeting.meeting_entries.select('team_id').distinct.count > 1)
  end
  # ---------------------------------------------------------------------------

  # Retrieves the teams lis for the meeting
  # If results are acquired the teams are those with at least one result
  # If results are not acquired the teams are those with at least one entry
  #
  def get_teams
    if has_results?
      teams = @meeting.teams.unscope(:order).sort_by_name('ASC').distinct
    elsif has_entries?
      teams = []
      @meeting.meeting_entries.select('team_id').distinct.map(&:team_id).each do |team_id|
        teams << Team.find(team_id)
      end
      teams.sort! { |n, p| n.name <=> p.name }
    else
      teams = []
    end
    teams
  end

  # Meeting entries methods
  # Those methods are based on meeting entries
  # Intended for stats on meeting without results
  # or to know entries stats

  # Statistic calculation for the team count
  # Temas are intended the distinct team with entries in the meeting
  #
  def get_entered_teams_count
    @meeting.meeting_entries
            .joins(:team).includes(:team)
            .select('teams.id').distinct.count
  end
  # ---------------------------------------------------------------------------

  # Statistic calculation for the meeting entries count
  # Entries are intended the distinct entries for the meeting
  #
  def get_entries_count(scope_name = :is_male)
    @meeting.meeting_entries.send(scope_name.to_sym).count
  end

  # Statistic calculation for the meeting entries count for a given team
  # Entries are intended the distinct entries for the meeting
  #
  def get_team_entries_count(team, scope_name = :is_male)
    @meeting.meeting_entries.for_team(team).send(scope_name.to_sym).count
  end

  # Statistic calculation for the meeting entries count for a given category
  # Entries are intended the distinct entries for the meeting
  #
  def get_category_ent_swimmers_count(category_type, scope_name = :is_male)
    @meeting.meeting_entries.for_category_type(category_type).send(scope_name.to_sym).select('swimmer_id').distinct.count
  end

  # Statistic calculation for the meeting entries count for a given event
  # Entries are intended the distinct entries for the meeting
  #
  def get_event_entries_count(event_type, scope_name = :is_male)
    @meeting.meeting_entries.for_event_type(event_type).send(scope_name.to_sym).count
  end
  # ---------------------------------------------------------------------------

  # Statistic calculation for the meeting entries swimmer count
  # swimmers are intended the physical distinct swimmers entered the meeting
  #
  def get_entered_swimmers_count(scope_name = :is_male)
    @meeting.meeting_entries.send(scope_name.to_sym).select('swimmer_id').distinct.count
  end

  # Statistic calculation for the meeting entries swimmer count for a given team
  # swimmers are intended the physical distinct swimmers entered the meeting
  #
  def get_team_entered_swimmers_count(team, scope_name = :is_male)
    @meeting.meeting_entries.for_team(team).send(scope_name.to_sym).select('swimmer_id').distinct.count
  end
  # ---------------------------------------------------------------------------

  # Meeting result methods
  # Those methods are based on meeting results
  # Intended for stats on meeting with results

  # Statistic calculation for the team count
  # Temas are intended the distinct team with results in the meeting
  #
  def get_teams_count
    @meeting.teams.distinct.count
  end

  # Statistic calculation for the meeting results count
  # Results are intended the distinct results swam in the meeting
  #
  def get_results_count(scope_name = :is_male)
    @meeting.meeting_individual_results.send(scope_name.to_sym).count
  end

  # Statistic calculation for the meeting results count for a given team
  # Results are intended the distinct results swam in the meeting
  #
  def get_team_results_count(team, scope_name = :is_male)
    @meeting.meeting_individual_results.for_team(team).send(scope_name.to_sym).count
  end

  # Statistic calculation for the meeting results count for a given category
  # Results are intended the distinct results swam in the meeting
  #
  def get_category_swimmers_count(category_type, scope_name = :is_male)
    @meeting.meeting_individual_results.for_category_type(category_type).send(scope_name.to_sym)
            .select('swimmer_id').distinct.count
  end

  # Statistic calculation for the meeting results count for a given event
  # Results are intended the distinct results swam in the meeting
  #
  def get_event_results_count(event_type, scope_name = :is_male)
    @meeting.meeting_individual_results.for_event_type(event_type).send(scope_name.to_sym).count
  end
  # ---------------------------------------------------------------------------

  # Statistic calculation for the meeting swimmer count
  # swimmers are intended the physical distinct swimmers swam in the meeting
  #
  def get_swimmers_count(scope_name = :is_male)
    @meeting.swimmers.send(scope_name.to_sym).distinct.count
  end
  # ---------------------------------------------------------------------------

  # Statistic calculation for the meeting swimmer count for a given team
  # swimmers are intended the physical distinct swimmers swam in the meeting
  #
  def get_team_swimmers_count(team, scope_name = :is_male)
    @meeting.meeting_individual_results.for_team(team).send(scope_name.to_sym).select('swimmer_id').distinct.count
  end
  # ---------------------------------------------------------------------------

  # Statistic calculation for the meeting disqualified count
  # Disqualified are intended the results in the meeting with is_disqualified attribute set to true
  #
  def get_disqualifieds_count(scope_name = :is_male)
    @meeting.meeting_individual_results.is_disqualified.send(scope_name.to_sym).count
  end
  # ---------------------------------------------------------------------------

  # Statistic calculation for the meeting disqualified count for a given team
  # Disqualified are intended the results in the meeting with is_disqualified attribute set to true
  #
  def get_team_disqualifieds_count(team, scope_name = :is_male)
    @meeting.meeting_individual_results.is_disqualified.for_team(team).send(scope_name.to_sym).count
  end
  # ---------------------------------------------------------------------------

  # Statistic calculation of the best standard score for a given team
  # Best results are intended evaluating the standard (FIN) points not 0
  # Assumes the standard (FIN) pints are always calculated
  # Returns 0 in no standard points
  #
  def get_team_best_standard(team, scope_name = :is_male)
    if @meeting.meeting_individual_results.for_team(team).is_valid.send(scope_name.to_sym).has_points.count > 0
      @meeting.meeting_individual_results.for_team(team).is_valid
              .send(scope_name.to_sym).has_points.unscope(:order)
              .order('standard_points DESC').first
              .standard_points
    else
      0.00
    end
  end
  # ---------------------------------------------------------------------------

  # Statistic calculation of the worst standard score for a given team
  # Worst results are intended evaluating the standard (FIN) points not 0
  # Assumes the standard (FIN) pints are always calculated
  # Returns 0 in no standard points
  #
  def get_team_worst_standard(team, scope_name = :is_male)
    if @meeting.meeting_individual_results.for_team(team).is_valid.send(scope_name.to_sym).has_points.count > 0
      @meeting.meeting_individual_results.for_team(team)
              .is_valid.send(scope_name.to_sym)
              .has_points.unscope(:order)
              .order('standard_points ASC').first
              .standard_points
    else
      0.00
    end
  end
  # ---------------------------------------------------------------------------

  # Statistic calculation of the medals number for a given team
  # Medals are intended as ranking (1=gold, 2=silver, 3=bronze, 4=wooden)
  #
  def get_team_medals(team, scope_name = :is_male, rank = 1)
    @meeting.meeting_individual_results.for_team(team).is_valid
            .send(scope_name.to_sym).has_rank(rank).count
  end
  # ---------------------------------------------------------------------------

  # Statistic calculation for the over target result count
  # The target is intended as the standard points to beat
  #
  def get_over_target_count(target = 900)
    @meeting.meeting_individual_results.where(['standard_points >= ?', target]).count
  end
  # ---------------------------------------------------------------------------

  # Statistic calculation for the meeting average standard points
  # Average is calculated considering only > 0 standard point results
  #
  def get_average(scope_name = :is_male)
    result_count = @meeting.meeting_individual_results.send(scope_name.to_sym).has_points.count
    if result_count > 0
      standard_points_sum = @meeting.meeting_individual_results.send(scope_name.to_sym).has_points.sum(:standard_points)
      (standard_points_sum / result_count).round(2)
    else
      result_count
    end
  end
  # ---------------------------------------------------------------------------

  # Statistic calculation for the meeting relays average standard points
  # Average is calculated considering only > 0 standard point results
  #
  def get_relays_average
    result_count = @meeting.meeting_relay_results.has_points.count
    if result_count > 0
      standard_points_sum = @meeting.meeting_relay_results.has_points.sum(:standard_points)
      (standard_points_sum / result_count).round(2)
    else
      result_count
    end
  end
  # ---------------------------------------------------------------------------

  # Statistic calculation for the meeting average standard points for a given team
  # Average is calculated considering only > 0 standard point results
  #
  def get_team_average(team, scope_name = :is_male)
    result_count = @meeting.meeting_individual_results.for_team(team).send(scope_name.to_sym).has_points.count
    if result_count > 0
      standard_points_sum = @meeting.meeting_individual_results.for_team(team).send(scope_name.to_sym).has_points.sum(:standard_points)
      (standard_points_sum / result_count).round(2)
    else
      result_count
    end
  end
  # ---------------------------------------------------------------------------

  # Statistic calculation of the oldest swimmers has swam in the meeting
  #
  def get_oldest_swimmers(scope_name = :is_male, swimmer_num = 3)
    @meeting.swimmers.send(scope_name.to_sym).unscope(:order)
            .order(:year_of_birth).distinct.limit(swimmer_num)
  end
  # ---------------------------------------------------------------------------

  # Statistic calculation of the best results swam in the meeting
  # Best results are intended evaluating the standard (FIN) points not 0
  # Assumes the standard (FIN) pints are always calculated
  #
  def get_best_standard_scores(scope_name = :is_male, score_num = 3)
    @meeting.meeting_individual_results.is_valid.send(scope_name.to_sym).has_points
            .unscope(:order).order('standard_points DESC').first(score_num)
  end
  # ---------------------------------------------------------------------------

  # Statistic calculation of the worst results swam in the meeting
  # Worst results are intended evaluating the standard (FIN) points not 0
  # Assumes the standard (FIN) pints are always calculated
  #
  def get_worst_standard_scores(scope_name = :is_male, score_num = 3)
    @meeting.meeting_individual_results.is_valid.send(scope_name.to_sym).has_points
            .unscope(:order).order('standard_points ASC').limit(score_num)
  end
  # ---------------------------------------------------------------------------

  # General stats calculation
  #
  def calculate(bests = 3, worsts = 1, oldests = 1, entries = true, teams = true, categories = true, events = true, scores = true, ranks = true)
    # Entry-based
    if entries && has_entries?
      @meeting_stats.set_general(:ent_teams_count, get_entered_teams_count)
      @meeting_stats.set_general(:ent_swimmers_male_count, get_entered_swimmers_count(:is_male))
      @meeting_stats.set_general(:ent_swimmers_female_count, get_entered_swimmers_count(:is_female))
      @meeting_stats.set_general(:entries_male_count, get_entries_count(:is_male))
      @meeting_stats.set_general(:entries_female_count, get_entries_count(:is_female))
    end

    # Result-based
    if has_results?
      @meeting_stats.set_general(:teams_count, get_teams_count)
      @meeting_stats.set_general(:swimmers_male_count, get_swimmers_count(:is_male))
      @meeting_stats.set_general(:swimmers_female_count, get_swimmers_count(:is_female))
      @meeting_stats.set_general(:results_male_count, get_results_count(:is_male))
      @meeting_stats.set_general(:results_female_count, get_results_count(:is_female))
      @meeting_stats.set_general(:dsqs_male_count, get_disqualifieds_count(:is_male))
      @meeting_stats.set_general(:dsqs_female_count, get_disqualifieds_count(:is_female))
      @meeting_stats.set_general(:oldest_male_swimmers, get_oldest_swimmers(:is_male, oldests)) if oldests > 0
      @meeting_stats.set_general(:oldest_female_swimmers, get_oldest_swimmers(:is_female, oldests)) if oldests > 0

      if has_relays?
        @meeting_stats.set_general(:results_relay_count, @meeting.meeting_relay_results.count)
        @meeting_stats.set_general(:dsqs_relay_count, @meeting.meeting_relay_results.is_disqualified.count)

        @meeting_stats.set_general(:average_relay_score, get_relays_average) if @meeting.meeting_relay_results.has_points.exists?
      end

      # Score-based
      if @meeting.meeting_individual_results.has_points.exists?
        @meeting_stats.set_general(:average_male_score, get_average(:is_male))
        @meeting_stats.set_general(:average_female_score, get_average(:is_female))
        @meeting_stats.set_general(:average_total_score, get_average(:has_points))
        @meeting_stats.set_general(:over_1000_count, get_over_target_count(1000))
        @meeting_stats.set_general(:over_950_count, get_over_target_count(950) - @meeting_stats.over_1000_count)
        @meeting_stats.set_general(:over_900_count, get_over_target_count(900) - @meeting_stats.over_950_count)
        @meeting_stats.set_general(:best_std_male_scores, get_best_standard_scores(:is_male, bests)) if bests > 0
        @meeting_stats.set_general(:best_std_female_scores, get_best_standard_scores(:is_female, bests)) if bests > 0
        @meeting_stats.set_general(:worst_std_male_scores, get_worst_standard_scores(:is_male, worsts)) if worsts > 0
        @meeting_stats.set_general(:worst_std_female_scores, get_worst_standard_scores(:is_female, worsts)) if worsts > 0
      end
    end

    calculate_teams(entries, scores, ranks) if teams
    calculate_categories(entries) if categories
    calculate_events(entries) if events

    @meeting_stats
  end
  # ---------------------------------------------------------------------------

  # Team stats calculation
  #
  def calculate_teams(entries = true, scores = true, ranks = true)
    @meeting_stats.teams = []
    get_teams.each do |team|
      team_stat = @meeting_stats.new_team(team)

      # Entry-based
      if entries && has_entries?
        team_stat.male_ent_swimmers   = get_team_entered_swimmers_count(team, :is_male)
        team_stat.female_ent_swimmers = get_team_entered_swimmers_count(team, :is_female)
        team_stat.male_entries        = get_team_entries_count(team, :is_male)
        team_stat.female_entries      = get_team_entries_count(team, :is_female)
      end

      # Result-based
      if has_results?
        # Default
        team_stat.male_results         = get_team_results_count(team, :is_male)
        team_stat.female_results       = get_team_results_count(team, :is_female)
        team_stat.male_swimmers        = get_team_swimmers_count(team, :is_male)
        team_stat.female_swimmers      = get_team_swimmers_count(team, :is_female)
        team_stat.relay_results        = @meeting.meeting_relay_results.for_team(team).count

        # Score stats
        if scores
          team_stat.male_best            = get_team_best_standard(team, :is_male)
          team_stat.male_worst           = get_team_worst_standard(team, :is_male)
          team_stat.male_average         = get_team_average(team, :is_male)
          team_stat.female_best          = get_team_best_standard(team, :is_female)
          team_stat.female_worst         = get_team_worst_standard(team, :is_female)
          team_stat.female_average       = get_team_average(team, :is_female)
        end

        # Ranking stats
        if ranks
          team_stat.male_disqualifieds   = get_team_disqualifieds_count(team, :is_male)
          team_stat.female_disqualifieds = get_team_disqualifieds_count(team, :is_female)
          team_stat.male_golds           = get_team_medals(team, :is_male, 1)
          team_stat.male_silvers         = get_team_medals(team, :is_male, 2)
          team_stat.male_bronzes         = get_team_medals(team, :is_male, 3)
          team_stat.female_golds         = get_team_medals(team, :is_female, 1)
          team_stat.female_silvers       = get_team_medals(team, :is_female, 2)
          team_stat.female_bronzes       = get_team_medals(team, :is_female, 3)

          if has_relays? && @meeting.meeting_relay_results.for_team(team).exists?
            team_stat.relay_disqualifieds  = @meeting.meeting_relay_results.for_team(team).is_disqualified.count
            team_stat.relay_golds          = @meeting.meeting_relay_results.for_team(team).has_rank(1).count
            team_stat.relay_silvers        = @meeting.meeting_relay_results.for_team(team).has_rank(2).count
            team_stat.relay_bronzes        = @meeting.meeting_relay_results.for_team(team).has_rank(3).count
          end
        end
      end

      @meeting_stats.teams << team_stat # if team_stat.get_entries_count + team_stat.get_results_count + team_stat.get_disqualifieds_count > 0
    end
    @meeting_stats.teams
  end
  # ---------------------------------------------------------------------------

  # Category stats calculation
  #
  def calculate_categories(entries = true)
    @meeting_stats.categories = []
    @meeting.category_types.are_not_relays.is_divided.sort_by_age.distinct.each do |category_type|
      category_stat = @meeting_stats.new_category(category_type)

      # Entry-based
      if entries && has_entries?
        category_stat.male_ent_swimmers   = get_category_ent_swimmers_count(category_type, :is_male)
        category_stat.female_ent_swimmers = get_category_ent_swimmers_count(category_type, :is_female)
      end

      # Result-based
      if has_results?
        category_stat.male_swimmers        = get_category_swimmers_count(category_type, :is_male)
        category_stat.female_swimmers      = get_category_swimmers_count(category_type, :is_female)
      end

      @meeting_stats.categories << category_stat
    end
    @meeting_stats.categories
  end
  # ---------------------------------------------------------------------------

  # Event stats calculation
  #
  def calculate_events(entries = true)
    @meeting_stats.events = []
    @meeting.event_types.are_not_relays
            .order('meeting_sessions.session_order, meeting_events.event_order')
            .distinct.each do |event_type|
      event_stat = @meeting_stats.new_event(event_type)

      # Entry-based
      if entries && has_entries?
        event_stat.male_entries        = get_event_entries_count(event_type, :is_male)
        event_stat.female_entries      = get_event_entries_count(event_type, :is_female)
      end

      # Result-based
      if has_results?
        event_stat.male_results         = get_event_results_count(event_type, :is_male)
        event_stat.female_results       = get_event_results_count(event_type, :is_female)
      end

      @meeting_stats.events << event_stat
    end
    @meeting_stats.events
  end
  # ---------------------------------------------------------------------------

  # Calculate stats cycling meeting individual results
  # Deprecate but useful to check single stat methods
  #
  def calculate_by_cycle
    teams_hash = {}
    # Stores, for each Team id as key:
    # team_id => [
    #   [array of processed swimmer ids], Team name, Male count,
    #    female count, tot. count, is_highlighted, gold_count,
    #    silver_count, bronze_count ],
    # Sort resulting list by team name, ASC

    categories_hash = {}
    # Stores, for each category id as key:
    # category_id => [ [array of processed swimmer ids],
    #   category name, Male count, female count, tot. count ],
    # Sort resulting list by category ID, ASC

    event_types_hash = {}
    # Stores, for each EventType id as key:
    # event_type_id => [ EventType name, Male count, female count, tot. count ],
    # Sort resulting list by event_type name, ASC

    mir = @meeting.meeting_individual_results.is_valid
    # Loop upon all individual results and count the athletes, without duplicates
    # (each athlete may have more than 1 result for its own team):
    mir.each do |ind_result| # "1 loop to bind them all..."
      swimmer = ind_result.swimmer
      female = swimmer.is_female ? 1 : 0
      male   = swimmer.is_male ? 1 : 0
      male_female = male + female
      # gold   = ( (ind_result.rank==1) && ind_result.is_valid_for_ranking && (ind_result.meeting_individual_points>0) ? 1 : 0 )
      # silver = ( (ind_result.rank==2) && ind_result.is_valid_for_ranking && (ind_result.meeting_individual_points>0) ? 1 : 0 )
      # bronze = ( (ind_result.rank==3) && ind_result.is_valid_for_ranking && (ind_result.meeting_individual_points>0) ? 1 : 0 )
      gold   = ((ind_result.rank == 1) && ind_result.is_valid_for_ranking ? 1 : 0)
      silver = ((ind_result.rank == 2) && ind_result.is_valid_for_ranking ? 1 : 0)
      bronze = ((ind_result.rank == 3) && ind_result.is_valid_for_ranking ? 1 : 0)
      # Collect athletes' gender for each team:
      if teams_hash[ind_result.team_id].nil?
        teams_hash[ ind_result.team_id ] = [
          [ind_result.swimmer_id],
          ind_result.team.get_full_name,
          female,
          male,
          male_female,
          false,
          gold,
          silver,
          bronze
        ]
      else
        team_arr = teams_hash[ind_result.team_id]
        unless team_arr[0].include?(ind_result.swimmer_id)
          # Add current result's swimmer to the "already processed list"
          team_arr[0] << ind_result.swimmer_id
          team_arr[2] += female
          team_arr[3] += male
          team_arr[4] += male_female
          # idx 5 => is_highlighted
        end
        # Always count the medals: (we have to count just one swimmer for each
        # result, but we want to count all the medals)
        team_arr[6] += gold
        team_arr[7] += silver
        team_arr[8] += bronze
      end
      # Collect athletes' gender for each category, without duplicates
      # (each athlete may have more than 1 result for its own category):
      if categories_hash[ind_result.get_category_type_id].nil?
        categories_hash[ ind_result.get_category_type_id ] = [
          [ind_result.swimmer_id],
          ind_result.get_category_type_short_name,
          female,
          male,
          male_female
        ]
      else
        cat_arr = categories_hash[ind_result.get_category_type_id]
        unless cat_arr[0].include?(ind_result.swimmer_id)
          # Add current result's swimmer to the "already processed list"
          cat_arr[0] << ind_result.swimmer_id
          cat_arr[2] += female
          cat_arr[3] += male
          cat_arr[4] += male_female
        end
      end
      # Collect athletes' gender for each event type (each athlete will ALWAYS have
      # just 1 result for each event type):
      if event_types_hash[ind_result.get_event_type_id].nil?
        event_types_hash[ ind_result.get_event_type_id ] = [
          ind_result.get_event_type_description,
          female,
          male,
          male_female
        ]
      else
        evnt_arr = event_types_hash[ind_result.get_event_type_id]
        evnt_arr[1] += female
        evnt_arr[2] += male
        evnt_arr[3] += male_female
      end
    end
    # Add also relay medals to the medal count:
    mrr = @meeting.meeting_relay_results.is_valid
    mrr.each do |rel_result|
      team_arr = teams_hash[rel_result.team_id]
      next unless team_arr

      gold   = (rel_result.rank == 1 && rel_result.is_valid_for_ranking ? 1 : 0)
      silver = (rel_result.rank == 2 && rel_result.is_valid_for_ranking ? 1 : 0)
      bronze = (rel_result.rank == 3 && rel_result.is_valid_for_ranking ? 1 : 0)
      team_arr[6] += gold
      team_arr[7] += silver
      team_arr[8] += bronze
    end
    # Prepare the team gender count list and sort it by name:
    # Substitute each 0-th element with the key (team_id)
    teams_hash.each { |key, val| val[0] = key }
    @teams_array = teams_hash.values.sort { |a, b| a[1] <=> b[1] }
    # Prepare the category gender count list and sort it by category ID (hash key):
    @categories_array = categories_hash.keys.sort.collect { |k| categories_hash[k] }
    # Prepare the event type gender count list and sort it by name:
    @event_types_array = event_types_hash.values.sort { |a, b|  a[0] <=> b[0] }
  end
  # ---------------------------------------------------------------------------

end
