# encoding: utf-8

=begin

= RecordUpdater
  - Goggles framework vers.:  6.100
  - author: Steve A.

 Strategy dedicated to the single task of updating or creating IndividualRecord rows
 from a supplied list of MeetingIndibidualResult rows.

 A logger instance can be supplied externally to display the current progress.

=end
class RecordUpdater
  include SqlConvertable

  # If the logger has been specified, this will be the step of the logging process
  # (tipically, a single dot printed on the console)
  LOG_PROGRESS_STEP = 10

  attr_writer :logger
  attr_reader :updated_records, :added_records
  #-- -------------------------------------------------------------------------
  #++


  # Creates a new instance.
  #
  def initialize()
    sql_diff_text_log = ''                          # SQL diff log
    @updated_records = 0
    @added_records = 0
  end


  # Seeks an existing IndividualRecord for a chosen result row.
  #
  # == Params:
  # - result_row: the result row that has to be processed.
  #               (It can also be an array of IndividualResult, it doesn't have
  #               to be neccessarily a MeetingIndividualResult)
  # - must_be_a_team_record: +true+ if the search must be performed on the Team records
  #               (+false+ or +nil+ for a season_type-record search)
  #
  # == Returns
  # +nil+ when no record was found.
  #
  def find_existing_record_for( result_row, must_be_a_team_record )
    record_type = RecordType.find_by_code( must_be_a_team_record ? 'TTB' : 'FOR' )
    if must_be_a_team_record
      IndividualRecord.includes(:category_type).where(
        pool_type_id:     result_row.pool_type.id,
        event_type_id:    result_row.event_type.id,
        # Leega. The category should be compared with code and not by id because every seasons has its own ones
        #category_type_id: result_row.category_type.id,
        'category_types.code' => result_row.category_type.code,
        gender_type_id:   result_row.gender_type.id,
        record_type_id:   record_type.id,
        team_id:          result_row.team_id,
        is_team_record:   true
      ).first
    else
      IndividualRecord.includes(:season_type, :category_type)
        .where(
          pool_type_id:     result_row.pool_type.id,
          event_type_id:    result_row.event_type.id,
          # Leega. The category should be compared with code and not by id because every seasons has its own ones
          #category_type_id: result_row.category_type.id,
          'category_types.code' => result_row.category_type.code,
          gender_type_id:   result_row.gender_type.id,
          record_type_id:   record_type.id,
          # [Steve, 20150602] If it's not a "team record", then it must be a federation
          # record (a season_type_id-governed record):
          'season_types.id' => result_row.season_type.id,
          is_team_record:   false
        ).first
    end
  end


  # Compares any result row specified with an IndividualRecord. This only comapares
  # the timing, not the possible category/event/pool or gender type combination.
  #
  # That is, it assumes both rows respond to the timing members (#minutes, #seconds & #hundreds),
  # without checking if both rows are actually comparable in a "ranking" sense.
  #
  # Returns +true+ if the first specified result is a new record (is "better") in
  # comparison to the second one. +false+ otherwise.
  #
  def is_better( meeting_individual_result, individual_record )
    return false if meeting_individual_result.nil?
    return true if individual_record.nil?
    if ( meeting_individual_result.respond_to?(:get_timing_instance) &&
         individual_record.respond_to?(:get_timing_instance) )
       first_timing  = meeting_individual_result.get_timing_instance
       second_timing = individual_record.get_timing_instance
       # Compare the 2 timings:
       case first_timing <=> second_timing
       when -1
         true
       else
         false
       end
    else
      false
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  # Loops on a given result list, seeking any missing or improved record updates.
  # This only iterates searching for season_type-only records (not team records).
  #
  # The season-types considered for the search are only the ones found in each
  # individual result row supplied with the list.
  #
  # In between each iteration, the DB and the SQL diff log text are updated.
  #
  # Note that no SQL diff log files are created: this is delegated to other external
  # methods.
  #
  def scan_results_for_season_type_records( meeting_individual_result_list )
    scan_records_with( meeting_individual_result_list, false )
  end
  #-- -------------------------------------------------------------------------
  #++


  # Loops on a given result list, seeking any missing or improved record updates.
  # This only iterates searching for team-only records (not season-type records).
  #
  # The teams considered for the search are only the ones found in each
  # individual result row supplied with the list.
  #
  # In between each iteration, the DB and the SQL diff log text are updated.
  #
  # Note that no SQL diff log files are created: this is delegated to other external
  # methods.
  #
  def scan_results_for_team_records( meeting_individual_result_list )
    scan_records_with( meeting_individual_result_list, true )
  end
  #-- -------------------------------------------------------------------------
  #++


  # Performs a low-level forced update of all the individual records enlisted in
  # the specified recordX4d_dao.
  #
  # This method can be used update *only* the 'TTB'-type records if the personal-best
  # have already been retrieved.
  #
  # The recordX4d_dao can be obtained using the dedicated TeamPersonalBestFinder strategy.
  #
  def force_update_for_team_records( recordX4d_dao )
    return unless recordX4d_dao.instance_of?( RecordX4dDAO )
    record_type = RecordType.find_by_code('TTB')
    index = 0

    recordX4d_dao.records.each do |record_dao|
      is_ok = true
      mir   = record_dao.record
      existing_record = find_existing_record_for( mir, true )

      if existing_record                            # Existing record slot found?
        if is_better( mir, existing_record )        # Better result? => Update record!
          new_attribute_values = {
            minutes:                      mir.minutes,
            seconds:                      mir.seconds,
            hundreds:                     mir.hundreds,
            swimmer_id:                   mir.swimmer_id,
            team_id:                      mir.team_id,
            season_id:                    mir.season.id,
            federation_type_id:           mir.federation_type.id,
            meeting_individual_result_id: mir.id,
            is_team_record:               true
          }
          is_ok = existing_record.update_attributes( new_attribute_values )
          if is_ok                                  # Update the SQL diff:
            sql_diff_text_log << to_sql_update( existing_record, false, new_attribute_values, "\r\n" ) # (false: no comment)
            @updated_records += 1
          end
        end

      else                                          # Record missing? => Insert record!
        new_record = IndividualRecord.new.from_individual_result( mir, record_type )
        new_record.is_team_record = true
        begin
          is_ok = new_record.save!
        rescue
          puts "\r\nError while saving #{new_record.inspect}"
          puts "Exception: #{ $!.to_s }" if $!
          sql_diff_text_log << "-- save statement failed! Row ID: #{new_record.id}\r\n"
        end
        if is_ok                                    # Update the SQL diff:
          sql_diff_text_log << to_sql_insert( new_record, false, "\r\n" ) # (false: no comment)
          @added_records += 1
        end
      end
                                                    # Log current progress in big steps:
      index += 1
      if ((index % LOG_PROGRESS_STEP) == 0) && @logger
        @logger.infoc('.')
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  private


  def scan_records_with( meeting_individual_result_list, must_be_a_team_record )
    return unless meeting_individual_result_list.respond_to?(:each)
    record_type = RecordType.find_by_code( must_be_a_team_record ? 'TTB' : 'FOR' )
    index = 0

    meeting_individual_result_list.each do |mir|
      is_ok = true
      existing_record = find_existing_record_for( mir, must_be_a_team_record )

      if existing_record                            # Existing record slot found?
        if is_better( mir, existing_record )        # Better result? => Update record!
          new_attribute_values = {
            minutes:                      mir.minutes,
            seconds:                      mir.seconds,
            hundreds:                     mir.hundreds,
            swimmer_id:                   mir.swimmer_id,
            team_id:                      mir.team_id,
            season_id:                    mir.season.id,
            federation_type_id:           mir.federation_type.id,
            meeting_individual_result_id: mir.id,
            is_team_record:               must_be_a_team_record
          }
          is_ok = existing_record.update_attributes( new_attribute_values )
          if is_ok                                  # Update the SQL diff:
            sql_diff_text_log << to_sql_update( existing_record, false, new_attribute_values, "\r\n" ) # (false: no comment)
            @updated_records += 1
          end
        end
      else                                          # Record missing? => Insert record!
        new_record = IndividualRecord.new.from_individual_result( mir, record_type )
        new_record.is_team_record = must_be_a_team_record
        begin
          is_ok = new_record.save!
        rescue
          puts "\r\nError while saving #{new_record.inspect}"
          puts "Exception: #{ $!.to_s }" if $!
          sql_diff_text_log << "-- save statement failed! Row ID: #{new_record.id}\r\n"
        end
        if is_ok                                    # Update the SQL diff:
          sql_diff_text_log << to_sql_insert( new_record, false, "\r\n" ) # (false: no comment)
          @added_records += 1
        end
      end
                                                    # Log current progress in big steps:
      index += 1
      if ((index % LOG_PROGRESS_STEP) == 0) && @logger
        @logger.infoc('.')
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end