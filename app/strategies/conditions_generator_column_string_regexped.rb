# frozen_string_literal: true

#
# = ConditionsGeneratorColumnStringRegexped
#
#   - version:  4.00.665
#   - author:   Steve A.
#
#   Customized ConditionsGeneratorColumn wrapper/strategy class.
#
#   Forces the usage of RLIKE or REGEXP instead of LIKE for any query text. Any compound
#   search text is splitted in search tokens before preparing the query.
#
#   Remember that this class name must be added to the array of
#   Wice::Defaults::ADDITIONAL_COLUMN_PROCESSOR in config/initializers/wice_grid_config.rb
#   when customizing WiceGrid behaviour.
#
class ConditionsGeneratorColumnStringRegexped

  # Generate an array of search conditions given the parameters.
  #
  def self.generate_query_conditions(table_alias, field_name, search_text, negation = '')
    search_tokens = search_text.split(/\s+/)
    query_text = []
    search_tokens.each do |_token|
      query_text << "#{table_alias}.#{field_name} REGEXP(?)"
    end
    [
      " #{negation} (" << query_text.join(' AND ') << ')'
    ] + search_tokens
  end
  #-- -------------------------------------------------------------------------
  #++

end
#-- ---------------------------------------------------------------------------
#++
