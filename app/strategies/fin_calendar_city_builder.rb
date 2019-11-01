# encoding: utf-8
require 'common/format'

=begin

= FinCalendarCityBuilder

  - Goggles framework vers.:  6.131
  - author: Steve A.

 Finds or creates a City instance given the parameters.

 The builder first tries to extract as much information as possible from the given
 source text line and the "fallback" meeting place, extracted from the Meeting
 calendar itself.

 If no existing city name is extracted and found from the parsed source text line,
 the builder instance will try to find an existing City from the given meeting_place
 name.

 A new row will be created only if both steps will fail.


 === Finder/Builder strategy:

 0. Extract city name from given source text
 1. Primary search:   => Seek existing City using extracted token(s)
 2. Secondary search: => Seek existing City using meeting_place
 3. City name empty? => Report missing data
 4. Not found and City name not empty? => Create new City and log the action
 5. Return the instance (either new or found/updated)

=end
class FinCalendarCityBuilder < FinCalendarBaseBuilder

  attr_reader :result_city

  # Creates a new instance, given the current user that has "recorded" this batch
  # of operations.
  #
  # The source_text_line should contain only information regarding the swimming
  # pool, its address and, obviously, the city name.
  #
  # The meeting_place should act as a fall-back in case the address information
  # is incomplete.
  #
  def initialize( current_user, source_text_line, meeting_place, honor_single_update = true, geocoder_api_key = nil  )
    super( current_user )
    raise ArgumentError.new('source_text_line must be a string (even empty)!') unless source_text_line.instance_of?( String )
    raise ArgumentError.new('meeting_place must be a string (even empty)!') unless meeting_place.instance_of?( String )
    @source_text_line = source_text_line
    @meeting_place = meeting_place
    @honor_single_update = honor_single_update
    @result_city = nil
    @geocode_result_hash = nil
    @geocoder = nil
    @geocoder_api_key = geocoder_api_key
    create_sql_diff_header( "FinCalendarCityBuilder: recorded from actions by #{ current_user }; meeting_place: '#{ meeting_place }'" )
    add_to_log( "\t······························\r\n\t··· FinCalendarCityBuilder ···\r\n\t······························" )
    add_to_log( "- source_text_line: <<#{ source_text_line }>>" )
    add_to_log( "- honor_single_update:  * ON *" ) if @honor_single_update
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the swimming_pool city name extracted from the text specified and split into
  # individual "tokens".
  #
  # The implementation reuses some class helpers from FinCalendarTextParser and
  # FinCalendarSwimmingPoolBuilder
  # @see FinCalendarTextParser, FinCalendarSwimmingPoolBuilder
  #
  def self.parse_pool_city_name_tokens( pool_text )
    # Filter out the interesting parts regarding the swimming pool:
    pool_parts = FinCalendarTextParser.get_filtered_pool_data_tokens( pool_text )
    pool_name_tokens = FinCalendarSwimmingPoolBuilder.parse_pool_name_tokens( pool_text.gsub(/[\`\’]/iu, "'") )
    pool_addr_tokens = FinCalendarSwimmingPoolBuilder.parse_pool_address_tokens( pool_text )
# DEBUG
    puts "\r\n- pool_parts..................: #{ pool_parts.inspect }"
    puts "- pool_name_tokens............: #{ pool_name_tokens.inspect }"
    puts "- pool_addr_tokens............: #{ pool_addr_tokens.inspect }"

    # Subtract *single* occurencies of name & cut away the address tokens from pool parts:
    remainder = FinCalendarTextParser.subtract_set_behaviour( pool_parts, pool_name_tokens )

    remainder_max_res = remainder.join(" ").scan(/[\wòàèéìùç\/\\\`\'°\^\(\)]+/ui)
    address_max_res   = pool_addr_tokens.join(" ").scan(/[\wòàèéìùç\/\\\`\'°\^\(\)]+/ui)
    partitioned_remainder = remainder_max_res.join(" ").partition( address_max_res.join(" ") )
# DEBUG
    puts "- remainder_max_res............: #{ remainder_max_res.inspect }"
    puts "- address_max_res..............: #{ address_max_res.inspect }"
    puts "- partitioned_remainder .......: #{ partitioned_remainder.inspect }"
    remainder = [ partitioned_remainder.first, partitioned_remainder.last ]
# DEBUG
    puts "- remainder before splitting...: #{ remainder.inspect }"
    remainder = remainder.map do |sentence|
      FinCalendarTextParser.split_in_sentences( sentence, true ) # split_using_spaces: true => sub-sentences of tokens
    end
      .flatten

# DEBUG
    puts "- remainder before drop........: #{ remainder.inspect }"
    # Drop leading empty tokens and check also for leading preposition:
    resulting_tokens = remainder.drop_while do |token|
      token.to_s.strip.empty? ||
      (token.to_s.strip =~ /
          \b\d{1,}\b|
          \bdi\b|\ba\b|
          ^[\,\.”\”\"\']\Z|
          \bsit[oa]\b|\bin\b|^del(l[ao\']?)?\b|^degli|\bpresso\b|\bc\/o\b|
          \bpiscina\b|\bcomunale\b|\bstadio\b|\bsport\b|\bnuoto\b
        /uxi
      )
    end
# DEBUG
    puts "=> resulting tokens............: #{ resulting_tokens.inspect } (size: #{ resulting_tokens.size }, addr: #{ pool_addr_tokens.size })"

    # Remove also any possible phone number:
    if resulting_tokens.first.to_s =~ /\btel\b|\btelefono\b/ui
      resulting_tokens = resulting_tokens.drop_while do |token|
        token.to_s.strip.empty? ||
        ( token.to_s.strip =~ /\btel\b|\btelefono\b|\b\d+\b/ui )
      end
# DEBUG
      puts "=> after phone removal.........: #{ resulting_tokens.inspect }"
    end

    # If the remainder resulting tokens are empty, we need to check "recursively"
    # the address tokens, since the City name may be there:
    if resulting_tokens.size < 1 && pool_addr_tokens.size > 0
# DEBUG
      puts "\r\n   EMPTY resulting tokens! 'Recursive' check on address tokens (#{ pool_addr_tokens.inspect }):"
      resulting_tokens = remainder.map do |sentence|
        FinCalendarTextParser.split_in_sentences( pool_addr_tokens.join(" "), true ) # split_using_spaces: true => sub-sentences of tokens
      end
        .flatten
# DEBUG
      puts "=> resulting tokens from addr..: #{ resulting_tokens.inspect }"
      resulting_tokens = resulting_tokens.drop_while do |token|
        # Search for a "belonging to" preposition or a separator:
        (token.to_s.strip =~ /^[\,\.\”\"\']\Z|\bdi\b|\ba\b/ui).nil?
      end
      # Drop also the preposition found and consider the remainder as a possible city name::
      resulting_tokens = resulting_tokens.drop_while do |token|
        # Search for a "belonging to" preposition or a separator:
        (token.to_s.strip =~ /^[\,\.\”\"\']\Z|\bdi\b|\ba\b/ui)
      end
    end

    # Consider the "leftovers" as actual possible name and strip-out the remaining empty separators:
    resulting_tokens = resulting_tokens.reject{ |token| token.to_s.strip.size == 0 }

# DEBUG
    puts "=> resulting toks. before take: #{ resulting_tokens.inspect }"
    # Drop trailing leftovers from address description:
    resulting_tokens = resulting_tokens.take_while do |token|
      (token.to_s.strip =~ /
          \(\w\w\)?\Z|
          ^[\,\.\”\"\']\Z|
          \bsit[oa]\b|\bin\b|\bpresso\b|\bc\/o\b|
          \bpiscina\b|\bvasca\b|\bcorsie\b|\bimpianto\b|\bprofondit|\bgara\b|\bmattonelle\b|\bacci?aio\b|
          \briscaldamento\b|
          \bvia\b|\bviale\b|\bv.le\b|\blaterale\b|\bzona\b|
          \bp\.z?za\b|\bpiazza\b|\bvi?c?.l[eo]\b|
          \bvicolo\b|\bvic\.\b|
          \bcorso\b|\bc.so\b|\bcomplesso\b|\bcomp\.\b|\bparcheggio\b|
          \bcirconvallazione\b|\bcirc(onv)?(al)?.ne\b|
          \bcontrada\b|\bc.da\b|\bct.da\b|
          \bpasseggio\b|\bpasso\b|\bp\.gio\b
          \bpass\w+\b|\blung\w+\b|\blargo\b|\bstretto\b
        /uxi
      ).nil?
    end
# DEBUG
    puts "=> resulting toks. AFTER take : #{ resulting_tokens.inspect }"

    # Remove possible duplicated city names (e.g. "Roma, Roma (ROMA)") and sanitize:
    resulting_tokens = resulting_tokens.map do |name|
      # Parenthesyzed very short name? (Possible city name abbreviation)
      if name.to_s =~ /[\(\)\/\\]/ui
        # Clean leftover brakets
        name = name.to_s.gsub(/[\(\)\/\\]/ui, '').strip
        name.size <= 3 ? name.upcase : name
      else
        # XXX At this point, any leftover braket belonging to a token is either noise
        # (address explanation or pool name explanation) or it's probably an additional
        # description for the address and it should belong to it.
        # Nevertheless, we'll search for an existing city checking each token value
        # reported here.
        name.to_s.camelcase.strip
      end
    end.uniq.compact.reject{ |token| token.to_s.strip.size == 0 }
# DEBUG
    puts "=> res. tokens @end..: #{ resulting_tokens.inspect }"
    resulting_tokens
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the memoized internal GeocodingParser instance.
  # It will also invoke its API call to init the GeocodingParser result, if it
  # hasn't been called before.
  #
  # Keep in mind that this getter may return nil on certain exceptional cases.
  #
  def get_geocoder()
     get_geocode_result( @geocoder_api_key )
     @geocoder
  end


  # Returns the memoized result Hash obtained from the internal GeocodingParser
  # instance, called upon the source text line (containing, allegedly, the full address
  # of the swimming pool).
  #
  def get_geocode_result( geocoder_api_key = nil )
    # Redundant safety quote conversion: (already taken care by GeocodingParser later)
    address = @source_text_line.gsub(/[\“\`]/ui, "'")
    address = @meeting_place unless address.present?
    unless @geocode_result_hash || !address.present?
      @geocoder = GeocodingParser.new( address )
      begin
        @geocoder.make_api_request( geocoder_api_key )
        @geocoder.extract_data!
        # Export extracted & reformatted data from GeoCoding:
        @geocode_result_hash = @geocoder.get_result_dao_as_hash()
      rescue
        # Resets the GeoCode result in case of Net::HTTP error:
        @geocode_result_hash = nil
      end
    end
    @geocode_result_hash
  end
  #-- -------------------------------------------------------------------------
  #++


  # Finds or creates a City instance using the #source_text_line given in the
  # constructor.
  #
  # If force_geocoding_search is +true+, even if a City is found it will be compared
  # to (and updated with) the values returned from the internal GeocodingParser instance.
  #
  # The returned City instance, which is also available through the member #result_city,
  # may be changed or updated by the process, logging both the action result as well as
  # the SQL involved.
  #
  # === Search/Create strategy precedence:
  #
  # 1) CityComparator search w/ Name, composed by city tokens (pool_city_tokens)
  # 2) CityComparator search w/ Meeting place name, extracted from FIN Calendar (@meeting_place)
  # 3) GeocodingParser search w/ full address text (@source_text_line)
  #    3.1) => Re-search using CityComparator for existing City using returned value from GeocodingParser ("locality_name")
  # 4) Create new w/ GeocodingParser results if set; otherwise use 2) if set, or 1)
  #
  def find_or_create!( force_geocoding_search = false )
    # Bail out if we have already found a result:
    if @result_city.instance_of?( City )
      add_to_log( "\r\nfind_or_create!() re-called. Returning previous city '#{ @result_city.name }'..." )
      return @result_city
    end

    pool_city_tokens = FinCalendarCityBuilder.parse_pool_city_name_tokens( @source_text_line )
    name = pool_city_tokens.join(' ')[0..49]        # Respect maximum length for City names
    zip  = '?'                                      # Set the default unknown zip code and country
    country = 'ITALIA'
    country_code = 'IT'
    user_id = @current_user.id
    area = nil
    area_type_id = nil
                                                    # --- SEARCH #1 ---
    add_to_log( "\r\nSearching using name from pool city tokens: '#{ name }'" )
    @result_city = CityComparator.new.search_composed_name( name )
                                                    # --- SEARCH #2 ---
    # Not found? Search again using @meeting_place:
    unless @result_city.instance_of?( City )
      name = @meeting_place
      add_to_log( "Searching using meeting place: '#{ name }'..." )
######################################################################
      # FinCalendarSwimmingPoolBuilder.parse_pool_address_tokens( pool_text )
#############
      @result_city = CityComparator.new.search_composed_name( name )
    end
                                                    # --- GEOCODING ---
    # Not found? Search again using the GeocodingParser:
    if @result_city.nil? && force_geocoding_search
      name, zip, area, area_type_id, country, country_code = geocoding_search( force_geocoding_search )
                                                    # --- SEARCH #3 ---
      add_to_log( "Searching again, using returned name from geoconding: '#{ name }'..." )
      @result_city = CityComparator.new.search_composed_name( name )
      if @result_city.instance_of?( City )
        add_to_log( "City found! => #{ @result_city.inspect }" )
                                                    # --- UPDATE ---
        # Force update of the found instance with the correct values if there are
        # any differences (when @honor_single_update is disabled).
        # Or, in case @honor_single_update is ON, do the update only if the date-time
        # of 30 minutes ago is more recent then the latest update on the row.
        if name.present? && zip.present? && country_code.present? && country.present? && (
             ( @result_city.name != name ) || ( @result_city.zip != zip ) ||
             ( @result_city.country_code != country_code ) ||
             ( @result_city.country != country )
           ) &&
           (
             !@honor_single_update ||
             ( @result_swimming_pool && @honor_single_update && ( 30.minutes.ago > @result_swimming_pool.updated_at ) )
           )
          update_existing( name, zip, country_code, country, area, area_type_id, user_id )
        end
        if ( @result_swimming_pool && @honor_single_update && ( 30.minutes.ago > @result_swimming_pool.updated_at ) )
          add_to_log( "Difference in values found, but @honor_single_update is ON. Skipping update..." )
        end
      end
    else
      add_to_log( "City found! => #{ @result_city.inspect }" )
    end
                                                    # --- CREATION ---
    # Not found? Create a new one:
    unless @result_city.instance_of?( City )
      create_new( name, zip, country_code, country, area, area_type_id, user_id )
    else
      add_to_log( "City found! => #{ @result_city.inspect }" )
    end

    @result_city
  end
  #-- -------------------------------------------------------------------------
  #++


  private


  # Performs a gecodingParser search, returning the "formatted" values for all
  # the main fields that define a City instance.
  #
  # The internal GecodingParser instance gets also memoized in the process.
  #
  def geocoding_search( force_geocoding_search )
    add_to_log( "Searching with GeocodingParser using @source_text_line...#{ force_geocoding_search ? ' (FORCED)' : '' }" )
    geocoder = get_geocoder

    if geocoder.instance_of?( GeocodingParser )
      # Override values w/ actual name, zip, country, country_code & area_type:
      name = geocoder.locality_name                                             # ex.: "Albinea"
      zip  = geocoder.postal_code_name                                          # ex.: "42020"
      area = geocoder.administrative_area_level_3_name                          # "Reggio nell'Emilia"
      # Sometimes the locality_name is not set and the Area (level 3) name should take over:
      name = area unless name.present?
      area_type_code = geocoder.administrative_area_level_2_name                # "RE"
      country_code   = geocoder.country_name                                    # ex.: "IT"
      country = ( country_code == 'IT' ? 'ITALIA' : country_code )
      area_type = AreaType.find_by_code( area_type_code )
      area_type_id = area_type.nil? ? nil : area_type.id
      add_to_log( "Geocoded result => #{ name }, zip: #{ zip }, #{ country } (#{ country_code }), area: #{ area }" )
      [ name, zip, area, area_type_id, country, country_code ]

    else
      add_to_log( "Warning: cannot create a GeocodingParser instance using current source text line! Returning nil values for address & area..." )
      [ nil, nil, nil, nil, 'ITALIA', nil ]
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  # Creates a new City instance setting its value to @result_city while logging the operation.
  #
  def create_new( name, zip, country_code, country, area, area_type_id, user_id )
    add_to_log( "City NOT found. Creating a new one as: '#{ name }', zip: #{ zip }, #{ country } (#{ country_code })" )
    @result_city = City.new(
      name:         name,
      zip:          zip,
      country:      country,
      country_code: country_code,
      area:         ( area.present? ? area : '?' ),
      area_type_id: area_type_id,
      user_id:      user_id
    )
    # Serialize the creation:
    super( @result_city, self.class.name )
  end
  #-- -------------------------------------------------------------------------
  #++


  # Updates @result_city with new values (assuming it is an instance of City)
  # while logging the operation.
  #
  def update_existing( name, zip, country_code, country, area, area_type_id, user_id )
    add_to_log( "Updating existing city with: '#{ name }', zip: #{ zip }, #{ country } (#{ country_code })" )
    @result_city.name = name
    @result_city.zip = zip unless zip == '?'
    @result_city.country_code = country_code
    @result_city.country = country
    @result_city.area = area if area.present?
    @result_city.area_type_id = area_type_id unless area_type_id.nil?
    @result_city.user_id = user_id

    sql_attributes = @result_city.attributes.select do |key|
      [ 'name', 'zip', 'country_code', 'country', 'area', 'area_type_id', 'user_id' ].include?( key.to_s )
    end
    # Serialize the update:
    super( @result_city, sql_attributes, self.class.name )
  end
  #-- -------------------------------------------------------------------------
  #++
end
