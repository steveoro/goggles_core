require 'wrappers/timing'

#
# == TeamBestFinder
#
# Strategy Pattern implementation for team best result retrieving
# Best team results should considered for categories and gender
#
# @author   Leega
# @version  4.00.837
#
class TeamBestFinder
  include SqlConvertable

  # These can be edited later on:
  attr_accessor :team, :distinct_categories, :gender_types, :pool_types, :event_types

  # Initialization
  #
  # == Params:
  # An instance of team
  #
  def initialize( team )
    unless team && team.instance_of?( Team )
      raise ArgumentError.new("Needs a valid team: #{team.inspect}")
    end
    unless team.meeting_individual_results.count > 0
      raise ArgumentError.new("Team #{team.get_full_name} hasn't results")
    end

    @team                = team
    @gender_types        = GenderType.individual_only
    @pool_types          = PoolType.only_for_meetings
    @event_types         = EventType.are_not_relays.for_fin_calculation
    @distinct_categories = retrieve_distinct_categories
  end
  #-- --------------------------------------------------------------------------
  #++

  # Sets the gender types to search for
  # Default is male and female
  #
  def set_genders( gender_types = GenderType.individual_only )
    @gender_types = gender_types
  end

  # Sets the pool types to search for
  # Default is 25 and 50
  #
  def set_pools( pool_types = PoolType.only_for_meetings )
    @pool_types = pool_types
  end

  # Sets the event types to search for
  # Default is FIN individual events
  #
  def set_events( event_types = EventType.are_not_relays.for_fin_calculation )
    @event_types = event_types
  end

  # Find out the category in the distinct_category array
  # using the category code
  # Return nil if category code not present
  #
  def find_category_by_code( category_code )
    element = @distinct_categories.rindex{ |e| e.code == category_code }
    @distinct_categories[element] if element
  end

  # Find out the categories for which to retrieve the "team best".
  # Only individual categories will be considered.
  # Different season types have different categories.
  # It will merge them whenever different season type categories are mergable.
  #
  def retrieve_distinct_categories
    if @distinct_categories
      categories = @distinct_categories
    else
      categories = []
      @team.season_types.each do |season_type|
        season_type.seasons.sort_season_by_begin_date.last.category_types.are_not_relays.sort_by_age.each do |category_type|
          categories << category_type if ! categories.rindex{ |e| e.code == category_type.code }
        end
      end
    end
    categories
  end

  # Check if a category has to be splitted
  # Some categories are undivided and has to be splitted for definition
  # Some categories have different age definition in different season types and need to be compared
  #
  def category_needs_split?( category_type )
    needs_split = false
    if category_type.is_undivided
      needs_split = true
    elsif @distinct_categories.rindex{ |e| e.code != category_type.code && e.age_begin >= category_type.age_begin && e.age_end <= category_type.age_end }
      needs_split = true
    end
    needs_split
  end

  # Find out the category to split in the actual one
  # The category to split in is the one, not splitted
  # with correct age range considering the swimmer age
  # at the moment of individual result
  #
  # If no matching category found return the result one
  #
  def get_category_to_split_into( meeting_individual_result )
    category_type = meeting_individual_result.category_type
    if category_needs_split?( category_type )
      # Find the swimmer age
      swimmer_age = meeting_individual_result.get_swimmer_age
      element = @distinct_categories.rindex{ |e| e.code != category_type.code && e.age_begin <= swimmer_age && e.age_end >= swimmer_age && ! e.is_undivided }
    end
    element ? @distinct_categories[element] : find_category_by_code( category_type.code )
  end

  # Verify if exists results for given gender, pool, event and category
  # for the selected team.
  # Disqualified results not considered
  #
  def has_individual_result?( gender_type, pool_type, event_type, category_code )
    team.meeting_individual_results.is_not_disqualified.for_gender_type(gender_type).for_pool_type(pool_type).for_event_type(event_type).for_category_code(category_code).sort_by_timing.count > 0
  end

  # Find best for given gender, pool, event and category code
  # Note it uses category code instaed of id
  # Returns nil if no results for given parameters
  # Disqualified results not considered
  #
  def get_team_best_individual_result( gender_type, pool_type, event_type, category_code )
    has_individual_result?( gender_type, pool_type, event_type, category_code ) ?
      team.meeting_individual_results.is_not_disqualified.for_gender_type(gender_type).for_pool_type(pool_type).for_event_type(event_type).for_category_code(category_code).sort_by_timing.first :
      nil
  end

  # Cycle between distinct categories to find out team bests
  # Team bests found should be rearranged for category split&merge operation
  # Returns a RecordX4dDAO with a RecordElement for each
  # pool type, gender type, event type and distinct category
  # with at least one not disqualified result
  #
  def scan_for_distinct_bests
    team_distinct_best = RecordX4dDAO.new( @team, RecordType.find_by_code( 'TTB' ) )

    # Cycle between set genders, pools, events and distinct categories
    @gender_types.each do |gender_type|
      @pool_types.each do |pool_type|
        @event_types.each do |event_type|
          @distinct_categories.each do |category_type|
            record = get_team_best_individual_result( gender_type, pool_type, event_type, category_type.code )
            if record
              team_distinct_best.add_record( record )
            end
          end
        end
      end
    end

    team_distinct_best
  end

  # Category split definition
  # Check out categories which needs to be splitted
  # and associates with target category
  #
  # Return an array with categories to split
  #
  def get_categories_to_split
    categories_to_split = []
    @distinct_categories.each do |category_type|
      if category_needs_split?( category_type )
        categories_to_split << category_type
      end
    end
    categories_to_split
  end

  # Split category records for grouped category
  # Cycle beetween distinct categories and suppress category
  # that needs to be splitted checking best records
  # with split destination category one
  #
  def split_categories( team_distinct_best )
    # Verify there are some categories thjat needs to be splitted
    category_to_split = get_categories_to_split.map{ |category_type| category_type.code }
    if category_to_split.size > 0
      # Scan team records searching for those with categories that needs split
      records_to_split = team_distinct_best.records.select{ |record| category_to_split.rindex( record.get_category_type ) }
      if records_to_split.size > 0
        # Split records
        # Finds taregt category
        # Check if for target category a record is already present
        # If present choses the better one
        records_to_split.each do |record_to_split|
          record          = record_to_split.get_record_instance
          pool_code       = record_to_split.get_pool_type
          gender_code     = record_to_split.get_gender_type
          event_code      = record_to_split.get_event_type
          target_category = get_category_to_split_into( record )

          if team_distinct_best.has_record_for?( pool_code, gender_code, event_code, target_category.code )
            if record.get_timing_instance < team_distinct_best.get_record_instance( pool_code, gender_code, event_code, target_category.code ).get_timing_instance
              # Update previous target record
              team_distinct_best.delete_record( pool_code, gender_code, event_code, target_category.code )
              team_distinct_best.add_record( record, target_category.code, pool_code, gender_code, event_code )
            end
          else
            # Creates new record
            team_distinct_best.add_record( record, target_category.code, pool_code, gender_code, event_code )
          end
          team_distinct_best.delete_record( pool_code, gender_code, event_code, record_to_split.get_category_type )
        end
      end
    end

    team_distinct_best
  end


  # TODO Consider to populate next 2 array during best scan to avoid multiple array scan

  # Retrieve categories with records for given pool and gender types
  #
  def get_categories_with_records( pool_type, gender_type, team_distinct_best )
    valid_categories = []
    @distinct_categories.each do |category_type|
      if team_distinct_best.has_record_for?( pool_type.code, gender_type.code, nil, category_type.code )
        valid_categories << category_type
      end
    end
    valid_categories.sort{ |n,p| n.age_begin <=> p.age_begin }
  end

  # Retrieve events with records for given pool and gender types
  #
  def get_events_with_records( pool_type, gender_type, team_distinct_best )
    valid_events = []
    @event_types.each do |event_type|
      if team_distinct_best.has_record_for?( pool_type.code, gender_type.code, event_type.code, nil )
        valid_events << event_type
      end
    end
    valid_events.sort{ |n,p| n.style_order <=> p.style_order }
  end
end
