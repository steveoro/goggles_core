# encoding: utf-8
require 'framework/console_logger'


=begin

= ReservationsCsi2Csv

  - Goggles framework vers.:  6.157
  - author: Steve A.
  - revised by Leega with new Negrini's requests
  
 The file will contains:
 Atleta  -> swimmer complete_name
 Anno    -> swimmer year_of_birth
 Squadra -> team_affiliation name
 Tempo   -> reservation time
 Codice  -> 5 caratters code created with gender, category and event
 Tessera -> Optional badge number  

 Strategy class used to output a specific CSV text format for the C.S.I. Regional
 Championship (used to exchange reservation data in between organizations).

 Given a valid Meeting.id (of a Meeting belonging to the CSI Championship),
 the source data set is obtained from a selected bunch of rows from MeetingReservations,
 MeetingEventReservation and MeetingRelayReservation.

 The stategy allows to extract all team and swimmer reservations found and to export
 the data in the custom format.

 The extracted data can be serialized on file at will with a dedicated method.

=end
class ReservationsCsi2Csv

  DEFAULT_OUTPUT_DIR = File.join( Rails.root, 'public', 'output' ) unless defined? DEFAULT_OUTPUT_DIR

  attr_reader :csi_data_rows, :created_file_full_pathname
  #-- -------------------------------------------------------------------------
  #++


  # Creates a new instance by specifying a valid Meeting instance.
  # The Meeting must belong to a Season of the CSI federation.
  #
  # If no filtering_team is specified, all the reservations for the meeting will
  # be collected.
  #
  def initialize( meeting, filtering_team = nil, logger = ConsoleLogger.new )
    unless ReservationsCsi2Csv.is_a_csi_meeting( meeting )
      raise ArgumentError.new("The specified Meeting must be a valid instance of Meeting, belonging to the '#{ SeasonType::CODE_MAS_CSI }' SeasonType.")
    end
    @meeting = meeting
    @filtering_team = filtering_team
    @logger  = logger
    @csi_data_rows = []                             # Actual data rows to be exported
    @swimmers_reservations = 0                      # Simply counts the reservation found
    # This will be used to extract a valid team/affiliation reference from the swimmer badge:
    @first_swimmer_reservation = nil
    @created_file_full_pathname = nil
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns true if the specified Meeting instance can be processed by this strategy
  # (regardless the fact that the Meeting has or hasn't any associated reservations).
  # Always false otherwise.
  #
  def self.is_a_csi_meeting( meeting )
    return false if meeting.nil?
    ( meeting && meeting.instance_of?( Meeting ) && meeting.season_type.code == SeasonType::CODE_MAS_CSI )
  end
  #-- -------------------------------------------------------------------------
  #++


  # Collects the data.
  #
  def collect()
    @logger.info( "Extracting reservation data for CSI2CSV data export..." )
    reservations = if @filtering_team.instance_of?( Team )
      @logger.info( "(Filtering for #{ @filtering_team.get_full_name } swimmers)" )
      MeetingReservation.where( meeting_id: @meeting.id, team_id: @filtering_team.id ).is_coming
    else
      MeetingReservation.where( meeting_id: @meeting.id ).is_coming
    end

    # Scan involved swimmers
    reservations.each do |meeting_reservation|
      swimmer = meeting_reservation.swimmer
      if @meeting.meeting_event_reservations.where( ['swimmer_id = ?', swimmer.id] ).is_reserved.exists?
        badge = meeting_reservation.badge
        gender_type = swimmer.gender_type
        category_type = badge.category_type

        @logger.info( "Swimmer #{swimmer.get_full_name} (#{badge.category_type.code})" )
        @swimmers_reservations = @swimmers_reservations + 1
        
        # Store the first reservation in order to extract useful team data for the headers later on:
        @first_swimmer_reservation = meeting_reservation if @swimmers_reservations == 1

        # Scan reserved events
        @meeting.meeting_event_reservations.where( ['swimmer_id = ?', swimmer.id] ).is_reserved.each do |meeting_event_reservation|
          swimmer_row = ""
          swimmer_row << "#{ swimmer.complete_name };"
          swimmer_row << "#{ swimmer.year_of_birth };"
          swimmer_row << "#{ badge.team_affiliation.name };"  
          
          # Check for no time to set correct notation        
          if meeting_event_reservation.is_no_time
            swimmer_row << "999998;"
          else
            swimmer_row << "#{ meeting_event_reservation.get_timing_flattened };"
          end
          
          # Badge number if present or single space if not
          swimmer_row << "#{ badge.number != '?' ? badge.number : ' ' };"

          # Find out csi gender-category-event code
          swimmer_row << "#{ get_csi_reservation_code( gender_type, category_type, meeting_event_reservation.event_type ) };"

          # Enod of line character sequence ";"
          swimmer_row << '";"'
          @csi_data_rows << swimmer_row
        end
      end
    end
    # After we have collected the reservations, we can prepare the headers and footer if needed:
    #prepare_header_titles()
    prepare_footer_filler()
  end


  # Composes the resulting text CSV output.
  # Returns nil if no data rows were collected.
  #
  def output_text
    if @csi_data_rows.size > 0
      while @csi_data_rows.size < 400 do
        @csi_data_rows << @footer_filler.join(';')
      end
      #( [ @header_titles.join(';') ] + @csi_data_rows ).join("\r\n")
      ( @csi_data_rows ).join("\r\n")
    else
      nil
    end
  end


  # Exports the collected data to a custom CSV file format.
  # It returns the created file full pathname, or nil if case there wasn't any
  # data to be exported.
  #
  def save_to_file( output_dir = DEFAULT_OUTPUT_DIR )
    if @swimmers_reservations > 0
      @logger.info( "\r\nExtracted data for #{ @swimmers_reservations } swimmers reservations." )
      extension = if @filtering_team.instance_of?( Team )
        @logger.info( "(While filtering for #{ @filtering_team.get_full_name } swimmers, team ID: #{ @filtering_team.id })" )
        "#{ @filtering_team.id }.csv"
      elsif @first_swimmer_reservation.instance_of?( MeetingReservation )
        affiliation = @first_swimmer_reservation.badge.team_affiliation
        @logger.info( "(While filtering for #{ affiliation.get_full_name } swimmers, team ID: #{ affiliation.team_id })" )
        "#{ affiliation.team_id }.csv"
      else
        "csv"
      end

      # (Re-)Create the csv file:
      file_name = @meeting.get_data_import_file_name( "isc", extension )
      @created_file_full_pathname = File.join(output_dir, file_name)
      File.open( @created_file_full_pathname, 'w' ) { |f| f.puts output_text }
      @logger.info( "\r\nEntry file " + file_name + " created\r\n" )
    else
      @logger.info( "\r\nNo reservations found. File creation skipped.\r\n" )
    end
    @created_file_full_pathname
  end
  #-- -------------------------------------------------------------------------
  #++


  # Find out the CSI reservation (and result) code for gender, category and event
  # The CSI code is a 5 digit numerical value with positional significant
  # <gender><category_2_digits><stroke_type><distance>
  def get_csi_reservation_code( gender_type, category_type, event_type )
    gender_code   = gender_type.get_csi_code.to_i * 10000
    category_code = category_type.get_csi_code.to_i * 100  # 2 digits
    stroke_code   = event_type.stroke_type.get_csi_code.to_i * 10
    distance_code = event_type.get_csi_distance_code.to_i
    (gender_code + category_code + stroke_code + distance_code).to_s 
  end
  

  private

  # Prepares the header
  #
  def prepare_header_titles()
    @header_titles = [
      "Atleta", "Anno", "Squadra", "Tempo", "Tessera", "Codice", "EOL"
    ]
    @header_titles
  end
  #-- -------------------------------------------------------------------------
  #++

  # Prepares filler footer
  #
  def prepare_footer_filler()
    @footer_filler = [
      "GOGGLES", "2018", "PLUTO", "999998", " ", "12142", '";"'
    ]
    @footer_filler
  end
  #-- -------------------------------------------------------------------------
  #++
end
