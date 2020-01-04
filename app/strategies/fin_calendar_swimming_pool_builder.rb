# encoding: utf-8
require 'common/format'

=begin

= FinCalendarSwimmingPoolBuilder

  - Goggles framework vers.:  6.329
  - author: Steve A.

 Finds or creates a SwimmingPool instance given the parameters.

 The builder first tries to extract as much information as possible from the given
 source text line and the "fallback" meeting place, extracted from the Meeting
 calendar itself.

 If no existing swimming pool is found from the parsed source text line and the
 meeting_place stored inside the given +parse_result_dao+, a new row will be created.


 === Finder/Builder strategy:

 1. Extract name and address from given source text
 2. SEARCH #1: search by nick_name & pool_type
 3. SEARCH #2: collect all same-typed pools for the same city and check among them by "simplified" nickname
 4. Repeat search #1 & #2 changing the pool type, if necessary.
 7. SEARCH #6: (fallback, in case no pool name is parsed) search just by city_id & pool_type and get the first found.
 8. Not found? => Create a new SwimmingPool using the formatted data from the API and log the action
 9. Return the instance (either new or found)


=end
class FinCalendarSwimmingPoolBuilder < FinCalendarBaseBuilder

  attr_reader :result_swimming_pool, :city_builder

  # Creates a new instance, given the current user that has "recorded" this batch
  # of operations.
  #
  # The source_program_text should contain the whole information about the meeting program,
  # the swimming pool, its address and, obviously, the city name.
  #
  # The meeting_place should act as a fall-back in case the address information
  # is incomplete.
  #
  # The instance will create an internal FinCalendarCityBuilder to analize the
  # source text and parse a (possible) valid City instance to link to the result
  # SwimmingPool.
  #
  def initialize( current_user, parse_result_dao, source_program_text, honor_single_update = true, geocoder_api_key = nil )
    super( current_user )
    raise ArgumentError.new('parse_result_dao must be defined!') unless parse_result_dao.instance_of?( FinCalendarParseResultDAO )
    raise ArgumentError.new('source_program_text must be a string (even empty)!') unless source_program_text.instance_of?( String )
    @parse_result_dao = parse_result_dao
    @source_program_text = source_program_text
    @honor_single_update = honor_single_update
    @result_swimming_pool = nil
    create_sql_diff_header( "FinCalendarSwimmingPoolBuilder recorded from actions by #{ current_user }" )
    add_to_log( "\t······································\r\n\t··· FinCalendarSwimmingPoolBuilder ···\r\n\t······································" )
    add_to_log( "- honor_single_update:  * ON *" ) if @honor_single_update

    # Instantiate an internal City builder w/ just the line concerning the pool:
    @filtered_pool_text = if @parse_result_dao.pool_override_text.present?
      @parse_result_dao.pool_override_text
    else
      FinCalendarTextParser.get_filtered_pool_data_text( source_program_text )
    end
    add_to_log( "- filtered_pool_text: <<#{ @filtered_pool_text }>>\r\n" )
    @city_builder = FinCalendarCityBuilder.new(
      current_user,
      @filtered_pool_text,
      @parse_result_dao.meeting_place,
      @honor_single_update,
      geocoder_api_key
    )
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the swimming_pool name text extracted from the text specified and split
  # into individual "tokens".
  #
  # The implementation reuses some class helpers from FinCalendarTextParser.
  # @see FinCalendarTextParser
  #
  def self.parse_pool_name_tokens( pool_text )
    # Filter out the interesting parts regarding the swimming pool:
    pool_parts = FinCalendarTextParser.get_filtered_pool_data_tokens( pool_text )

# DEBUG
#    puts "\r\n- pool_parts before splitting....: #{ pool_parts.inspect }"
    pool_name_tokens = pool_parts.map do |sentence|
      FinCalendarTextParser.split_in_sentences( sentence, true ) # split_using_spaces: true => sub-sentences of tokens
    end
      .flatten

