# encoding: utf-8
require 'framework/console_logger'


=begin

= ReservationsCsi2Csv

  - Goggles framework vers.:  6.084
  - author: Steve A.

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
  def initialize( meeting, logger = ConsoleLogger.new )
    unless ReservationsCsi2Csv.is_a_csi_meeting( meeting )
      raise ArgumentError.new("The specified Meeting must be a valid instance of Meeting, belonging to the '#{ SeasonType::CODE_MAS_CSI }' SeasonType.")
    end
    @meeting = meeting
    @logger  = logger
    prepare_header_titles()
    @csi_data_rows = []
    @swimmers_reservations = 0
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

    # Scan involved swimmers
    @meeting.meeting_reservations.is_coming.each do |meeting_reservation|
      swimmer = meeting_reservation.swimmer
      if @meeting.meeting_event_reservations.where( ['swimmer_id = ?', swimmer.id] ).is_reserved.count > 0
        badge = meeting_reservation.badge

        @logger.info( "Swimmer #{swimmer.get_full_name} (#{badge.category_type.code})" )
        @swimmers_reservations = @swimmers_reservations + 1

        swimmer_row = ""
        swimmer_row << "#{ badge.category_type.code };"
        swimmer_row << "#{ swimmer.last_name };"
        swimmer_row << "#{ swimmer.first_name };"
        swimmer_row << "#{ badge.number != '?' ? badge.number : '' };"
        swimmer_row << "#{ swimmer.gender_type.code };"
        swimmer_row << "#{ swimmer.year_of_birth };"

        # Scan events
        @meeting.meeting_event_reservations.where( ['swimmer_id = ?', swimmer.id] ).is_reserved.each do |meeting_event_reservation|
          swimmer_row << "#{ meeting_event_reservation.get_event_type_for_csi_entry };"
          swimmer_row << "#{ meeting_event_reservation.get_timing_flattened };"
        end
        swimmer_row << "#{ @meeting.header_date.year - swimmer.year_of_birth };"
        @csi_data_rows << swimmer_row
      end
    end
  end


  # Composes the resulting text CSV output.
  # Returns nil if no data rows were collected.
  #
  def output_text
    if @csi_data_rows.size > 0
      ( [ @header_titles.join(';') ] + @csi_data_rows ).join("\r\n")
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

      # (Re-)Create the csv file:
      file_name = @meeting.get_data_import_file_name( 'isc', 'csv' )
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


  private


  # Prepares the header
  #
  def prepare_header_titles()
    @header_titles = [
      "Cat", "Cognome", "Nome", "Tess", "Sesso", "Anno"
    ]
    # Event reservations:
    for event_number in (1 .. @meeting.max_individual_events) do
      @header_titles << "Gara#{ event_number }"
      @header_titles << "Tempo#{ event_number }"
    end
    @header_titles << "Età"
    @header_titles
  end
  #-- -------------------------------------------------------------------------
  #++
end
