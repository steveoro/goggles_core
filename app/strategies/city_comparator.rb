# frozen_string_literal: true

# require_relative '../../../strategies/fuzzy_string_matcher'

#
# = CityComparator
#
#   - Goggles framework vers.:  6.114
#   - author: Steve A.
#
#  Generic strategy class dedicated to compare City names taking
#  into account possible abbreviations and naming variations.
#
class CityComparator

  # Searches for existing matching city names, assuming the
  # specified "composed" name contains the name of target city.
  #
  # === Params:
  # - team_or_composed_name: a name allegedly containing the city name to be searched.
  # - entity: the entity to be used for the search; defaults to City.
  #
  # === Returns
  # The first matching entity instance or +nil+ when none are found.
  #
  def search_composed_name( team_or_composed_name, entity = City )
    raise ArgumentError, "'entity' must be an ActiveRecord model responding to :name!" unless entity.new.is_a?( ActiveRecord::Base ) && entity.new.respond_to?(:name)

    # DEBUG
    #    puts "\r\nCityComparator.search_composed_name( '#{team_or_composed_name}' )"
    tokens = self.class.get_token_array_from_city_member_name( team_or_composed_name )
    tokens = tokens.delete_if { |token| token =~ /csi|scuola|accadem|team|club|united|asd|nuot|swim|\d/i }
    search_token = tokens.first
    # Try to use another token if the first one is just a letter:
    search_token = tokens.last if search_token.to_s.length < 2 && tokens.last.present? && tokens.last.to_s.length > 1
    trimmed_name = tokens.join(' ')
    # DEBUG
    #    puts "search_token: '#{ search_token }' (trimmed_name: '#{ trimmed_name }')"
    result = nil
    possible_names = search_token.present? ? entity.where( ['name LIKE ?', "%#{ search_token }%"] ) : []

    # DEBUG
    #    puts "possible_names: #{ possible_names.to_a.inspect }"
    unless possible_names.empty?
      matcher = FuzzyStringMatcher.new( possible_names, :name )
      bias_score, result_list = matcher.seek_deep_match( trimmed_name )
      # DEBUG
      #      puts "result_list using fuzzy match: #{result_list.inspect}"
      result_hash = result_list.first
      result = result_hash[:row] if result_hash.instance_of?( Hash )
    end
    # Force a fallback to the first entity row found if we have one and the FuzzyStringMatcher
    # has been too severe:
    result = possible_names.first if result.nil? && !possible_names.empty?
    result
  end
  #-- -------------------------------------------------------------------------
  #++

  # Strips a City or Area or Country name of common prefixes, abbreviations and
  # connections or grammar characters, in a sort of a "normalization process".
  #
  # Note that this name should only be used on City members or places names,
  # since rules for abbreviating persons' names do not apply in the same manner.
  #
  # === Returns
  # An array or "normalized" tokens that, if joined together,
  # still "look like" the actual name of the city.
  #
  def self.get_token_array_from_city_member_name( full_city_name )
    arr_of_tokens = full_city_name.to_s.split( /[\'\,\s\.]/ )
    arr_of_tokens.delete_if do |el|
      # Add here more frequently used abbreviations:
      [
        'from', 'to', 'the',
        'di', 'ne', 'nel', 'nell', 'del', 'dell', 'in',
        'su', 'sul', 'sull',
        'da', 'dal', 'dall', 'san', 's', 'sant', ''
      ].include?(el.downcase)
    end
  end

  # Compare two city-related names (either city name, area or country),
  # using the normalization process from #get_token_array_from_city_member_name().
  #
  # The first name is matched against the second, translated as a Regexp.
  #
  # Note that this name should only be used on City members or places names,
  # since rules for abbreviating persons' names do not apply in the same manner.
  #
  # === Returns
  # true if there seems to be a match, false otherwise.
  #
  def self.compare_city_member_strings( city_member_name_1, city_member_name_2 )
    normalized_name_1  = get_token_array_from_city_member_name( city_member_name_1 ).join(' ')
    normalized_array_2 = get_token_array_from_city_member_name( city_member_name_2 )
    reg = Regexp.new( normalized_array_2.join('\s.*'), Regexp::IGNORECASE ) if normalized_array_2.instance_of?(Array)
    match = ( normalized_name_1 =~ reg )
    !match.nil?
  end
  #-- -------------------------------------------------------------------------
  #++

  # Strips a City or Area or Country name of common prefixes, abbreviations and
  # connections or grammar characters, in a sort of a "normalization process",
  # and checks to see if they may refer to the same City.
  #
  # === Returns
  # +true+ if the comparison "seems a match".
  #
  def self.seems_the_same( city_name_1, city_name_2,
    area_name_1,    area_name_2,
    country_code_1, country_code_2 )
    ( compare_city_member_strings( city_name_1, city_name_2 ) &&
      compare_city_member_strings( area_name_1, area_name_2 ) &&
      (country_code_1.upcase == country_code_2.upcase)
    )
  end
  #-- -------------------------------------------------------------------------
  #++

end
