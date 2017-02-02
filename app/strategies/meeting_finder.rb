# encoding: utf-8
require 'conditions_generator_column_string_regexped' # Used to generate simple_search query condition


=begin

= MeetingFinder

 - Goggles framework vers.:  6.071
 - author: Steve A.

 Finder (strategy) class used to retrieve lists of Meeting instances based
 upon a "simple" search query.

 The text specified in the constructor will be searched among:

 - meeting header: description, title and notes
 - meeting results: swimmer names
 - meeting results: team names

=end
class MeetingFinder

  # Constructor
  #
  # == Params:
  # - query_term: the text to be searched; returns all Meetings when no term is supplied.
  # - limit: limit for results of the query
  #
  def initialize( query_term = nil, limit = nil )
    query_term = nil if query_term.to_s == ''
    @query_term = query_term
    @limit = limit
  end
  #-- --------------------------------------------------------------------------
  #++

  # Executes the search, returning just an array of row IDs, corresponding to the
  # Meeting rows satisfying the search term.
  # Default search is set on header, swimming pool and events
  #
  def search_ids(scan_header = true, scan_swimming_pool = true, scan_events = true, scan_teams = false, scan_swimmers = false)
    ids = []

    # Avoid query build-up if no search text is given:
    if @query_term
      ids += search_in_header if scan_header
      ids += search_in_swimming_pool if scan_swimming_pool
      ids += search_in_events if scan_events
      ids += search_in_teams if scan_teams
      ids += search_in_swimmers if scan_swimmers

      # Return the results:
      ids.uniq[ 0..@limit.to_i-1 ]
    else                                            # No search term:
      Meeting.select(:id).all.limit( @limit ).map{ |row| row.id }.flatten.uniq
    end
  end


  # Executes the search, returning just an array of row IDs, corresponding to the
  # Meeting rows satisfying the search term.
  #
  def deep_search_ids
    ids = []
    # Avoid query build-up if no search text is given:
    if @query_term
      query_swimmers_condition = ConditionsGeneratorColumnStringRegexped.generate_query_conditions(
        'swimmers',
        'complete_name',
        @query_term
      )
      query_teams_condition    = ConditionsGeneratorColumnStringRegexped.generate_query_conditions(
        'teams',
        'name',
        @query_term
      )
      search_like_text = "%#{@query_term}%"

      # Search among most-used text columns in Meetings:
      ids += Meeting.select(:id).where(
        [
          "(description LIKE ?) OR (header_year LIKE ?) OR (notes LIKE ?) OR (reference_name LIKE ?)",
          search_like_text, search_like_text, search_like_text, search_like_text
        ]
      ).limit( @limit ).map{ |row| row.id }.flatten.uniq

      # Search among linked Swimmers:
      ids += Meeting.select(:id)
          .joins( :swimmers )
          .includes( :swimmers )
          .where( query_swimmers_condition ).limit( @limit )
          .map{ |row| row.id }.flatten.uniq

      # Search among linked Teams:
      ids += Meeting.select(:id)
          .joins( :teams )
          .includes( :teams )
          .where( query_teams_condition ).limit( @limit )
          .map{ |row| row.id }.flatten.uniq

      # Search among linked EventTypes:
      event_type_ids = EventType
          .joins( :stroke_type )
          .includes( :stroke_type )
          .limit( @limit )
          .find_all do |row|
        ( row.i18n_short =~ %r(#{@query_term})i ) ||
        ( row.i18n_description =~ %r(#{@query_term})i )
      end.map{ |row| row.id }.flatten.uniq

      # Complete the list of IDs to be retrieved:
      ids += Meeting.select(:id)
          .joins( :meeting_events )
          .includes( :meeting_events )
          .where( :'meeting_events.event_type_id' => event_type_ids )
          .limit( @limit )
          .map{ |row| row.id }.flatten.uniq
      # Return the results:
      ids.uniq[ 0..@limit.to_i-1 ]
    else                                            # No search term:
      Meeting.select(:id).all.limit( @limit ).map{ |row| row.id }.flatten.uniq
    end
  end
  #-- --------------------------------------------------------------------------
  #++


  # Executes the search, using meeting header fields
  # Fileds considered are:
  # - description
  # - notes (TODO use team which organize meeting)
  # Suppressed:
  # - reference_name
  # - header_year
  #
  # Returns Meeting rows (just an array of row IDs) satisfying the search term.
  #
  def search_in_header
    ids = []

    # Avoid query build-up if no search text is given:
    if @query_term
      search_like_text = "%#{@query_term}%"

      # Search among most-used text columns in Meetings:
          #"(description LIKE ?) OR (header_year LIKE ?) OR (notes LIKE ?) OR (reference_name LIKE ?)",
      ids += Meeting.select(:id).where(
        [
          "(description LIKE ?) OR (notes LIKE ?)",
          search_like_text, search_like_text
        ]
      ).limit( @limit ).map{ |row| row.id }.flatten.uniq
    end

    # Return the results:
    ids.uniq[ 0..@limit.to_i-1 ]
  end
  #-- --------------------------------------------------------------------------
  #++


  # Executes the search, using meeting swimming pools
  # Fileds considered are:
  # - pool name
  # - city name
  # - country name
  #
  # Returns Meeting rows (just an array of row IDs) satisfying the search term.
  #
  def search_in_swimming_pool
    ids = []

    # Avoid query build-up if no search text is given:
    if @query_term
      search_like_text = "%#{@query_term}%"

      # Search among pool name and city
      ids += Meeting.select(:id)
          .joins( swimming_pools: :city )
          .includes( swimming_pools: :city )
          .where(
        [
          "(swimming_pools.name LIKE ?) OR (cities.name LIKE ?) OR (cities.area LIKE ?)",
          search_like_text, search_like_text, search_like_text
        ]
      ).limit( @limit ).map{ |row| row.id }.flatten.uniq
    end

    # Return the results:
    ids.uniq[ 0..@limit.to_i-1 ]
  end
  #-- --------------------------------------------------------------------------
  #++


  # Find out event types id to use in search among meeting_events
  # Returns Event types rows (just an array of row IDs) satisfying the search term.
  #
  def find_event_types
    event_type_ids = []

    # Avoid query build-up if no search text is given:
    if @query_term
      # Search among linked EventTypes:
      event_type_ids = EventType
          .joins( :stroke_type )
          .includes( :stroke_type )
          .find_all do |row|
        ( row.i18n_short =~ %r(#{@query_term})i ) ||
        ( row.i18n_compact =~ %r(#{@query_term})i ) ||
        ( row.i18n_description =~ %r(#{@query_term})i )
      end.map{ |row| row.id }.flatten.uniq
    end

    # Return the results:
    event_type_ids.uniq[ 0..@limit.to_i-1 ]
  end
  #-- --------------------------------------------------------------------------
  #++


  # Executes the search, using events
  # Fileds considered are:
  # - description
  # - code
  #
  # Returns Meeting rows (just an array of row IDs) satisfying the search term.
  #
  def search_in_events
    ids = []

    # Avoid query build-up if no search text is given:
    if @query_term
      search_like_text = "%#{@query_term}%"

      # Search among linked EventTypes:
      event_type_ids = find_event_types

      if event_type_ids.size > 0
        # Complete the list of IDs to be retrieved:
        ids += Meeting.select(:id)
            .joins( :meeting_events )
            .includes( :meeting_events )
            .where( :'meeting_events.event_type_id' => event_type_ids )
            .limit( @limit )
            .map{ |row| row.id }.flatten.uniq
      end
    end

    # Return the results:
    ids.uniq[ 0..@limit.to_i-1 ]
  end
  #-- --------------------------------------------------------------------------
  #++


  # Executes the search, evaluating teams involved in meeting
  # Fileds considered are:
  # - team name
  #
  # Returns Meeting rows (just an array of row IDs) satisfying the search term.
  #
  def search_in_teams
    ids = []

    # Avoid query build-up if no search text is given:
    if @query_term
      query_teams_condition    = ConditionsGeneratorColumnStringRegexped.generate_query_conditions(
        'teams',
        'name',
        @query_term
      )
      search_like_text = "%#{@query_term}%"

      # Search among linked Teams:
      ids += Meeting.select(:id)
          .joins( :teams )
          .includes( :teams )
          .where( query_teams_condition ).limit( @limit )
          .map{ |row| row.id }.flatten.uniq
    end

    # Return the results:
    ids.uniq[ 0..@limit.to_i-1 ]
  end
  #-- --------------------------------------------------------------------------
  #++


  # Executes the search, evaluating swimmers involved in meeting
  # Fileds considered are:
  # - swimmer name
  #
  # Returns Meeting rows (just an array of row IDs) satisfying the search term.
  #
  def search_in_swimmers
    ids = []

    # Avoid query build-up if no search text is given:
    if @query_term
      query_swimmers_condition = ConditionsGeneratorColumnStringRegexped.generate_query_conditions(
        'swimmers',
        'complete_name',
        @query_term
      )
      search_like_text = "%#{@query_term}%"

      # Search among linked Swimmers:
      ids += Meeting.select(:id)
          .joins( :swimmers )
          .includes( :swimmers )
          .where( query_swimmers_condition ).limit( @limit )
          .map{ |row| row.id }.flatten.uniq
    end

    # Return the results:
    ids.uniq[ 0..@limit.to_i-1 ]
  end
  #-- --------------------------------------------------------------------------
  #++


  # Executes the search, returning full row instances
  #
  def search
    # Avoid query build-up if no search text is given:
    @query_term ? Meeting.where( id: search_ids() ).limit( @limit ) :
                  Meeting.all.limit( @limit )
  end
  #-- --------------------------------------------------------------------------
  #++
end
