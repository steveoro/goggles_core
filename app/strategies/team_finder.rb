# encoding: utf-8
require 'conditions_generator_column_string_regexped' # Used to generate simple_search query condition


=begin

= TeamFinder

 - Goggles framework vers.:  5.00
 - author: Steve A.

 Finder (strategy) class used to retrieve lists of Team instances based
 upon a "simple" search query.

 To reduce query overhead and API abuse, this finder instance will return an
 empty list if the query parameter is empty or unspecified.
 (MeetingFinder is the only finder class that allows empty query parameters so far.)

=end
class TeamFinder

  # Constructor
  #
  # == Params:
  # - query_term: the text to be searched; finder methods will return no matches for
  #               an empty or nil query term.
  #
  def initialize( query_term = nil )
    query_term = nil if query_term.to_s == ''
    @query_term = query_term
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
      # Search among Teams:
      query_condition = ConditionsGeneratorColumnStringRegexped.generate_query_conditions(
        'teams',
        'editable_name',
        @query_term
      )
      ids += Team.select(:id).where( query_condition ).map{ |row| row.id }.flatten.uniq

      # Search among other most-used text columns in Team:
      search_like_text = "%#{@query_term}%"
      ids += Team.select(:id).where(
        [
          "(name LIKE ?) OR (name_variations LIKE ?) OR (contact_name LIKE ?) OR (notes LIKE ?)",
          search_like_text, search_like_text, search_like_text, search_like_text
        ]
      ).map{ |row| row.id }.flatten.uniq
    end
    # Return the results:
    ids.uniq
  end
  #-- --------------------------------------------------------------------------
  #++


  # Executes the search, returning full row instances
  #
  def search
    Team.where( id: search_ids() )
  end
  #-- --------------------------------------------------------------------------
  #++
end
