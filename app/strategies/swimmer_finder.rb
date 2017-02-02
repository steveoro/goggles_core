# encoding: utf-8
require 'conditions_generator_column_string_regexped' # Used to generate simple_search query condition


=begin

= SwimmerFinder

 - Goggles framework vers.:  6.071
 - author: Steve A.

 Finder (strategy) class used to retrieve lists of Swimmer instances based
 upon a "simple" search query.

 To reduce query overhead and API abuse, this finder instance will return an
 empty list if the query parameter is empty or unspecified.
 (MeetingFinder is the only finder class that allows empty query parameters so far.)

=end
class SwimmerFinder

  # Constructor
  #
  # == Params:
  # - query_term: the text to be searched; finder methods will return no matches for
  #               an empty or nil query term.
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
  # rows satisfying the search term.
  # Returns an empty array in case of no matches found.
  #
  def search_ids
    ids = []
    # Avoid query build-up if no search text is given:
    if @query_term
      # Search among Swimmers:
      query_condition = ConditionsGeneratorColumnStringRegexped.generate_query_conditions(
        'swimmers',
        'complete_name',
        @query_term
      )
      ids += Swimmer.select(:id).where( query_condition ).limit( @limit )
        .map{ |row| row.id }.flatten.uniq

      # Search among other most-used text columns in Swimmer:
      search_like_text = "%#{@query_term}%"
      ids += Swimmer.select(:id).where(
        [
          "(nickname LIKE ?) OR (e_mail LIKE ?)",
          search_like_text, search_like_text
        ]
      ).limit( @limit ).map{ |row| row.id }.flatten.uniq
    end
    # Return the results:
    ids.uniq[ 0..@limit.to_i-1 ]
  end
  #-- --------------------------------------------------------------------------
  #++


  # Executes the search, returning full row instances
  #
  def search
    Swimmer.where( id: search_ids() ).limit( @limit )
  end
  #-- --------------------------------------------------------------------------
  #++
end
