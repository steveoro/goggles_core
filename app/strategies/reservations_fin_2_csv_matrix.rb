# frozen_string_literal: true

require 'framework/console_logger'

#
# = ReservationsFin2CsvMatrix
#
#   - Goggles framework vers.:  6.157
#   - author: Leega
#
#  Strategy class used to output a specific CSV text format for the C.S.I. Regional
#  Championship (used to exchange reservation data in between organizations).
#
#  Given a valid Meeting.id (of a Meeting belonging to the FIN Championship),
#  the source data set is obtained from a selected bunch of rows from MeetingReservations,
#  MeetingEventReservation and MeetingRelayReservation.
#
#  The stategy allows to extract all team and swimmer reservations found and to export
#  the data in the custom format.
#
#  The extracted data can be serialized on file at will with a dedicated method.
#
class ReservationsFin2CsvMatrix

  DEFAULT_OUTPUT_DIR = Rails.root.join('public', 'output').freeze unless defined? DEFAULT_OUTPUT_DIR

  attr_reader :fin_data_rows, :created_file_full_pathname
  #-- -------------------------------------------------------------------------
  #++

  # Creates a new instance by specifying a valid Meeting instance.
  # The Meeting must belong to a Season of the FIN federation.
  #
  # If no filtering_team is specified, all the reservations for the meeting will
  # be collected.
  #
  def initialize(meeting, filtering_team = nil, logger = ConsoleLogger.new)
    raise ArgumentError, 'The specified Meeting must be a valid instance of Meeting' unless ReservationsFin2CsvMatrix.is_a_valid_meeting(meeting)

    @meeting = meeting
    @filtering_team = filtering_team
    @logger = logger
    @fin_data_rows = []                             # Actual data rows to be exported
    @swimmers_reservations = 0                      # Simply counts the reservation found
    # This will be used to extract a valid team/affiliation reference from the swimmer badge:
    @first_swimmer_reservation = nil
    @pre_header_lines = []
    @created_file_full_pathname = nil
    # Enforce locale needed by this strategy:
    I18n.locale = :it
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns true if the specified Meeting instance can be processed by this strategy
  # (regardless the fact that the Meeting has or hasn't any associated reservations).
  # Always false otherwise.
  # This strategy treats only FIN federation meetings
  #
  def self.is_a_valid_meeting(meeting)
    return false if meeting.nil?

    meeting&.instance_of?(Meeting) && meeting.federation_type.code == 'FIN'
  end
  #-- -------------------------------------------------------------------------
  #++

  # Collects the data.
  #
  def collect
    @logger.info('Extracting reservation data for FIN2CSV data export...')
    reservations = if @filtering_team.instance_of?(Team)
      @logger.info("(Filtering for #{@filtering_team.get_full_name} swimmers)")
      MeetingReservation.where(meeting_id: @meeting.id, team_id: @filtering_team.id).is_coming
    else
      MeetingReservation.where(meeting_id: @meeting.id).is_coming
    end

    # Scan involved swimmers
    reservations.each do |meeting_reservation|
      swimmer = meeting_reservation.swimmer
      reservations_count = @meeting.meeting_event_reservations.where(['swimmer_id = ?', swimmer.id]).is_reserved.count

      next unless reservations_count > 0

      badge = meeting_reservation.badge
      @logger.info("Swimmer #{swimmer.get_full_name} (#{badge.category_type.code})")
      @swimmers_reservations += 1
      # Store the first reservation in order to extract useful team data for the headers later on:
      @first_swimmer_reservation = meeting_reservation if @swimmers_reservations == 1

      swimmer_row = ''
      swimmer_row << "#{badge.category_type.code};"
      # If we have the last name, this means that the name has already been correctly split:
      if swimmer.last_name.present?
        swimmer_row << "#{swimmer.last_name};"
        swimmer_row << "#{swimmer.first_name};"
      # Otherwise, we have to guess the first & last name part from the complete_name.
      # Typically, this is not possible. So we stick using the last item in the
      # array of split elements as the first name (the sequence in complete_name
      # is to use the last_name as first). The rest of the sequence is joined together.
      else
        name_parts = swimmer.get_full_name.split(/\s/)
        first_name = name_parts.last
        last_name  = name_parts[0..name_parts.size - 2].join(' ')
        swimmer_row << "#{last_name};"
        swimmer_row << "#{first_name};"
      end
      swimmer_row << "#{badge.number != '?' ? badge.number : ''};"
      swimmer_row << "#{swimmer.gender_type.code};"
      swimmer_row << "#{swimmer.year_of_birth};"

      # Scan events
      @meeting.meeting_event_reservations.where(['swimmer_id = ?', swimmer.id]).is_reserved.each do |meeting_event_reservation|
        swimmer_row << "#{meeting_event_reservation.get_event_type};"
        swimmer_row << if meeting_event_reservation.is_no_time
          'ST;'
        else
          "#{meeting_event_reservation.get_timing_flattened};"
                       end
      end
      # Add empty columns if event reservations are less than expected output format:
      (get_actual_total_reservable_events(@meeting) - reservations_count).times do
        swimmer_row << ';;'
      end
      swimmer_row << "#{@meeting.header_date.year - swimmer.year_of_birth};"
      @fin_data_rows << swimmer_row
    end
    # After we have collected the reservations, we can prepare the headers:
    prepare_header_titles
  end

  # Composes the resulting text CSV output.
  # Returns nil if no data rows were collected.
  #
  def output_text
    unless @fin_data_rows.empty?
      @pre_header_lines.join("\r\n") + "\r\n" +
        ([@header_titles.join(';')] + @fin_data_rows).join("\r\n")
    end
  end

  # Exports the collected data to a custom CSV file format.
  # It returns the created file full pathname, or nil if case there wasn't any
  # data to be exported.
  #
  def save_to_file(output_dir = DEFAULT_OUTPUT_DIR)
    if @swimmers_reservations > 0
      @logger.info("\r\nExtracted data for #{@swimmers_reservations} swimmers reservations.")
      extension = if @filtering_team.instance_of?(Team)
        @logger.info("(While filtering for #{@filtering_team.get_full_name} swimmers, team ID: #{@filtering_team.id})")
        "#{@filtering_team.id}.csv"
      elsif @first_swimmer_reservation.instance_of?(MeetingReservation)
        affiliation = @first_swimmer_reservation.badge.team_affiliation
        @logger.info("(While filtering for #{affiliation.get_full_name} swimmers, team ID: #{affiliation.team_id})")
        "#{affiliation.team_id}.csv"
      else
        'csv'
      end

      # (Re-)Create the csv file:
      file_name = @meeting.get_data_import_file_name('isc', extension)
      @created_file_full_pathname = File.join(output_dir, file_name)
      File.open(@created_file_full_pathname, 'w') { |f| f.puts output_text }
      @logger.info("\r\nEntry file " + file_name + " created\r\n")
    else
      @logger.info("\r\nNo reservations found. File creation skipped.\r\n")
    end
    @created_file_full_pathname
  end
  #-- -------------------------------------------------------------------------
  #++

  private

  # Computes the actual total number of possibile reservations for this meeting
  #
  def get_actual_total_reservable_events(meeting)
    # Include also "out-of-race" events, which are usually not counted among the
    # max_individual_events value:
    meeting.max_individual_events + meeting.meeting_events.where(is_out_of_race: true).count
  end

  # Prepares the header
  #
  def prepare_header_titles
    if @first_swimmer_reservation
      team = @first_swimmer_reservation.team
      affiliation = @first_swimmer_reservation.badge.team_affiliation
      team_manager = TeamManager.where(team_affiliation_id: affiliation.id).first
      meeting_session = @meeting.meeting_sessions.first

      place   = meeting_session.swimming_pool.city.name
      date    = meeting_session.get_scheduled_date
      events  = meeting_session.get_short_name.gsub(';', ',')
      address = team&.address ? team.address.gsub(';', ',') : ''
      phone   = team&.phone_number ? team.phone_number : ''
      mobile  = team&.phone_mobile ? team.phone_mobile : ''
      email   = team&.e_mail ? team.e_mail : team_manager.user.email
      manager_name = team&.contact_name ? team.contact_name : "#{team_manager.user.first_name} #{team_manager.user.last_name}"

      @pre_header_lines = [
        "data e località manifestazione;;;;#{date} #{@meeting.description} #{place};;;;;",
        'Società;;;;;;;;;',
        "#{affiliation.name};;;;;;;;;",
        'Indirizzo (Via, CAP, località, provincia);;;;;;;;;',
        "#{address};;;;;;;;;",
        'Responsabile e recapito telefonico;;;;;;;;;',
        "#{manager_name} #{phone || mobile};;;;;;;;;",
        'Email;;;;;;;;;',
        "#{email};;;;;;;;;",
        ';;;;;;;;;'
      ]
    end

    @header_titles = %w[
      Cat Cognome Nome Tess Sesso Anno
    ]
    # Get the total number of possibile reservations:
    total_reservable_events =
      # Event reservations for each possible event:
      (1..get_actual_total_reservable_events(@meeting)).each do |event_number|
        @header_titles << "Gara#{event_number}"
        @header_titles << "Tempo#{event_number}"
      end
    @header_titles << 'Età'
    @header_titles
  end
  #-- -------------------------------------------------------------------------
  #++

end
