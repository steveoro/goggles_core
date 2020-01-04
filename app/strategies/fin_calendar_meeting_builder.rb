# encoding: utf-8
require 'common/format'

=begin

= FinCalendarMeetingBuilder

  - Goggles framework vers.:  6.200
  - author: Steve A.

 Finds or creates a Meeting instance given the parameters.

 If no existing Meeting is found from the parsed source fin_calendar row and the
 given meeting_place, a new Meeting row will be created.

 Whenever a FinCalendar row has already the link set to its corresponding Meeting,
 this will be considered as "unchangeable" and the linked Meeting will receive any
 updated values from the calendar.


 === Finder/Builder strategy:

 1. Extract meeting.code and header date from constructor parameters

 2. *1st* search (==): seek existing Meeting: season_id & code
 3. *2nd* search => Search a Meeting having same season and code
 3. *3nd* search => Search a Meeting having same season, date and code token (from city)
 4. *4nd* search => Search a Meeting having same season, date and code token (from title)
 5. *5nd* search (skipped for Regional Meetings, which have too similar descriptions)
                 => Search a Meeting having same season, date and (last) description token

 6. Found? => Check for missing data and update the existing row
 7. (Not found?) Create a new Meeting using the provided data
 8. Return the instance (either new or found/updated)


=end
class FinCalendarMeetingBuilder < FinCalendarBaseBuilder

  attr_reader :result_meeting

  # Creates a new instance, given the current user that has "recorded" this batch
  # of operations.
  #
  def initialize( current_user, fin_calendar_row )
    super( current_user )
    raise ArgumentError.new('fin_calendar_row must be defined!') unless fin_calendar_row.instance_of?( FinCalendar )
    @source_row = fin_calendar_row
    @result_meeting = nil
    create_sql_diff_header( "FinCalendarMeetingBuilder recorded from actions by #{ current_user }" )
    add_to_log( "\r\n\t**************************************\r\n\t***    FinCalendarMeetingBuilder   ***\r\n\t**************************************" )
    add_to_log( "- goggles_meeting_code: '#{ fin_calendar_row.goggles_meeting_code }'\r\n" )
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the Fixnum for the specified +month_name+.
  #
  def self.get_month_number( month_name )
    case month_name.to_s
    when /gen|\b1\b/i
      1
    when /feb|\b2\b/i
      2
    when /mar|\b3\b/i
      3
    when /apr|\b4\b/i
      4
    when /mag|\b5\b/i
      5
    when /giu|\b6\b/i
      6
    when /lug|\b7\b/i
      7
    when /ago|\b8\b/i
      8
    when /set|\b9\b/i
      9
    when /ott|\b10\b/i
      10
    when /nov|\b11\b/i
      11
    when /dic|\b12\b/i
      12
    else
      0
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the ISO-formatted string date from each single field
  # representing the meeting dates.
  #
  # Returns nil only if the +meeting_days+ filed seems to be invalid or undefined.
  #
  # @param year, the year of the Meeting
  # @param month_name, the month name of the Meeting
  # @param meeting_days, 1 or 2 days for the meeting date, separated either by ',' or '-'
  # @param which_day, which day in meeting_days must be considered (either :first or :last; default: :first)
  # @param output_format, the output format for the string date (default: "%04d-%02d-%02d")
  #
  def self.get_iso_date( year, month_name, meeting_days, which_day = :first,
                         output_format = "%04d-%02d-%02d" )
    day = meeting_days.to_s.split(/[\-\,\/\s]/).send( which_day )
    return nil if day.nil?
    month = self.get_month_number( month_name )
    output_format % [ year.to_i, month, day.to_i ]
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the meeting description stripped of its edition number, the
  # edition numeral itself converted into Fixnum and the edition_type_id
  # all parsed from the provided calendar meeting name.
  #
  # == Returns:
  #
  # A list containing: [ description, edition, edition_type_id ].
  #
  def self.parse_edition_and_type( calendar_name )
    # Edition and description parsing:
    name_tokens = calendar_name.to_s.split(/(^[IXVLMCD]+)\s|(^\d+[°^oa]?)\s/u)
    description = name_tokens.last
    edition     = name_tokens[1] if name_tokens.count > 1

    # Ex: "CAMPIONATO REGIONALE ...", "DISTANZE SPECIALI ..."
    edition_type_id = if description =~ /distanze\sspec|regionali|finale|italiani|mondiali|europei/ui
      EditionType::YEAR_ID

    # Ex: "2A PROVA REGIONALE ..."
    elsif edition =~ /[oa]/u && description =~ /prova\sregionale|meeting\sregionale/ui
      EditionType::SEASON_ID

    # Ex: "16° Trofeo ...", "XXIV Meeting Internazionale ..."
    elsif edition =~ /^\d+|^[IXVLMCD]+/u
      EditionType::ROMAN_ID

    else
      EditionType::NONE_ID
    end

    # Parse the edition number:
    if edition =~ /\d+/
      edition = edition.to_i
    elsif edition =~ /[IXVLMCD]+/ui
      edition = Fixnum.from_roman( edition )
    end
    # [Steve, 20170705] "Ordinal" has never been actually used and is DEPRECATED:
    # elsif edition =~ /\d+/u
    #   edition_type_id = EditionType::ORDINAL_ID

    [ description, edition, edition_type_id ]
  end
  #-- -------------------------------------------------------------------------
  #++


  # Compares for difference the meeting instance with the specified values for
  # the corresponding columns. Other, non-listed columns are ignored during the
  # comparison.
  # Currently, the comparison checks only the meeting fields listed as parameters
  # below.
  #
  # The specified values are safely checked for presence, thus +nil+ or empty
  # values won't override already set columns.
  #
  # Returns +true+ if any of the columns have different values, +false+ otherwise
  # or in case of errors (or if the pool has been flagged as "do_not_update").
  #
  def self.has_different_values?( meeting, code, header_date, header_year, description,
                                  edition, edition_type_id, timing_type_id, is_confirmed,
                                  entry_deadline_text, manifest_link )
    return false if !meeting.instance_of?( Meeting ) ||
                    ( meeting.instance_of?( Meeting ) && meeting.do_not_update )