# DEBUG
#    puts "=> pool_name tokens before take: #{ pool_name_tokens.inspect }"
    pool_name_tokens = pool_name_tokens.take_while do |token|
      (token =~ /
          \bvia\b|\bpresso\b|\bc\/o\b|\blocalit.\b|\bvicin.|
          \bsit[oa]\b|\bin\b|\b\d{4,}\b
        /uxi
      ).nil? &&
      (token.to_s.strip.length != 0)
    end

# DEBUG
#    puts "=> pool_name tokens before leading prep. remove: #{ pool_name_tokens.inspect }"
    # Reject leading empty tokens, prepositions or sentence separators:
    pool_name_tokens = pool_name_tokens.drop_while do |token|
      ( token.to_s.strip.size == 0 ) ||
      ( token.to_s =~ /
          ^di\b|
          ^del(l[ao\']?)?\b|
          ^degli|
          ^[\,\.”\”\"\']\s?\Z|
          ^piscina\b
        /uxi
      )
    end if pool_name_tokens.size > 1

    # Check if the text has a special preposition used only when describing
    # the pool name: (i.e.: "piscina denominata XYZ" - a very rare case, but existing)
    pool_name_preposition_token = pool_name_tokens.detect{ |token| token =~ /denominata/ui }
    if pool_name_preposition_token.present?
      # If we've found such preposition/prefix, we assume the pool name starts
      # actually *after* it, so we keep only the tokens from the subsequent
      # position to the end:
      pool_name_allegedly_start_index = pool_name_tokens.index( pool_name_preposition_token )
      pool_name_tokens = pool_name_tokens[ pool_name_allegedly_start_index+1 .. -1 ]
    end

# DEBUG
#    puts "=> pool_name tokens AFTER leading prep. remove: #{ pool_name_tokens.inspect }"

    # Since we have now removed any leading preposition out of the way, we can
    # keep the (allegedly) leading "name part", up until another sentence separator
    # or another ownership or location preposition is found:
    pool_name_tokens = pool_name_tokens.take_while do |token|
      (token =~ /
          ^[\,\.”\”\"\']\s?\Z|
          ^di\b|
          ^del(l[ao\']?)?\s(?!nuoto|sport)|
          ^l\'(?!\w+|\s)
          ^degli|
          \bvia\b|\bpresso\b|\bc\/o\b|\blocalit.\b|\bvicin.|
          \bsit[oa]\b|\bin\b|\b\d{4,}\b|[\(\)]|
          \bviale\b|\bv.le\b|
          \bp\.z?za\b|\bpiazza\b|\bvi?c?.l[eo]\b|
          \bvicolo\b|\bvic\.\b|
          \bcorso\b|\bc.so\b|\bcomplesso\b|\bcomp\.\b|\bparcheggio\b|
          \bcirconvallazione\b|\bcirc(onv)?(al)?.ne\b|
          \bcontrada\b|\bc.da\b|\bct.da\b|
          \bpasseggio\b|\bpasso\b|\bp\.gio\b
          \bpass\w+\b|\blung\w+\b|\blargo\b|\bstretto\b
        /uxi
      ).nil? &&
      (token.to_s.strip.length != 0)
    end

# DEBUG
#    puts "=> pool_name tokens before reject: #{ pool_name_tokens.inspect }"
    # Strip out remaining separators and ownership prepositions:
    pool_name_tokens = pool_name_tokens.reject do |token|
      ( token.to_s.strip.size == 0 ) ||
      ( token.to_s.strip =~ /
          ^[\,\.”\”\"\']\s?\Z|
          ^del(l[ao\']?)?\b
        /uxi
      )
    end
    # Clear out any remaining double quotes (these must be considered as "anomalies"):
    pool_name_tokens = pool_name_tokens.map{ |token| token.to_s.gsub(/[\"\``\“”]/ui, '') }

# DEBUG
#    puts "=> pool_name tokens AFTER reject: #{ pool_name_tokens.inspect }"
    pool_name_tokens
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the swimming_pool address text extracted from the text specified and split
  # into individual "tokens".
  #
  # The implementation reuses some class helpers from FinCalendarTextParser.
  # @see FinCalendarTextParser
  #
  def self.parse_pool_address_tokens( pool_text )
    # Filter out the interesting parts regarding the swimming pool:
    pool_parts = FinCalendarTextParser.get_filtered_pool_data_tokens( pool_text )
    pool_name_tokens = FinCalendarSwimmingPoolBuilder.parse_pool_name_tokens( pool_text )
# DEBUG
#    puts "\r\n- pool_parts.....: #{ pool_parts.inspect }"
#    puts "- pool_name_tokens...: #{ pool_name_tokens.inspect }"
    # Subtract *single* occurencies of name & address tokens from pool parts:
    remainder = FinCalendarTextParser.subtract_set_behaviour( pool_parts, pool_name_tokens )
# DEBUG
#    puts "- remainder before splitting..: #{ remainder.inspect }"
    remainder = remainder.map do |sentence|
      FinCalendarTextParser.split_in_sentences( sentence, true ) # split_using_spaces: true => sub-sentences of tokens
    end
      .flatten
# DEBUG
#    puts "- remainder AFTER splitting...: #{ remainder.inspect }"

    resulting_tokens = remainder.drop_while do |token|
      (token =~ /
          \bvia\b|\blocalit.\b|
          \bviale\b|\bv.le\b|
          \bp\.z?za\b|\bpiazza\b|\bvi?c?.l[eo]\b|
          \bvicolo\b|\bvic\.\b|
          \bcorso\b|\bc.so\b|\bcomplesso\b|\bcomp\.\b|\bparcheggio\b|
          \bcirconvallazione\b|\bcirc.ne\b|\bcirconv.ne\b|\bcirconval.ne\b|
          \bcontrada\b|\bc.da\b|\bct.da\b|
          \bpasseggio\b|\bpasso\b|\bp\.gio\b
          \bpass\w+\b|\blung\w+\b|\blargo\b|\bstretto\b
        /uxi
      ).nil?
    end
# DEBUG
#    puts "=> resulting tokens..: #{ resulting_tokens.inspect }"
    # Strip out remaining separators:
    resulting_tokens = resulting_tokens.reject do |token|
      (token.to_s.strip.size == 0) || (token.to_s.strip =~ /^[\,\.”\”\"\']\Z/ui)
    end
    # Keep the address up until we find a civic number or a phone num. (usually at the end):
    address_tokens = resulting_tokens.take_while do |token|
      (token =~ /\d{1,}\b|\bsnc\b|\btel\b/ui).nil?        # ("snc" = "senza numero civico", w/o civic number)
    end
    # Add the last (skipped) token, which allegedly should be a number:
    skipped_civic_number = (resulting_tokens - address_tokens).first
    address_tokens = address_tokens.compact
    # Add a civic number if found, separated by a comma:
    if skipped_civic_number.present?
      # For some cases, we need to add the comma before the last token or even
      # skip it completely:
      if address_tokens[-1] =~ /n°|km|n\./ui
        address_tokens[-2] = address_tokens[-2] + ','
      elsif (address_tokens[-1] =~ /zona/ui).nil?
        address_tokens[-1] = address_tokens[-1] + ','
      end
      ( address_tokens << skipped_civic_number ) unless (skipped_civic_number =~ /\btel\b/ui)
    end
    # Remove trailing commas, when left over:
    if address_tokens.size > 1
      address_tokens[-1] = address_tokens.last[0..-2] if address_tokens.last.last == ','
    end
    address_tokens
  end
  #-- -------------------------------------------------------------------------
  #++


  # Compares for difference the SwimmingPool instance with the specified values for
  # the corresponding columns. Other, non-listed columns are ignored during the
  # comparison.
  # Currently, the comparison checks only: name, address & nick_name.
  #
  # The specified values are safely checked for presence, thus +nil+ or empty
  # values won't override already set columns.
  #
  # Returns +true+ if any of the columns have different values, +false+ otherwise
  # or in case of errors (or if the pool has been flagged as "do_not_update").
  #
  def self.has_different_values?( swimming_pool, name, address, nick_name )
    return false if !swimming_pool.instance_of?( SwimmingPool ) ||
                    ( swimming_pool.instance_of?( SwimmingPool ) && swimming_pool.do_not_update )
# DEBUG
    puts "\r\nChecking for different values:"
    puts "- Pool name....: '#{ swimming_pool.name }' vs '#{ name }'"
    puts "- DO_NOT_UPDATE: #{ swimming_pool.do_not_update }"
    puts "- address......: '#{ swimming_pool.address }' vs '#{ address }'"
    puts "- nick_name....: '#{ swimming_pool.nick_name }' vs '#{ nick_name }'"
    ( name.present? && address.present? && nick_name.present? ) &&
    (
       ( swimming_pool.name != name ) ||
       ( swimming_pool.address != address ) ||
       ( swimming_pool.nick_name != nick_name )
    )
  end
  #-- -------------------------------------------------------------------------
  #++


  # Finds or creates a SwimmingPool instance using the #source_text_line given in the
  # constructor.
  #
  # If force_geocoding_search is +true+, even if a City/Pool is found it will be compared
  # to (and updated with) the values returned from the internal GeocodingParser instance.
  #
  # === Finder/Builder strategy:
  #
  #   0. Extract name and address from given source text
  #   1. Primary search: seek existing SwimmingPool using extracted token(s)
  #   3. Not found?
  #     3.1 Create a new SwimmingPool using the formatted data from the API and log the action
  #   4. Return the instance (either new or found)
  #
  def find_or_create!( force_geocoding_search = false )
    # Bail out if we have already found a result:
    if @result_swimming_pool.instance_of?( SwimmingPool )
      add_to_log( "\r\nfind_or_create!() re-called. Returning previous pool '#{ @result_swimming_pool.nick_name }'..." )
      return @result_swimming_pool
    end
    add_to_log( "- force_geocoding_search: #{ force_geocoding_search }\r\n" )

    @city_builder.find_or_create!( force_geocoding_search )
    city = @city_builder.result_city
    # Append the logs of the City builder to ours:
    @city_builder.report( @report_log, :<< )
    sql_diff_text_log << @city_builder.sql_diff_text_log
    add_to_log( "\r\n-------------------------------------------\r\n" )

    pool_name_tokens    = FinCalendarSwimmingPoolBuilder.parse_pool_name_tokens( @filtered_pool_text )
    pool_address_tokens = FinCalendarSwimmingPoolBuilder.parse_pool_address_tokens( @filtered_pool_text )
    pool_type_missing   = false
    pool_type           = FinCalendarTextParser.parse_pool_type( @source_program_text )
    # Set a pool_type default and flag reminder in case the pool type wasn't
    # correctly parsed or specified, so that we may later try a different pool
    # type for the search:
    if pool_type.nil?
      pool_type = PoolType.find( PoolType::MT25_ID )  # Get the default pool type
      pool_type_missing = true
    end
    lanes_number = FinCalendarTextParser.parse_pool_lanes_number( @source_program_text )
                                                    # Compose name from extracted tokens:
    name = if pool_name_tokens && pool_name_tokens.respond_to?(:count) && (pool_name_tokens.count > 0)
      pool_name_tokens.join(' ')
    else                                            # Use a default Pool name for all unique town pools:
      "Comunale"
    end
                                                    # Compose address from extracted tokens:
    address = if pool_address_tokens && pool_address_tokens.respond_to?(:count) && (pool_address_tokens.count > 0)
      # Remove from the tokens any duplicated city name:
      # (NOTE: this currently works well only for single-name cities)
      if city.instance_of?( City )
        pool_address_tokens = pool_address_tokens.delete_if{ |token| token =~ /#{ city.name }/ui }
      end
      pool_address_tokens.join(' ')
    else                                            # Use a default empty address:
      ""
    end

    maps_uri = nil
    notes    = nil

    # Set correct value for nick_name, if all the fields are available:
    nick_name = NameNormalizer.get_swimming_pool_nickname( city, pool_name_tokens, pool_type )
    add_to_log( "Setting normalized nick_name as '#{ nick_name }'." ) if nick_name.present?

    # Set/override correct value for various other fields using the GeocodingParser, if enabled:
    if force_geocoding_search
      geocoder = @city_builder.get_geocoder
      if geocoder.instance_of?( GeocodingParser )
        add_to_log( "Geocoder results available." )
        address  = geocoder.formatted_address if geocoder.formatted_address.present?
        maps_uri = "https://www.google.com/maps/place/?q=place_id:#{ geocoder.place_id }" if geocoder.place_id.present?
        notes    = "#{ address }\r\nplace_id:#{ geocoder.place_id }\r\n@#{ geocoder.location_lat },#{ geocoder.location_lng },15z"
      end
    end

    perform_search_strategy( nick_name, pool_name_tokens, pool_type, city )

    # ONLY IF unsuccessful, before choosing to create a new pool, repeat the
    # whole search process switching to a different pool_type, in case the parsing
    # took a default value for granted:
    if @result_swimming_pool.nil? && pool_type_missing
      # Force/switch to a different pool type:
      new_pool_type = PoolType.find( PoolType::MT50_ID )
      # Re-perform the search:
      perform_search_strategy( nick_name, pool_name_tokens, new_pool_type, city )
      # Switch to the new pool_type if it works:
      pool_type = new_pool_type if @result_swimming_pool.instance_of?( SwimmingPool )
    end
                                                    # --- SEARCH #6: (fallback), just city_id & pool_type ---
    if @result_swimming_pool.nil? && city.instance_of?( City )
      add_to_log( "Searching using just city_id: #{ city.id } pool_type #{ pool_type.code } (FALLBACK)..." )
      @result_swimming_pool = SwimmingPool.where(
        ["(pool_type_id = ?) AND (city_id = ?)", pool_type.id, city.id]
      ).first
    end

                                                    # Match found?
    if @result_swimming_pool.instance_of?( SwimmingPool )
      add_to_log( "Pool found! => #{ @result_swimming_pool.inspect }" )
                                                    # --- UPDATE ---
      # Force update of the found instance with the correct values if there are
      # any differences (when @honor_single_update is disabled).
      # Or, in case @honor_single_update is ON, do the update only if the date-time
      # of 30 minutes ago is more recent then the latest update on the row.
      if FinCalendarSwimmingPoolBuilder.has_different_values?( @result_swimming_pool, name, address, nick_name ) &&
        (
          !@honor_single_update ||
          ( @honor_single_update && ( 30.minutes.ago > @result_swimming_pool.updated_at ) )
        )
        update_existing( name, pool_type, lanes_number, city, address, nick_name, maps_uri, notes )
      else
        if @result_swimming_pool.do_not_update
          add_to_log( "Possible difference in values, but do_not_update flag is ON. Skipping update..." )
        elsif ( @honor_single_update && ( 30.minutes.ago > @result_swimming_pool.updated_at ) )
          add_to_log( "Possible difference in values, but @honor_single_update is ON. Skipping update..." )
        end
      end
                                                    # --- CREATION ---
    else
      create_new( name, pool_type, lanes_number, city, address, nick_name, maps_uri, notes )
    end

    @result_swimming_pool
  end
  #-- -------------------------------------------------------------------------
  #++


  private


  # Performs the whole search strategy given the parameters
  #
  def perform_search_strategy( nick_name, pool_name_tokens, pool_type, city )
    # --- SEARCH #1: seek out exact nick_name & pool_type ---
    if nick_name
      add_to_log( "Searching using nick_name '%#{ nick_name }%' and pool_type #{ pool_type.code }..." )
      @result_swimming_pool = SwimmingPool.where(
        ["(nick_name LIKE ?) AND (pool_type_id = ?)", "%#{ nick_name }%", pool_type.id]
      ).first
    end
    # --- SEARCH #2: collect all same-typed pools for the same city and check among them by "simplified" nickname ---
    if @result_swimming_pool.nil? && pool_name_tokens.count > 0 && city.instance_of?( City ) && nick_name
      add_to_log( "Collecting all available pools in #{ city.name } for comparison..." )
      all_city_pools = SwimmingPool.where( ["(pool_type_id = ?) AND (city_id = ?)", pool_type.id, city.id] )
      if all_city_pools.count > 0
        normalized_city_name = NameNormalizer.get_normalized_name( city.name )
        stripped_nickname = nick_name.gsub(/#{ normalized_city_name }|#{ pool_type.code }/ui, '')
        add_to_log( "Found #{ all_city_pools.count } same-typed pools. Comparing nick-names with current..." )
        all_city_pools.each do |possible_pool|
          compared_stripped_nickname = possible_pool.nick_name.gsub(/#{ normalized_city_name }|#{ pool_type.code }/ui, '')
          is_similar = compared_stripped_nickname.include?( stripped_nickname ) ||
                       stripped_nickname.include?( compared_stripped_nickname )
          add_to_log( "#{ compared_stripped_nickname } =~ #{ stripped_nickname } ? #{ is_similar ? 'OK!' : '--' }" )
          if is_similar
            @result_swimming_pool = possible_pool
            break
          end
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  # Creates a new SwimmingPool instance setting its value to @result_swimming_pool
  # while logging the operation.
  #
  def create_new( name, pool_type, lanes_number, city, address, nick_name, maps_uri, notes )
    add_to_log( "Pool NOT found.\r\nCreating a new one as: '#{ name }'/'#{ nick_name }', #{ pool_type ? pool_type.code : '?' } m., #{ lanes_number } lanes, (#{ city.name }, #{ address }) - maps: #{ maps_uri }" )
    @result_swimming_pool = SwimmingPool.new(
      name:         name,
      nick_name:    nick_name,
      pool_type_id: pool_type.id,
      city_id:      city.id,
      address:      address,
      maps_uri:     maps_uri,
      notes:        notes,
      user_id:      @current_user.id
    )

    # Serialize the creation:
    super( @result_swimming_pool, self.class.name )
  end
  #-- -------------------------------------------------------------------------
  #++


  # Updates @result_swimming_pool with new values (assuming it is an instance of SwimmingPool)
  # while logging the operation.
  #
  def update_existing( name, pool_type, lanes_number, city, address, nick_name, maps_uri, notes )
    add_to_log( "Updating existing one with: '#{ name }'/'#{ nick_name }', #{ pool_type.code } m., #{ lanes_number } lanes, (#{ city.name }, #{ address }) - maps: #{ maps_uri }" )
    @result_swimming_pool.name = name
    @result_swimming_pool.nick_name = nick_name
    @result_swimming_pool.address = address
    @result_swimming_pool.city_id = city.id           if city
    @result_swimming_pool.pool_type_id = pool_type.id if pool_type
    @result_swimming_pool.maps_uri  = maps_uri        if maps_uri.present?
    @result_swimming_pool.notes     = notes           if notes.present?
    @result_swimming_pool.user_id   = @current_user.id

    sql_attributes = @result_swimming_pool.attributes.select do |key|
      [
        'name', 'nick_name', 'pool_type_id', 'city_id', 'address', 'maps_uri', 'notes', 'user_id'
      ].include?( key.to_s )
    end
    # Serialize the update:
    super( @result_swimming_pool, sql_attributes, self.class.name )
  end
  #-- -------------------------------------------------------------------------
  #++
end
