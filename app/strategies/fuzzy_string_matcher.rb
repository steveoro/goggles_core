# frozen_string_literal: true

require 'fuzzystringmatch'

#
# = FuzzyStringMatcher
#
#   - Goggles framework vers.:  4.00.617
#   - author: Steve A.
#
#  Generic strategy class dedicated to find best fuzzy matches
#  for a given text, provided a list of possible objects containing
#  candidates for matching values in one of its members.
#
#  The constructor allows to specify an alternative getter method to
#  retrieve the candidate value for the matching comparison.
#
class FuzzyStringMatcher

  # Bias score result for a fuzzy name search.
  # Default maximum (starting) value for #seek_deep_match.
  BIAS_SCORE_MAX  = 0.99

  # Bias score result for a fuzzy name search.
  # Default value for strict results.
  BIAS_SCORE_BEST = 0.98

  # Bias score result for a fuzzy name search.
  # Default minimum (ending) value for #seek_deep_match.
  #
  # This is used as lower limit for the iterative search if no matching
  # candidates are found. During the loop, if the minimum bias is not
  # reached, the match will be declared as inconclusive.
  # (With no results found)
  BIAS_SCORE_MIN  = 0.8

  # A more permissive bias score for the fuzzy search.
  # Used only as default value for single #find call.
  BIAS_SCORE_LAX  = 0.65
  #-- -------------------------------------------------------------------------
  #++

  # Creates a new instance.
  #
  # === Params:
  # - <tt>array_of_rows</tt>: a list of objects responding to #each and to the #getter_method; allows even empty lists.
  # - <tt>getter_method</tt>: method called on each object in the #array_of_rows to get the matching value
  # - <tt>alternative_getter_method</tt>: alternative method used to retrieve a second possible candidate value for the matching comparison (+nil+ as default)
  #
  def initialize(array_of_rows, getter_method, alternative_getter_method = nil)
    raise 'The array_of_rows does not support the :each and :size enumerator!' unless array_of_rows.respond_to?(:each) && array_of_rows.respond_to?(:size)

    unless array_of_rows.empty?
      raise "The first element of array_of_rows does not respond to '#{getter_method}'!" unless array_of_rows.first.respond_to?(getter_method)

      if alternative_getter_method
        raise "The first element of array_of_rows does not respond to '#{alternative_getter_method}'!" unless array_of_rows.first.respond_to?(alternative_getter_method)
      end
    end
    @array_of_rows     = array_of_rows
    @getter_method     = getter_method
    @alt_getter_method = alternative_getter_method
  end
  #-- -------------------------------------------------------------------------
  #++

  # Using a fuzzy-string matching metric, this method loops on all instances
  # supplied in the costructor to seek the highest-scoring match.
  #
  # The matching value can be any string.
  # The array can contain any Model/Class instance, as long as it responds to
  # the specified method to retrieve the comparison value (and to #each, to loop on
  # all the objects).
  #
  # A score_bias can be specified to override the minimum sufficient acceptable score
  # (default: #BIAS_SCORE_LAX -- which is kinda low and permissive, depending on the context).
  #
  # === Params:
  # - <tt>matching_string</tt>: the text to be searched among the array of rows
  # - <tt>score_bias</tt>: the minimum score that must be reached to be declared as a "successful match".
  #
  # === Returns:
  # A single row from the array with the best score.
  # +nil+ if none was found with a sufficient matching score (greater than the bias).
  #
  def find(matching_string, score_bias = BIAS_SCORE_LAX)
    result_row = nil
    matcher    = FuzzyStringMatch::JaroWinkler.create
    best_score = 0

    @array_of_rows.each do |row|
      comparison_string = row.send(@getter_method)
      match_score = matcher.getDistance(matching_string.upcase, comparison_string.upcase)
      if (match_score > score_bias) && (best_score < match_score)
        # DEBUG
        #        puts( "\r\nFuzzyStringMatcher::find('#{matching_string}'): checking '#{comparison_string}' => score: #{match_score}" )
        best_score = match_score
        result_row = row
      end
      # Search for a match also with the alternative getter, when provided
      if @alt_getter_method
        comparison_string = row.send(@alt_getter_method)
        match_score = matcher.getDistance(matching_string.upcase, comparison_string.upcase)
        if (match_score > score_bias) && (best_score < match_score)
          # DEBUG
          #          puts( "\r\nFuzzyStringMatcher::find('#{matching_string}'): checking '#{comparison_string}' => score: #{match_score} (alt.)" )
          best_score = match_score
          result_row = row
        end
      end
      break if best_score > 9.9999
    end
    result_row
  end
  #-- -------------------------------------------------------------------------
  #++

  # Similarly to #find(), uses a fuzzy string search and simply
  # collects the best matches found, given the bias score.
  #
  # Matches are collected in FIFO order, with each one selected having a better
  # score than the previous one. The resulting array is sorted on score,
  # in descending order.
  #
  # === Returns
  # An array of Hash having each element as:
  #
  #  { score: <match_score>, row: <match_row_instance> }
  #
  # Where the match_row_instance is a match that has scored higher than the bias.
  #
  def collect_matches(matching_string, score_bias = BIAS_SCORE_LAX)
    matcher    = FuzzyStringMatch::JaroWinkler.create
    results    = []
    best_score = 0

    @array_of_rows.each do |row|
      comparison_string = row.send(@getter_method)
      match_score = matcher.getDistance(matching_string.upcase, comparison_string.upcase)
      next unless (match_score > score_bias) && (best_score < match_score)

      # DEBUG
      #        puts( "\r\nFuzzyStringMatcher::collect_matches('#{matching_string}'): checking '#{comparison_string}' => score: #{match_score}" )
      results << { score: match_score, row: row }
    end
    results.sort! { |x, y| y[:score] <=> x[:score] }
  end
  #-- -------------------------------------------------------------------------
  #++

  # Iterates on itself using #collect_matches until at least a match is found or
  # the minimum bias score  is reached.
  #
  # Returns both the updated bias score and the result list of best-matches in
  # a single array:
  #
  #   [ updated_bias_score, result_list ]
  #
  # ...Where each item in the +result_list+ array is an Hash with this structure:
  #
  #   { score: <match_score>, row: <match_row_instance> }
  #
  # (The +result_list+ is of the same kind returned by #collect_matches)
  #
  def seek_deep_match(matching_string, bias_score = BIAS_SCORE_MAX, limit_bias_score = BIAS_SCORE_MIN)
    result_list   = collect_matches(matching_string, bias_score)
    total_matches = result_list.size
    # Search deeper using a more relaxed bias:
    if total_matches < 1 && bias_score > limit_bias_score
      new_bias_score, new_result_list = seek_deep_match(
        matching_string,
        bias_score - 0.01,
        limit_bias_score
      )
      bias_score  = new_bias_score
      result_list = (result_list + new_result_list).sort! { |x, y| y[:score] <=> x[:score] }
    end

    [bias_score, result_list]
  end
  #-- -------------------------------------------------------------------------
  #++

end
