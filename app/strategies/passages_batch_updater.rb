require 'wrappers/timing'
require 'timing_parser'
require 'common/validation_error_tools'


=begin

= PassagesBatchUpdater
  - Goggles framework vers.:  6.093
  - author: Leega, Steve A.

 Strategy dedicated to the single task of updating or creating Passage rows.

=end
class PassagesBatchUpdater
  include SqlConvertable

  # These can be edited later on:
  attr_reader :edited_passages, :new_passages, :destroyed_passages,
              :total_errors

  # Creates a new instance, given the current user that has created this batch
  # of operations.
  #
  def initialize( created_by_user )
    @edited_passages = 0
    @new_passages = 0
    @destroyed_passages = 0
    @total_errors = 0
    @current_user = created_by_user
    create_sql_diff_header( "PassagesBatchUpdater: recorded from actions by #{ created_by_user }" )
  end
  #-- -------------------------------------------------------------------------
  #++

  # Edits an existing passage id assuming its new value for the incremental
  # timing should be the one specified as a string parameter.
  #
  # If the parsing of the text value fails or the text value is nil or empty,
  # the passage is assumed to be *cleared*. That, currently, equals to the row
  # being deleted.
  #
  # This method updates also the internal counters of the whole batch operation,
  # as well as the progressive SQL diff log file.
  # (Which should be serialized by some other external method at the end of the
  # whole batch of edits or creations.)
  #
  # == Returns:
  # +true+ if successful, +false+ in case of errors, a deleted row instance in
  # case of row deletion.
  #
  def edit_existing_passage!( passage_id, incremental_timing_text_value )
    passage = Passage.find_by_id( passage_id )
    timing = TimingParser.parse( incremental_timing_text_value )
    is_ok = true
    if timing && passage                          # Update w/ new value:
      passage = prepare_passage_fields( passage, timing )
      is_ok = passage.save
      if is_ok
        sql_attributes = passage.attributes.select do |key,val|
          [
            'id', 'minutes', 'seconds', 'hundreds',
            'minutes_from_start', 'seconds_from_start', 'hundreds_from_start',
            'user_id'
          ].include?( key.to_s )
        end
        sql_diff_text_log << to_sql_update( passage, false, sql_attributes, "\r\n" )
        @edited_passages += 1
      else
        sql_diff_text_log << "-- UPDATE VALIDATION FAILURE: #{ ValidationErrorTools.recursive_error_for( passage ) }\r\n" if passage.invalid?
        sql_diff_text_log << "-- UPDATE FAILURE: #{ $! }\r\n" if $!
        @total_errors += 1
      end

    elsif timing.nil? && passage                  # Erase existing row:
      is_ok = passage.destroy
      if is_ok
        sql_diff_text_log << to_sql_delete( passage, false, "\r\n" )
        @destroyed_passages += 1
      else
        sql_diff_text_log << "-- DESTROY FAILURE: #{ $! }\r\n" if $!
        @total_errors += 1
      end
    end
    is_ok
  end
  #-- -------------------------------------------------------------------------
  #++


  # Creates a new passage row given its parent MIR id and its associated passage
  # type id and its new value for the incremental timing  specified as a string parameter.
  #
  # If the parsing of the text value fails or the text value is nil or empty,
  # the new passage is not created.
  #
  # This method updates also the internal counters of the whole batch operation,
  # as well as the progressive SQL diff log file.
  # (Which should be serialized by some other external method at the end of the
  # whole batch of edits or creations.)
  #
  # == Returns:
  # +true+ if successful, +false+ otherwise
  #
  def create_new_passage!( mir_id, passage_type_id, incremental_timing_text_value )
    timing = TimingParser.parse( incremental_timing_text_value )
    is_ok = true
    if timing                                       # Create the new row:
      passage = prepare_passage_fields( Passage.new, timing, mir_id, passage_type_id )
      is_ok = passage.save
      if is_ok
        sql_diff_text_log << to_sql_insert( passage, false, "\r\n" )
        @new_passages += 1
      else
        sql_diff_text_log << "-- INSERT VALIDATION FAILURE: #{ ValidationErrorTools.recursive_error_for( passage ) }\r\n" if passage.invalid?
        sql_diff_text_log << "-- INSERT FAILURE: #{ $! }\r\n" if $!
        @total_errors += 1
      end
    else
      sql_diff_text_log << "-- INSERT SKIPPED FOR INVALID PARSE: '#{ incremental_timing_text_value }', MIR ID: #{ mir_id }, passage_type_id: #{ passage_type_id }\r\n"
      is_ok = false
      @total_errors += 1
    end
    is_ok
  end
  #-- -------------------------------------------------------------------------
  #++


  # Estabilsh if a pasage is a delta
  # A passage is a delta if passage timing is the time swam in the passage distance
  # First passage is always a delta
  # A passage is a delta if lesser than prevvoius one
  # A passage is a delta if greater than prevvoius one but
  # not more 50% of difference with previous distance swam (average speed per meter).
  # (so a passage is incremental only if greater than previous one)
  #
  # EG 1.
  #  50: 3000 -> delta (first passage)
  # 100: 6130 -> incremental (50 in 6130 is a variation greater than 50% of previous one)
  # 150: 9300 -> incremental (50 in 9300 is a variation lesser than 50% of previous one)
  # EG 2.
  #  50: 3000 -> delta (first passage)
  # 100: 3130 -> delta (50 in 3130 is a variation lesser than 50% of previous one)
  # 150: 3270 -> delta (50 in 3270 is a variation lesser than 50% of previous one)
  #
  def is_delta?( passage )
    is_delta = false

    # Is incremental (not delta) if passage time swam equal to mir time swam
    if passage.get_timing_instance == passage.get_final_time
      is_delta = false
    else
      previous_passage = passage.get_previous_passage
      if previous_passage
        total_time_before = previous_passage.compute_incremental_time
        # Is delta if passage time swam smaller than time swam before
        if total_time_before > passage.get_timing_instance
          is_delta = true
        # Is delta if passage swam speed per meter smaller than average swam speed per meter * 50%
        elsif (passage.get_timing_instance.to_hundreds / passage.compute_distance_swam) <= (( passage.get_final_time.to_hundreds / passage.get_total_distance ) * 1.5 )
          is_delta = true
        # Is incremental if passage swam speed per meter greater than average swam speed per meter * 50%
        else
          is_delta = false
        end
      # Is delta if first passage (or no previous one)
      else
        is_delta = true
      end
    end
    is_delta
  end


  private


  # Prepares the required timing fields for the specified passage instance row,
  # given a parsed timing instance containing the values used to update the Passage.
  #
  # === Returns:
  # The updated Passage instance
  #
  def prepare_passage_fields( passage, timing, mir_id = nil, passage_type_id = nil )
    passage.user_id = @current_user.id
    if mir_id
      mir = MeetingIndividualResult.find( mir_id )
      passage.meeting_program_id = mir.meeting_program_id
      passage.meeting_individual_result_id = mir_id
      passage.swimmer_id = mir.swimmer_id
      passage.team_id = mir.team_id
    end
    passage.passage_type_id = passage_type_id if passage_type_id

    prev_timing = passage.get_previous_passage ? passage.get_previous_passage.compute_incremental_time : nil

    # Detrminates if passage is delta or incremental
    #is_delta = false
    passage.minutes  = timing.minutes
    passage.seconds  = timing.seconds
    passage.hundreds = timing.hundreds
    is_delta = is_delta?( passage )

    if is_delta == true
      # Timing is the delta.
      # Should calculate time from start
      passage.minutes  = timing.minutes
      passage.seconds  = timing.seconds
      passage.hundreds = timing.hundreds
      passage.minutes_from_start  = timing.minutes + ( prev_timing ? prev_timing.minutes : 0 )
      passage.seconds_from_start  = timing.seconds + ( prev_timing ? prev_timing.seconds : 0 )
      passage.hundreds_from_start = timing.hundreds + ( prev_timing ? prev_timing.hundreds : 0 )
    else
      # Timing is the incremental.
      # Should calculate delta time
      delta_timing = prev_timing ? timing - prev_timing : timing
      passage.minutes  = delta_timing.minutes
      passage.seconds  = delta_timing.seconds
      passage.hundreds = delta_timing.hundreds
      passage.minutes_from_start  = timing.minutes
      passage.seconds_from_start  = timing.seconds
      passage.hundreds_from_start = timing.hundreds
    end
    puts "\r\n-#{mir_id} : " << passage.inspect
    passage
  end
  #-- -------------------------------------------------------------------------
  #++
end