# DEBUG
#    puts "\r\n- Meeting code:.......... '#{ meeting.code }' vs '#{ code }'"
#    puts "- header_date:........... '#{ Format.a_date( meeting.header_date ) }' vs '#{Format.a_date( header_date ) }'"
#    puts "- header_year:........... '#{ meeting.header_year }' vs '#{ header_year }'"
#    puts "- description:........... '#{ meeting.description }' vs '#{ description }'"
#    puts "- edition:............... '#{ meeting.edition }' vs '#{ edition }'"
#    puts "- edition_type_id:....... '#{ meeting.edition_type_id }' vs '#{ edition_type_id }'"
#    puts "- timing_type_id:........ '#{ meeting.timing_type_id }' vs '#{ timing_type_id }'"
#    puts "- is_confirmed:.......... '#{ meeting.is_confirmed }' vs '#{ is_confirmed }'"
#    puts "- entry_deadline_text:... #{ meeting.entry_deadline.present? } vs #{ entry_deadline_text.present? }"
#    puts "- manifest_link:......... #{ meeting.invitation.present? } vs #{ manifest_link.present? }"
    ( code.present? && (meeting.code != code) ) ||
    ( header_date.present? && (Format.a_date( meeting.header_date ) != Format.a_date( header_date )) ) ||
    ( header_year.present? && (meeting.header_year != header_year) ) ||
    ( description.present? && (meeting.description != description) ) ||
    ( meeting.is_confirmed? != !!is_confirmed ) ||
    ( (edition.to_i > 0) && (meeting.edition.to_i != edition.to_i )) ||
    ( (edition_type_id.to_i > 0) && (edition_type_id.to_i != EditionType::NONE_ID) && (meeting.edition_type_id.to_i != edition_type_id.to_i) ) ||
    ( (timing_type_id.to_i > 0) && (meeting.timing_type_id.to_i != timing_type_id.to_i) ) ||
    ( (!meeting.entry_deadline.present?) && entry_deadline_text.present? ) ||
    ( (!meeting.invitation.present?) && manifest_link.present? )
  end
  #-- -------------------------------------------------------------------------
  #++


  # Finds or creates a Meeting instance using the #fin_calendar_row given in the
  # constructor.
  #
  # It always returns a Meeting instance, either pre-existing or newly created,
  # _unless_ the current source row does NOT have a valid goggles meeting code
  # and either has a missing +meeting_place+ or a missing +meeting_name+ (which
  # both can be used to identify the meeting itself).
  #
  def find_or_create!()
    # Bail out if we have already found a result:
    if @result_meeting.instance_of?( Meeting )
      add_to_log( "\r\nfind_or_create!() re-called. Returning previous meeting '#{ @result_meeting.code }'..." )
      return @result_meeting
    end
                                                    # Check source row integrity:
    valid_meeting_code = (
        @source_row.goggles_meeting_code.present? &&
        ( @source_row.goggles_meeting_code.to_s =~ /risultati|start/ui ).nil?
    )
    # Calendar place could be invalid for meetings like "regpuglia", season 162,
    # which occur in several different places. So, the following option is an "OR":
    valid_calendar_place = ( @source_row.calendar_place.present? && @source_row.calendar_place.length > 3 )

    unless valid_meeting_code ||
           ( @source_row.calendar_name.present? && valid_calendar_place )
      add_to_log( "\r\nSkipping processing for incomplete calendar row '#{ @source_row.get_verbose_name }'." )
      return @result_meeting
    end
                                                    # Prepare Meeting requires:
    code        = @source_row.goggles_meeting_code
    season_id   = @source_row.season_id
    user_id     = @current_user.id
    header_year = @source_row.season.header_year
    header_date = FinCalendarMeetingBuilder.get_iso_date(
      @source_row.calendar_year,
      @source_row.calendar_month,
      @source_row.calendar_date
    )
                                                    # Edition and description parsing:
    # [Steve, 20170803] Just as a remark, we'll get the "stripped" description from
    # the actual meeting name on the FIN calendar as a tool for seeking any existing
    # meeting with a similar name.
    # The actual creation or update process uses the full calendar name itself
    # for the meeting description.
    description, edition, edition_type_id = FinCalendarMeetingBuilder.parse_edition_and_type(
      @source_row.calendar_name
    )
                                                    # Make an educated guess for timing_type_id:
    timing_type_id = if @source_row.season.season_type.code == "MASFIN"
      TimingType::AUTOMATIC_ID
    else
      TimingType::SEMIAUTO_ID
    end
    # [Steve, 20170705] "Manual" has never been actually used and is DEPRECATED:
    # TimingType::MANUAL_ID
                                                    # --- Pre-check for already set links between calendar & meeting ---
    if @source_row.meeting
      add_to_log( "\r\nMeeting already set on FIN Calendar row. Using it..." )
      @result_meeting = @source_row.meeting
    end
                                                    # --- SEARCH #1: SAME season, date and code ---
    unless @result_meeting.instance_of?( Meeting )
      add_to_log( "\r\nSearching meeting within season #{ season_id }, header_date #{ header_date } & code '#{ code }'..." )
      @result_meeting = Meeting.where(
        [
          "(season_id = ?) AND (header_date = ?) AND (code = ?)",
          season_id, header_date, code
        ]
      ).first
    end
                                                    # --- SEARCH #2: SAME season and code (meeting possibly "moved") ---
    unless @result_meeting.instance_of?( Meeting )
      add_to_log( "\r\nSearching meeting within season #{ season_id } & code '#{ code }'..." )
      @result_meeting = Meeting.where(
        [ "(season_id = ?) AND (code = ?)", season_id, code ]
      ).first
    end
                                                    # --- SEARCH #3: season, date and similar code token (from city) ---
    if @result_meeting.nil? && @source_row.calendar_place.present? &&
       @source_row.calendar_place.length > 3
      norm_city_token = '%' + NameNormalizer.get_normalized_name( @source_row.calendar_place ) + '%'
      add_to_log( "Searching meeting within season #{ season_id }, header_date #{ header_date } & code token '#{ norm_city_token }' (from city)..." )
      @result_meeting = Meeting.where(
        [
          "(season_id = ?) AND (header_date = ?) AND (code LIKE ?)",
          season_id, header_date, norm_city_token
        ]
      ).first
    end
                                                    # --- SEARCH #4: season, date and similar code token (from title) ---
    if @result_meeting.nil? && @source_row.calendar_place.present? &&
       @source_row.calendar_place.length > 3
      norm_title = '%' + NameNormalizer.get_normalized_name( @source_row.calendar_name ) + '%'
      add_to_log( "Searching meeting within season #{ season_id }, header_date #{ header_date } & code token '#{ norm_title }' (from title)..." )
      @result_meeting = Meeting.where(
        [
          "(season_id = ?) AND (header_date = ?) AND (code LIKE ?)",
          season_id, header_date, norm_title
        ]
      ).first
    end
                                                    # --- SEARCH #5: season, date and similar description token ---
    # [Steve, 20180106] Skip search #5 for Regional Meetings, that usually have too similar descriptions
    if @result_meeting.nil? && description.present? && ( description =~ /regional/ui ).nil?
      # Extract a searchable (normalized) token from the description of the Meeting:
      # (token must be a word and not too short and not a too-common word)
      description_token = NameNormalizer.get_normalized_string( description )
          .split(/\s/).reject{ |token|
              !!(token =~ /\d+|campionato|distanze|special|region|finali|master|nuoto/ui) || (token.length < 4)
          }.first.to_s
      if description_token.present?
        description_token = "%#{ description_token }%"
        add_to_log( "Searching meeting within season #{ season_id }, header_date #{ header_date } & description token '#{ description_token }'..." )
        @result_meeting = Meeting.where(
          [
            "(season_id = ?) AND (header_date = ?) AND (description LIKE ?)",
            season_id, header_date, description_token
          ]
        ).first
      else
        add_to_log( "Unable to extract a suitable description token within the current rule set." )
      end
    end
                                                    # Match found?
    if @result_meeting.instance_of?( Meeting )
      add_to_log( "Meeting found! => #{ @result_meeting.inspect }" )
                                                    # --- UPDATE ---
      # Force update of the found instance with the correct values if there are
      # any differences (except user_id):
      if FinCalendarMeetingBuilder.has_different_values?( @result_meeting,
          code, header_date, header_year, @source_row.calendar_name,
          edition, edition_type_id, timing_type_id,
          ( @source_row.manifest_link.present? || @source_row.startlist_link.present? || @source_row.results_link.present? ),
          @source_row.name_import_text,
          @source_row.manifest_link
      )
        update_existing( code, header_date, header_year, season_id, edition, edition_type_id, timing_type_id )
      else
        if @result_meeting.do_not_update
          add_to_log( "Possible difference in values, but do_not_update flag is ON. Skipping update..." )
        end
      end
                                                    # --- CREATION ---
    else
      create_new( code, header_date, header_year, season_id, edition, edition_type_id, timing_type_id )
    end

    @result_meeting
  end
  #-- -------------------------------------------------------------------------
  #++


  private


  # Creates a new Meeting instance setting its value to @result_meeting
  # while logging the operation.
  #
  def create_new( code, header_date, header_year, season_id, edition, edition_type_id, timing_type_id )
    # Bail out if we can't save the meeting:
    season = Season.find_by_id( season_id )
    unless code.present? && header_date.present? && header_year.present? && season.instance_of?(Season)
      add_to_log( "WARNING: unable to create a Meeting due to lack of parsed values. Returning a nil meeting..." )
      return
    end
    free_id = MeetingIDGenerator.get_free_id( season )
    add_to_log( "Meeting NOT found.\r\nCreating a new one as: ID #{ free_id }, '#{ code }'/'#{ header_date }', '#{ @source_row.calendar_name }', season #{ season_id }, edition: #{ edition }, edition_type_id: #{ edition_type_id }, timing_type_id: #{ timing_type_id }" )
    add_to_log( "WARNING: UNABLE TO FIND THE REQUIRED FREE ID. Using the database-generated one..." ) if free_id.nil?
    @result_meeting = Meeting.new(
      id:               free_id,
      code:             code,
      header_date:      header_date,
      header_year:      header_year,
      description:      @source_row.calendar_name,
      is_confirmed:     @source_row.manifest_link.present? || @source_row.startlist_link.present? || @source_row.results_link.present?,
      season_id:        season_id,
      edition:          ( edition.to_i > 0 ? edition.to_i : 1 ),
      edition_type_id:  edition_type_id,
      timing_type_id:   timing_type_id,
      is_autofilled:    true,
      entry_deadline:   ( @source_row.name_import_text.present? ? parse_entry_deadline_from_locale_it_text_date : nil ),
      invitation:       ( @source_row.manifest_link.present?    ? "https://www.federnuoto.it#{ @source_row.manifest_link }" : nil ),
      user_id:          @current_user.id
    )
    # Serialize the creation:
    super( @result_meeting, self.class.name )
  end
  #-- -------------------------------------------------------------------------
  #++


  # Updates @result_meeting with new values (assuming it is an instance of Meeting)
  # while logging the operation.
  #
  def update_existing( code, header_date, header_year, season_id, edition, edition_type_id, timing_type_id )
    add_to_log( "\r\nUpdating existing Meeting with valid values chosen among these: '#{ code }'/'#{ header_date }', '#{ @source_row.calendar_name }', season #{ season_id }, edition: #{ edition }, edition_type_id: #{ edition_type_id }, timing_type_id: #{ timing_type_id }" )
    @result_meeting.code = code
    @result_meeting.header_date = header_date
    @result_meeting.header_year = header_year
    @result_meeting.description = @source_row.calendar_name
    # Having the results link set on the fin calendar row allows us to be sure about
    # a Meeting confirmation (since it has indeed either happened or being cancelled,
    # in the case the results link points to an empty results file - for cancelled
    # meetings)
    @result_meeting.is_confirmed = @source_row.manifest_link.present? || @source_row.startlist_link.present? || @source_row.results_link.present?
    @result_meeting.season_id = season_id
    # Change the edition only if it has a value:
    @result_meeting.edition   = edition if edition.present?
    # Update the edition type only if set to a non-default (parsed) value and differs from the existing:
    if (edition_type_id.to_i > 0) && (edition_type_id.to_i != EditionType::NONE_ID) &&
       (@result_meeting.edition_type_id.to_i != edition_type_id.to_i)
      @result_meeting.edition_type_id = edition_type_id
    end
    @result_meeting.timing_type_id  = timing_type_id
    @result_meeting.user_id  = @current_user.id
    # Alternative Manifest direct link support:
    if @source_row.manifest_link.present? && ( !@result_meeting.has_invitation? ) && ( !@result_meeting.invitation.present? )
      @result_meeting.invitation = "https://www.federnuoto.it#{ @source_row.manifest_link }"
    end
    # Set entry_deadline from the parsed result of @source_row.name_import_text:
    # Note: currently, #name_import_text stores just Meeting.entry_deadline (as a Locale-IT date).
    if @source_row.name_import_text.present?
      @result_meeting.entry_deadline = parse_entry_deadline_from_locale_it_text_date()
    end

    sql_attributes = @result_meeting.attributes.select do |key|
      [
        'code', 'header_date', 'header_year', 'description', 'is_confirmed', 'season_id',
        'edition', 'edition_type_id', 'timing_type_id', 'invitation',
        'entry_deadline', 'user_id'
      ].include?( key.to_s )
    end
    # Serialize the update:
    super( @result_meeting, sql_attributes, self.class.name )
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the ISO-compliant text date from the locale-IT text date found inside
  # @source_row.name_import_text.
  #
  def parse_entry_deadline_from_locale_it_text_date()
    deadline_day, deadline_month, deadline_year = @source_row.name_import_text.to_s
      .split(/\:\s/ui).last
      .to_s.split("/")
    "#{ deadline_year }-#{ deadline_month }-#{ deadline_day }"
  end
  #-- -------------------------------------------------------------------------
  #++
end
