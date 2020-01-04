# require 'mw'


#
# == FinCalendarTextParser
#
# Parser strategy to extract meeting session data tokens and values from the pre-filtered
# text stored into the dedicated columns of FinCalendar.
#
# @author   Steve A.
# @version  6.133
#
class FinCalendarTextParser

  attr_reader :source_row, :session_daos

  # Pool selector RegExp
  IS_A_POOL_REGEXP = /(?<=complesso\W)|(?<=piscina\W|piscine\W)/ui unless defined? IS_A_POOL_REGEXP

  # Date selector RegExp
  IS_A_DATE_REGEXP = /(?<date>\d{1,2}.(set|ott|nov|dic|gen|feb|mar|apr|mag|giu|lug|ago))/iu unless defined? IS_A_DATE_REGEXP

  # Time selector RegExp
  IS_A_TIME_REGEXP = /(?<time>ore\s\d{1,2}.\d{1,2})/iu unless defined? IS_A_TIME_REGEXP

  # Style selector RegExp
  IS_A_STYLE_REGEXP = /(?<style>(150|10|20|40|80|5)0\s?(metri|m|m\.|mt|mt.)?\s?(fa|sl|st|do|ra|mi(?!n)|mx|de(?!ll)|dl|df))/iu unless defined? IS_A_STYLE_REGEXP

  # Individual event selector RegExp (to be applied on single tokens, not full lines)
  IS_INDIV_EVENT_REGEXP = /(?<individual>(?<!\d)(?<!.x|x.)(150|10|20|40|80|5)0\s?(metri|m|m\.|mt|mt.)?\s?(fa|sl|st|do|ra|mi(?!n)|mx|de(?!ll)|dl|df))/iu unless defined? IS_INDIV_EVENT_REGEXP

  # Relay selector RegExp (to be applied on single tokens, not full lines)
  IS_RELAY_EVENT_REGEXP = /(?<relay>((Mi)?staff(etta)?.{0,2})?\d\W?x\W?(150|10|20|40|80|5)0\s?(metri|m|m\.|mt|mt.)?\s?(fa|sl|st|do|ra|mi(?!n)|mx|de(?!ll)|dl|df))/iu unless defined? IS_RELAY_EVENT_REGEXP

  # Warm-up selector RegExp
  IS_WARMUP_EVENT_REGEXP = /(?<warmup>riscaldamento)/iu unless defined? IS_WARMUP_EVENT_REGEXP

  # Address *detector* RegExp
  IS_AN_ADDRESS_REGEXP = /
    \bvia\b|\bviale\b|\bv.le\b|\blaterale\b|\bzona\b|
    \bp\.z?za\b|\bpiazza\b|\bvi?c?.l[eo]\b|
    \bvicolo\b|\bvic\.\b|
    \bcorso\b|\bc.so\b|
    \bcontrada\b|\bc.da\b|
    \bpass\w+\b|\blung\w+\b|\blargo\b|\bstretto\b
  /uxi unless defined? IS_AN_ADDRESS_REGEXP

  # Footnote inside program text RegExp
  IS_A_FOOTNOTE_REGEXP = /(?<footnote>^\*{1,4}\s|^\d{1,4}\.\s|^\D{1,4}\.\s|^\(\D{1,4}\)\s|^\(\d{1,4}\)\s)/ui unless defined? IS_A_FOOTNOTE_REGEXP

  # Skippable distraction/noise text (for the parser) RegExp:
  IS_NOISE_REGEXP = /(?<noise>cronometraggio\s)/ui unless defined? IS_NOISE_REGEXP
  #-- -------------------------------------------------------------------------
  #++


  # Creates a new instance, given the current user that has "recorded" this batch
  # of operations.
  #
  def initialize( fin_calendar_row )
    raise ArgumentError.new('fin_calendar_row must be defined!') unless fin_calendar_row.instance_of?( FinCalendar )
    @source_row = fin_calendar_row
    # This will store a list of FinCalendarParseResultDAO instances:
    @session_daos = []
  end
  #-- -------------------------------------------------------------------------
  #++


  # Parses all the text in the FinCalendar row specified in the constructor.
  #
  # The current_user allows the text parser to log the user's action according to its ID.
  #
  # If force_geocoding_search is +true+, even if a City/Pool is found it will be compared
  # to (and updated with) the values returned from the internal GeocodingParser instance.
  #
  def parse!()
    # This will prepare the core list of all the possible (parsed) session DAOs
    # from the program text, creating a new session DAO for each date or timing
    # found at the start of a list of events.
    # The DAOs will store just the text tokens (events, date and times) that will
    # have to be parsed afterwards
    extract_tokens_and_prepare_dao_list( @source_row.program_import_text )

    # Parse all tokens stored into the @session_daos:
    parse_all_daos()

    # Compact session DAOs moving warmup-only session DAOs into the next event
    # session, using as warm-up time the begin time stored into the warm-up session DAO
    # that has to be removed.
    move_warmup_daos_into_event_daos()

    # "Merge" same or split-event session DAOs into a single session by deleting
    # the duplicated event sessions except for the first one.
    # The reason for this is that we do not plan to support events split among
    # different sessions.
    remove_duplicated_event_daos()
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns true if the specified text seems to contain a pool name.
  def self.contains_a_pool?( text )
    !!(text =~ IS_A_POOL_REGEXP)
  end

  # Returns true if the specified text seems to contain a date.
  def self.contains_a_date?( text )
    !!(text =~ IS_A_DATE_REGEXP)
  end

  # Returns true if the specified text seems to contain a time.
  def self.contains_a_time?( text )
    !!(text =~ IS_A_TIME_REGEXP)
  end

  # Returns true if the specified text seems to contain a style definition.
  def self.contains_a_style?( text )
    !!(text =~ IS_A_STYLE_REGEXP) &&
    !!!(text =~ IS_A_POOL_REGEXP)
  end

  # Returns true if the specified text seems to contain an individual event definition.
  def self.contains_individual_event?( text )
    !!(text =~ IS_INDIV_EVENT_REGEXP) &&
    !!!(text =~ IS_A_POOL_REGEXP)
  end

  # Returns true if the specified text seems to contain a warm-up definition.
  def self.contains_a_warmup?( text )
    !!(text =~ IS_WARMUP_EVENT_REGEXP)
  end

  # Returns true if the specified text seems to contain a relay definition.
  def self.contains_a_relay_event?( text )
    !!(text =~ IS_RELAY_EVENT_REGEXP)
  end

  # Returns true if the specified text seems to contain a footnote definition.
  def self.contains_a_footnote?( text )
    !!(text =~ IS_A_FOOTNOTE_REGEXP)
  end

  # Returns true if the specified text seems to contain skippable text.
  def self.contains_skippable_text?( text )
    !!(text =~ IS_NOISE_REGEXP)
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the array of lines extracted from the specified text and containing
  # just the meeting program definition, whenever is found.
  #
  # === Parsing guidelines:
  #
  # The meeting program definition is assumed to be written out sequentially.
  #
  # Thus, any preceeding date will be assumed as the starting of the session,
  # any following hour will be assumed as pertaining any subsequent event definition
  # found.
  #
  def self.get_filtered_program_lines( program_text )
    # 1) Substitute all ord:160 with ord:32 (standard space), otherwise String#strip will fail:
    # 2) Split lines
    # 3) Clear exceeding new lines
    # 4) Delete (resulting) empty lines
    # 5) Select only interesting lines (containing a date, a time, or a style/relay definition)
    program_text.to_s
      .gsub(" ", " ")
      .split("\n")
      .each{ |line| line.gsub!("\r", '') }
      .delete_if{ |line| line.size == 0 }
      .select { |line|
        contains_a_pool?( line )  ||
        contains_a_date?( line )  ||
        contains_a_time?( line )  ||
        ( contains_a_style?(line) && !contains_skippable_text?(line) ) ||
        contains_a_footnote?( line ) ||
        ( contains_a_relay_event?(line) && !contains_skippable_text?(line) )
      }
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the array of tokens found in the specified text_line.
  # Each token containing "interesting data" is used as a separator for the noise.
  # Only some of the most common "noise" formats are filtered: each token returne
  # will need parsing for the actual data to be extracted.
  #
  def self.event_line_token_splitter( text_line )
    # 1) Substitute all ord:160 with ord:32 (standard space), otherwise String#strip will fail:
    # 2) Split into tokens
    # 3) Clear uninteresting stuff
    # 4) Remove any leading and trailing spaces
    text_line.to_s
      .gsub(" ", " ")
      .split(
        /
          #{ IS_A_TIME_REGEXP }|
          #{ IS_INDIV_EVENT_REGEXP }|
          #{ IS_RELAY_EVENT_REGEXP }|
          #{ IS_WARMUP_EVENT_REGEXP }
        /xui
      )
      .reject { |token|
        (token.to_s.size < 1) || (token == " : ") ||  (token =~ / +\Z/) ||
        (token =~ /[\s\t]+\Z/) || (token =~ /(?<separator>\s\W\s)/iu)
      }.map { |token|
        token.strip
      }
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the length in meters from the specified event text token, containing
  # a "style" token (stroke type code). Example: ("4x100 SL", "SL").
  #
  def self.parse_event_length_in_meters( event_token, style_token )
    event_token.to_s.split(/#{ style_token }(?!staff|aff)/ui)
      .first.to_s.split(/\d\D?(x)/ui)
      .last.to_s.strip
      .to_i
  end

  # Returns the number of relay phases found in the event_token. Defaults to 1 if
  # it's not a relay.
  #
  def self.parse_event_relay_phases( event_token, is_a_relay )
    subtoken = event_token.to_s
      .split(/(?<=\d)\D?x/ui).first.to_s
      .split(/staf\D+/uix).last.to_s
      .strip
    is_a_relay ? subtoken.to_i : 1
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the specified pool_text string filtered out of all noise, except
  # all data regarding pool name, city and address (when available).
  #
  # The resulting text string is usually viable for a GeoCoding API string query
  # for seeking the actual place coordinates.
  #
  def self.get_filtered_pool_data_text( pool_text )
    # Filter out the interesting parts regarding the swimming pool:
    data_part = pool_text.to_s
      .split(/gare\ssi\ssvolgeranno\s(presso\s)?(il|la|le|lo|nel(lo|la)?)?/ui).last.to_s
      .split(/\.?\W+Caratteristiche\sde|^vasca\b/uix).first.to_s
    # Leave only the pool name, the address and the city name
    data_part = data_part.split(/#{ IS_A_POOL_REGEXP }/ui)
    if data_part.count > 1
      # Throw away the first token if we have actually more than 1:
      data_part = data_part[1..-1].join
    else
      data_part = data_part.first
    end
    # Subst abbreviations:
    data_part.to_s.strip.gsub(/c\.s\./ui, "Centro Sportivo")
  end


  # Returns the specified prefiltered_text splitted into "complex data tokens"
  # sentences; that is, splitting only at sentence separators (commas, dots, and semicolons),
  # but keeping together and respecting quotes or composed address data
  # (i.e.: "n.27/A", "'Piscina Gigi'", and so on...)
  #
  # Note the, by default, spaces are not considered a "sentence separator".
  # By enabling +split_using_spaces+, the prefiltered_text can be split into
  # a list "atomic tokens" separated by spaces.
  #
  # The result is an array of sub-sentences extracted from the text.
  #
  def self.split_in_sentences( prefiltered_text, split_using_spaces = false )
    # Broke the data part into actual atomic data tokens (name parts, city, address parts, ...):
    # 1. respect quotes: keep quoted names together by splitting them into a single token
    data_part = prefiltered_text.split(/[\"\``\“”](.+)[\"\``\“”]/ui)
    # 1.1 reject the first empty token, in case it has been created (pool names starting with quotes will create an empty token during splitting)
    if (data_part.count > 1) && data_part.first.length == 0
      # Throw away the first token if we have actually more than 1:
      data_part = data_part[1..-1]
    end

    # Collect each token...
    data_part.map do |token|
      # 2.1 ...as is, if it contains quotes
      if token =~ /[\"\``\“”](.+)[\"\``\“”]/ui
        token
      # 2.2.1 ...split it using spaces (but respecting abbreviations w/o spaces and not for quoted text)
      elsif split_using_spaces
        token.scan(/[\wòàèéìùç̉̉\/`\'°\^\(\)\.]+/ui)
      # 2.2.2 ...split it using other separators (but not for quoted text)
      else
        token.split(
          /
            [\-–\–\:\;]|
            [\/\\](?=\W)|
            (?<!\b\w)([\.\,]\s?)(?=\w)
          /uxi
        ).map{ |subtoken| subtoken.to_s.strip }
      end
    end
      .flatten
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the style token from the specified event token text, in a 2-char simplified
  # format (yet to be standardized and converted to an actual stroke_type.code).
  # (i.e. "50 mt. Delfino" => "De")
  #
  def self.extract_style_token( event_token_text )
    # If it contains a relay specification, split it, and use the last part:
    event_token_text = if event_token_text.to_s =~ /(?<=\d)\s?x/ui
      event_token_text.to_s.split(/(?<=\d)\s?x/ui).last.to_s
    else
      event_token_text.to_s
    end
    event_token_text.split(/(fa|sl|st(?!af)|do|ra|mi(?!n|staf)|mx|de(?!ll)|dl|df)/ui)[1].to_s
  end


  # Returns the PoolType row parsing the specified program_text, whenever possible.
  #
  # It will return +nil+ in case of an unsuccessful parsing or when no pool type
  # tokens are found.
  #
  def self.parse_pool_type( program_text )
    # i.e.: "Vasca coperta 50 mt, 8 corsie\r\nCronometraggio manuale\r\nVasca 25 mt sempre disponibile per riscaldamento"
    filtered = program_text.lines.select{ |line| line =~ /\bvasca\b\s(?>\w+\b\s)*(\d\d)\b\sm./ui }
    # We'll consider just the first filtered line:
    pool_type_tokens = filtered.first.to_s.strip.split(/\bvasca\b\s(?>\w+\b\s)*(\d\d)\b\sm./ui)  # i.e.: ["", "50", ", 8 corsie"]
    # We return an actual PoolType only if we really found one (no defaults handling here):
    if pool_type_tokens.count >= 1
      PoolType.find_by_code( pool_type_tokens[1] )
    else
      nil
    end
  end


  # Returns the total pool lanes number parsing the specified program_text, whenever possible.
  # It may return a default of 8 lanes in case of an unsuccessful parsing.
  #
  def self.parse_pool_lanes_number( program_text )
    # i.e.: "Vasca coperta 50 mt, 8 corsie\r\nCronometraggio manuale\r\nVasca 25 mt sempre disponibile per riscaldamento"
    filtered = program_text.lines.select{ |line| line =~ /\b(\d\d?)\scorsie\b/ui }
    # We'll consider just the first filtered line:
    lanes_tot_tokens = filtered.first.to_s.strip.split(/\b(\d\d?)\scorsie\b/ui)                    # i.e.: ["Vasca coperta 50 mt, ", "8"]
    lanes_tot_tokens.count >= 1 ? lanes_tot_tokens.last.to_i : 8 # (default value)
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns an array of data text tokens ragarding the pool; typically: the pool
  # name, its address and its city.
  # It may or it may not be divided in 3 parts, or be just one text or an empty array.
  #
  def self.get_filtered_pool_data_tokens( pool_text )
    # Filter out the interesting parts regarding the swimming pool:
    data_part = FinCalendarTextParser.get_filtered_pool_data_text( pool_text )
# DEBUG
#    puts "\r\n- data_part before splitting: #{ data_part.inspect }"
    FinCalendarTextParser.split_in_sentences( data_part )
  end


  # Returns the left_dest_array minus the first occurences of every
  # element of the right_source_array.
  #
  # For array of string items, the subtraction is applied recursively on each
  # element, for just *one* time, meaning that if some (string) element of the
  # right array has a first-found match inside some element of the left array,
  # the right element is first "subtracted" from the left array element, then
  # it is popped from the right array, making the subtraction occur just once.
  #
  # The original source right array is copied, so no changes occur in it.
  #
  def self.subtract_set_behaviour( left_dest_array, right_source_array )
    # Maximize granularity of the subtraction array:
    right_source_array = right_source_array.join(" ").scan(/[\wòàèéìùç̉̉]+/ui)
# DEBUG
#    puts "\r\nsubtract_set_behaviour:"
#    puts "#{ left_dest_array.inspect } - #{ right_source_array.inspect }"
    while right_source_array.size > 0
      # Pop-out last item from the right array and convert it into a safe Regexp:
      last_item_right  = right_source_array.pop.to_s
      regexp_last_item = /\b#{ last_item_right }\b/ui # FIXME Regexp.new( last_item_right, Regexp::IGNORECASE )
      found_at = left_dest_array.find_index{ |left_item| left_item.to_s.match( regexp_last_item ) }
# DEBUG
#      puts "   item <#{ last_item_right }> found at: #{ found_at } using #{ regexp_last_item }"
      unless found_at.nil?
        if left_dest_array[ found_at ] == last_item_right
# DEBUG
#          puts "   item EQUAL, deleting..."
          left_dest_array.delete_at( found_at )
        else
          # Split the token w/ the right match in 3 parts, and throw away the matched token:
          partition = left_dest_array[ found_at ].to_s.partition( regexp_last_item )
          left_dest_array[ found_at ] = ( partition.first + partition.last ).strip
# DEBUG
#          puts "   item MATCHING, subtracting. Result: <#{ left_dest_array[ found_at ] }> #{ left_dest_array[ found_at ].size == 0 ? ' (EMPTY => deleting)' : '' }"
          left_dest_array.delete_at( found_at ) if left_dest_array[ found_at ].size == 0
        end
      end
    end
# DEBUG
#    puts "=> FINAL Result: #{ left_dest_array.inspect }"
    left_dest_array
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the possible pool definition text or nil if the currently parsed
  # program line is not compliant.
  #
  # === Params:
  #
  # - program_text: full (unfiltered) program text;
  # - current_line: line currently being parsed, extracted from the above text.
  #
  # === Returns:
  #
  # Either a string text containing the possible pool definition, or nil, if the
  # specified current_line doesn't seem to be a pool definition inside the context
  # of the program_text.
  #
  def self.extract_possible_pool_definition( program_text, current_line )
    # Note: the line is not considered to be an actual pool def. text if it ends
    # with a proposition implying a follow-up list of pools. Thus, we check this:
    pool_definition_text = current_line if FinCalendarTextParser.contains_a_pool?( current_line ) &&
                                           !!!(current_line =~ /presso\sle\spiscine\:?\s*\z/ui)
# DEBUG
#    puts "\r\n#pool_definition_text: '#{ pool_definition_text }'" if FinCalendarTextParser.contains_a_pool?( current_line )

    # Pool definition / Exceptional case: additional pool override is present on the same line as the
    # session date (ex: "28 Febbraio / Centro Acquatico Ovest").
    # In this case, we also search for the first line (elsewhere) containing its name
    # and, possibly, its address:
    if pool_definition_text.nil? && FinCalendarTextParser.contains_a_date?( current_line ) &&
       ( !!(current_line =~ /\s+\/\s+/ui) )
      pool_name = current_line.split( /\s+\/\s+/ui ).last
      # Split all the program text into single lines & find the first one referencing
      # the extracted pool name from the current line.
      # Hopefully, the first line found is either another line referencing the pool
      # name, or (best case scenario) it's the actual description of the pool,
      # together with its address.
      possible_address = program_text
          .split(/\r?\n/ui)
          .select{ |row| row =~ /#{ pool_name }/ui }
          .first
      # Check if it's actually a different line, not containing another date + pool def.
      pool_definition_text = if possible_address && (possible_address != current_line) &&
                                !FinCalendarTextParser.contains_a_date?( possible_address )
        possible_address
      else
        pool_name
      end
# DEBUG
#      puts "\r\n- pool_name found..........: '#{ pool_name }'"
#      puts "- possible_address found...: '#{ possible_address }'"
#      puts "- current_line.............: '#{ current_line }'"
#      puts "=> pool_definition_text....: '#{ pool_definition_text }'"
    end

    pool_definition_text
  end
  #-- -------------------------------------------------------------------------
  #++


  private


  # Returns a normalized stroke_type.code given the style token.
  #
  def normalize_to_stroke_type_code( style_token, is_a_relay )
# DEBUG
#    puts "\r\n- normalize_to_stroke_type_code(#{ style_token }, #{ is_a_relay })"
    style_token = "MI" if !is_a_relay && (style_token =~ /mi|mx/ui)
    style_token = "MX" if is_a_relay && (style_token =~ /mi|mx/ui)
    style_token = "FA" if (style_token =~ /de|dl|df/ui)
    style_token = "SL" if (style_token =~ /st/ui)
    style_token.upcase
  end


  # Returns the Organization name and the reference contact person name given the
  # text token.
  #
  def parse_organization_and_reference_person( text_token )
    text_token.to_s.split(/man.+\sorganizzata\sda\:\s|resp.+org.+\:\s|\n|\s{3,}/ui)
      .reject{|token| token.size == 0 }
  end


  # Returns the day_part_type instance given the session start text token
  # (Ex: "ore 08.30", "ore 09.00", ...).
  #
  def parse_begin_time_from_locale_it_text_time( start_time_token )
    # SQL Format sample for UPDATE-compliate time field:
    # ... SET `begin_time` = '00:08:00' WHERE ...;
    hour_24, minutes = start_time_token.to_s.split(/\s/).last
      .to_s.split(/\D/)
      .map{ |time_part| "%02d" % time_part.to_s.to_i }
    hour_24 ? "#{ hour_24 }:#{ minutes }:00" : nil
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the day_part_type instance given the session start time text
  # (Ex: "08:30:00", "09:00:00", ...).
  #
  def parse_day_part_type_id( begin_time_text )
# DEBUG
#    puts "\r\n- parse_day_part_type_id(#{ begin_time_text })"

    hour = begin_time_text.to_s.gsub(/ore\b|h\b/ui, '').to_s.split(/\D/).first
# DEBUG
#    puts "=> hour: #{ hour }"
    # Return the default DayPartType::MORNING_ID in case of empty begin time text:
    return DayPartType::MORNING_ID unless hour.present?

    case hour.to_i
    when 5..11
      DayPartType::MORNING_ID
    when 12..16
      DayPartType::AFTERNOON_ID
    #when 17..19
    when 17..23
      DayPartType::EVENING_ID
    #when 20..23
    when 0..4
      DayPartType::NIGHT_ID
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the stroke_type instance given the parameters.
  #
  def parse_stroke_type( style_token, is_a_relay )
# DEBUG
#    puts "\r\n- parse_stroke_type(#{ style_token }, relay: #{ is_a_relay })"
    stroke_type = StrokeType.find_by_code( normalize_to_stroke_type_code( style_token, is_a_relay ) )
    if stroke_type.nil?
# DEBUG
#      puts "\r\nFOUND unparsed style_token: '#{ style_token }'"
      # FIXME MISSING WARM-UP STROKE TYPE (code='RI'); all the others are usually found
    end
    stroke_type
  end


  # Returns either the existing event_type instance given the parameters or the associated
  # event_type_dao if the event_type is still missing.
  #
  def parse_event_type( event_token, stroke_type, is_a_relay, is_mixed_gender, relay_phases, length_in_meters )
# DEBUG
#    puts "\r\n- parse_event_type(#{ event_token }, #{ stroke_type.inspect }, is_a_relay: #{ is_a_relay }, is_mixed_gender: #{ is_mixed_gender }, relay_phases: #{ relay_phases }, len: #{ length_in_meters })"
    if stroke_type.instance_of?( StrokeType )
      event_type = EventType.where(
        stroke_type_id:         stroke_type.id,
        is_a_relay:             is_a_relay,
        is_mixed_gender:        is_mixed_gender,
        phases:                 relay_phases,
        length_in_meters:       length_in_meters * relay_phases,
        phase_length_in_meters: length_in_meters
      ).first
      if event_type.nil?
        event_type = FinCalendarParseResultDAO::EventTypeDAO.new( stroke_type, is_a_relay, is_mixed_gender, relay_phases, length_in_meters )
# DEBUG
        puts "\r\n\r\nWARNING: event_type not found for token: '#{event_token}' => (stroke_type.id: #{stroke_type.id}, length_in_meters: #{length_in_meters}, is_a_relay: #{is_a_relay}, relay_phases: #{relay_phases}, is_mixed_gender: #{is_mixed_gender})"
        if is_a_relay && relay_phases > 1
          puts "Possible new/MISSING 'event_types' row to be created: [ #{relay_phases}x#{length_in_meters} #{stroke_type.code} ]"
        end
      end
      event_type
    end
  end


  # Returns either the meeting_event instance given the parameter or the associated
  # event_type_dao if the event_type is still missing.
  # (An EventTypeDAO is used to represent any MeetingEvent pointing to yet-to-be-created
  #  EventTypes.)
  #
  def parse_meeting_event( event_type )
# DEBUG
#    puts "\r\n- parse_meeting_event( #{ event_type.inspect } )"
    if event_type.instance_of?( EventType )
      MeetingEvent.new(
        event_type_id: event_type.id,
        heat_type_id:  HeatType::FINALS_ID
      )
    elsif event_type.instance_of?( FinCalendarParseResultDAO::EventTypeDAO )
      # We'll use the same EventTypeDAO to signal that the event is missing its type and must
      # be created from scratch anyway:
      event_type
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Processes the text allegedly containing the whole meeting program, adding
  # to the internal #session_daos member any new session found defined in the text.
  #
  # Each meeting session found will be solely defined by a single FinCalendarParseResultDAO
  # filled with the text token extracted (yet to be actually parsed).
  #
  def extract_tokens_and_prepare_dao_list( program_text )
    filtered_lines = FinCalendarTextParser.get_filtered_program_lines( program_text )
    if filtered_lines.size > 0
      current_session = nil
      pool_definition_text = nil
      current_session_order = 0
      footnotes_reached = false

      filtered_lines.each do |line|
        # Pool definition found? Check it:
        new_possible_pool_definition = FinCalendarTextParser.extract_possible_pool_definition(
          program_text, line
        )

        # Session def. start?
        if FinCalendarTextParser.contains_a_date?( line )
          # Store previous session if existing whenever a new date is found:
          # (meeting sessions are written down sequentially)
          if current_session.instance_of?( FinCalendarParseResultDAO )
            # Set the pool text, if present, just before storing the session in list:
            current_session.pool_override_text = pool_definition_text if pool_definition_text.present?
            @session_daos << current_session
          end

          # --- Start a new session: ---
          date_parts = extract_date(line)
          current_session_order += 1
          current_session = FinCalendarParseResultDAO.new( date_parts.first, date_parts.last, current_session_order, line )
        end

        # "Footnotes" def. start? (Assuming footnotes are left at the end of the
        # program text, we'll start skipping the rest of the style definitions if
        # we find a footnote def.)
        if FinCalendarTextParser.contains_a_footnote?( line )
          footnotes_reached = true
# DEBUG
#          puts "Footnotes found."
        end

        # Program definition?
        # (Skip the rest of the "style def" lines if footnotes are reached)
        if FinCalendarTextParser.contains_a_time?( line ) ||
           ( FinCalendarTextParser.contains_a_style?( line ) && !footnotes_reached )
          FinCalendarTextParser.event_line_token_splitter( line ).each do |token|
            # Since we may have to store the session while parsing the time token,
            # we need to set the pool text if present:
            current_session.pool_override_text = pool_definition_text if current_session && pool_definition_text.present?
            # Time def. start? Possible start of a new session!
            current_session = extract_time( token, current_session, line )
            current_session_order = current_session.session_order
            # Style def. start?
            extract_events( :contains_individual_event?, IS_INDIV_EVENT_REGEXP, token, current_session )
            # Warm-up def. start?
            extract_events( :contains_a_warmup?, IS_WARMUP_EVENT_REGEXP, token, current_session )
            # Relay def. start?
            extract_events( :contains_a_relay_event?, IS_RELAY_EVENT_REGEXP, token, current_session )
          end
        end

        # Set/update the current pool def text only if not yet set or if it's different
        # (i.e.: it has changed from another previous def. found):
        if new_possible_pool_definition && (
             pool_definition_text.nil? || (new_possible_pool_definition != pool_definition_text)
           )
          pool_definition_text = new_possible_pool_definition
        end
      end

      # At the end of the extracting loop, store the last processed session, if defined:
      if current_session.instance_of?( FinCalendarParseResultDAO )
        # Set the pool text, if present, just before storing the session in list:
        current_session.pool_override_text = pool_definition_text if pool_definition_text.present?
        @session_daos << current_session
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the date parts found in text as an array of [dd, mm].
  # The date parts are assumed to be separated by spaces.
  #
  def extract_date( text )
    text.split(/\s/)[0..1]
  end


  # Checks if the specified +text_token+ could be a time and sets the
  # internal member with its value when the check is successful.
  #
  # If the current session is defined and hasn't a time set, it will be re-used.
  # Otherwise, a new session is created.
  #
  # == Params
  # - text_token: the text token that has to be processed, extracted from the source_text_line
  # - the current session DAO; it may be nil
  # - source_text_line: the full source text line
  #
  # == Returns
  # The current session DAO (either updated or created as new)
  #
  def extract_time( text_token, current_session, source_text_line )
    # Session start not yet found? Force a new one using the table row dates extracted from the calendar:
    if current_session.nil?
      # --- Start a new session: ---
# FIXME Log warning somehow instead of using console, or decrease level of verbosity
      puts "\r\n  WARNING: Current session is still nil. Forcing a new one using '#{ @source_row.calendar_date }/#{ @source_row.calendar_month }'."
      # Use the base source row date/month pair for the new session start (from header date):
      current_session = FinCalendarParseResultDAO.new( @source_row.calendar_date, @source_row.calendar_month, 1, source_text_line )
    end
    # [Steve, 20170515] It's possible to encounter new sessions w/o any start time defined.
    # We'll use a default one (8:00? 9:00?) whenever we encounter a nil time token during
    # the serialization phase of the parsing.
    return current_session unless FinCalendarTextParser.contains_a_time?( text_token )

    # START a new session only when a time is found and we still haven't set the time for the current_session.
    if current_session.instance_of?( FinCalendarParseResultDAO ) &&
       !current_session.start_time_token.nil?
      @session_daos << current_session
      # --- Start a new session: ---
      # Use the previously found date/month pair for the new session start:
      current_session = FinCalendarParseResultDAO.new(
        current_session.date_day_token,
        current_session.date_month_token,
        current_session.session_order + 1,
        source_text_line
      )
    end

    # Set the start time token for the current session:
    current_session.start_time_token = text_token
    current_session
  end


  # Tries to split the specified +text_token+ using the +regexp_splitter+ if the
  # +text_token+ seems to contain what is been checked by the +checker_method+.
  # If the +current_session+ is defined, its #event_list will be updated with the
  # sub-token extracted.
  #
  # === Example:
  #
  # "50 SL - 100 DO - 200 RA" => event list: ["50 SL", "100 DO", "200 RA"]
  #
  def extract_events( checker_method, regexp_splitter, text_token, current_session )
    if FinCalendarTextParser.send( checker_method, text_token )
      # Split the text into several sub-tokens and process them individually:
      text_token.split( regexp_splitter ).each_with_index do |subtoken, subtok_idx|
        if FinCalendarTextParser.send( checker_method, subtoken )
          current_session.event_tokens << subtoken
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  # Loops on all session DAOs, parsing the event token previously found.
  #
  # Updates directly the @session_daos member.
  #
  # === Returns:
  #
  # A @session_daos reference.
  #
  def parse_all_daos()
    @session_daos.each do |dao|
      # Parse dates and other fields from the DAO, whem available:
      month = FinCalendarMeetingBuilder.get_month_number( dao.date_month_token )
      day   = dao.date_day_token.to_i
      # If the day is not valid, we rely upon the source row date:
      if day < 1 || day > 31
        month = @source_row.calendar_month
        day   = @source_row.calendar_date
      end
      dao.header_date_iso_format = FinCalendarMeetingBuilder.get_iso_date( @source_row.calendar_year, month, day )

      # Meeting.notes / Meeting.reference_name
      dao.organization_notes, dao.reference_name = parse_organization_and_reference_person( @source_row.organization_import_text )
      # Meeting.notes additional row
      dao.meeting_place = @source_row.calendar_place.to_s

      # Build-up day_part_type for meeting_session (parse current_session time token)
      dao.start_time_iso_format = parse_begin_time_from_locale_it_text_time( dao.start_time_token )
      dao.day_part_type_id = parse_day_part_type_id( dao.start_time_iso_format )

      # Parse and store events into dedicated member list:
      dao.event_tokens.each do |event_token|
        # Some example tokens: "50FA", "100 SL", "4x100 MX", "200 MI", "Mistaff 4x50 Stile", "Staff 4x100 MI"...
        is_a_relay       = !!FinCalendarTextParser.contains_a_relay_event?( event_token )
        is_mixed_gender  = is_a_relay ? !!(event_token.to_s =~ /Mistaff/ui) : false
        style_token      = FinCalendarTextParser.extract_style_token( event_token )
        length_in_meters = FinCalendarTextParser.parse_event_length_in_meters( event_token, style_token )
        relay_phases     = FinCalendarTextParser.parse_event_relay_phases( event_token, is_a_relay )
        # Parse Stroke type: (warm-ups will have a nil stroke_type)
        stroke_type = parse_stroke_type( style_token, is_a_relay )
        # Parse Event type:  (warm-ups will have a nil event_type)
        event_type = parse_event_type( event_token, stroke_type, is_a_relay, is_mixed_gender, relay_phases, length_in_meters )
# DEBUG / VERBOSE:
        # When the stroke type is valid but the EventType isn't found, a DAO will be returned instead.
        # Output the source line for easier inspection/debug:
        if event_type.instance_of?( FinCalendarParseResultDAO::EventTypeDAO )
          puts "Source line for the extracted token:\r\n---8<---\r\n'#{ dao.source_text_line }'\r\n---8<---"
        end
        # Parse Meeting Event:
        meeting_event = parse_meeting_event( event_type )
        # Add meeting_event to the parsed list of dao.meeting_events:
        dao.add_meeting_event( meeting_event ) unless meeting_event.nil?
      end
    end

    @session_daos
  end
  #-- -------------------------------------------------------------------------
  #++


  # "Compacts" the list of session DAOs removing the warm-ups from the list and
  # storing their start-up time as warm-up time for the following event session DAO
  # found.
  #
  # Updates directly the @session_daos member.
  #
  # === Returns:
  #
  # A @session_daos reference.
  #
  def move_warmup_daos_into_event_daos()
    # Scan the DAOs in search of warmup-only pseudo-sessions in order to
    # "compactify" them:
    @session_daos.each_with_index do |dao, index|
      # Current DAO is a warm-up and the next one not?
      # => Assume we can remove it and use its start time as warm-up time:
      if dao.is_a_warmup? && ( index + 1 < @session_daos.size ) && @session_daos.at(index+1)
# DEBUG
#          puts "\r\nMoving warmup session #{ dao } to session #{ index+1 },"
        if dao.warmup_time_iso_format
# DEBUG
#          puts "Setting its warmup time to #{ dao.warmup_time_iso_format } (prev. warmup)"
          @session_daos.at(index+1).warmup_time_token      = dao.warmup_time_token
          @session_daos.at(index+1).warmup_time_iso_format = dao.warmup_time_iso_format
        else
# DEBUG
#          puts "Setting its warmup time to #{ dao.start_time_iso_format } (prev. start)"
          @session_daos.at(index+1).warmup_time_token      = dao.start_time_token
          @session_daos.at(index+1).warmup_time_iso_format = dao.start_time_iso_format
        end
      end
    end
    # Compactify the sessions DAOs, keeping only the actual events:
    @session_daos.delete_if{ |dao| dao.is_a_warmup? }

    @session_daos
  end
  #-- -------------------------------------------------------------------------
  #++


  # Deletes any "duplicated" event rows among the session DAOS list and erases
  # any possible resulting empty session.
  #
  # Events are considered "duplicates" if they have the same event type of an
  # already encoutered event. Only the first event is kept in its original form
  # and session.
  #
  # The motivation behind this is that we do not support (or plan to support in
  # the future) events split among different meeting sessions.
  #
  # This updates directly the @session_daos member.
  #
  # === Returns:
  #
  # A @session_daos reference.
  #
  def remove_duplicated_event_daos
    # Scan the DAOs and their event list and build a map of all the unique events.
    #
    # While bulding the map, if an event is already mapped, it is removed from its
    # session DAO event list.
    #
    # If, at the end of the DAO event list scanning, the session is empty, the
    # session DAO itself is removed from the @session_daos list.
    unique_event_types = []

    @session_daos.each do |dao|
      dao.meeting_events.delete_if do |meeting_event|
        # Since the list may contain existing MeetingEvents as well as not-yet
        # created event type DAOs, we need to check this and compare the codes:
        event_type_code = if meeting_event.instance_of?( FinCalendarParseResultDAO::EventTypeDAO )
          meeting_event.get_suggested_instance.code
        else
          meeting_event.event_type.code
        end
        # Now we can return true to delete an item or false if we want to keep it:
        if unique_event_types.include?( event_type_code )
          # The event has already been encountered, so we can safely delete it:
          true
        else
          # The event code is new, so we add it to the list:
          unique_event_types << event_type_code
          false
        end
      end
    end

    # Remove any possible resulting "empty" session DAOs from the session list:
    @session_daos.delete_if do |dao|
      dao.meeting_events.count < 1
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
