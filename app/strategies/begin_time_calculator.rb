# frozen_string_literal: true

require 'common/format'

#
# = BeginTimeCalculator
#
#   - Goggles framework vers.:  4.00.767
#   - author: Steve A.
#
#  Allows to compute an esteemed begin time for any Meeting program or event given
#  the number of total registered athletes, the event ordinal number and its base
#  time.
#
class BeginTimeCalculator

  # Computes the esteemed begin time of any event, given the parameters.
  # (Useful when the results are not available yet.)
  #
  # == Params:
  # - scheduled_date:
  #   Tthe scheduled date for this event/program;
  # - event_order:
  #   The ordinal number of the event/program;
  # - total_athletes:
  #   The total number of athletes for this event/program;
  # - base_time_mins:
  #   The base time minutes for this event (taken from time_standards);
  # - previous_begin_time:
  #   (default +nil+) when given as either a Time or a DateTime instance,
  #   the previous event begin time allows the computation to be more precise;
  # - previous_duration_in_secs:
  #   (default +120+) the previous event duration (esteemed) in seconds,
  # - pool_lanes_total:
  #   (default 8) the typical/medium number of pool lanes occupancy;
  # - starting_hour: (default 8) the starting hour of the event (24h format).
  #
  # == Returns
  # An instance of Time representing the alleged/esteemed begin time for this event
  # or program.
  #
  def self.compute_from_previous( scheduled_date, event_order, total_athletes,
    base_time_mins,
    previous_begin_time = nil, previous_duration_in_secs = 120,
    pool_lanes_total = 8, starting_hour = 8 )
    if previous_begin_time.instance_of?( Time )
      # DEBUG
      #      puts "\r\nprevious_begin_time: #{previous_begin_time}"
      return Time.utc(
        scheduled_date.year,
        scheduled_date.month,
        scheduled_date.day,
        previous_begin_time.hour % 24,
        previous_begin_time.min % 60
      ) + previous_duration_in_secs
    end
    # Compute heat number:
    heat_number_approx = get_esteemed_heat_number(
      total_athletes,
      pool_lanes_total,
      event_order
    ) # Compute esteemed duration:
    esteemed_duration_in_mins = get_esteemed_duration_in_mins(
      base_time_mins,
      heat_number_approx
    )
    # Prepare the result:
    Time.utc(
      scheduled_date.year,
      scheduled_date.month,
      scheduled_date.day,
      starting_hour,
      0
    ) + (esteemed_duration_in_mins * 60)
  end
  #-- --------------------------------------------------------------------------
  #++

  # Computes an esteemed heat number given the parameters.
  #
  def self.get_esteemed_heat_number( total_athletes, pool_lanes_total, event_order )
    event_order = event_order.to_i > 0 ? event_order.to_i : 1
    ( total_athletes / pool_lanes_total ) + event_order
  end

  # Computes an esteemed event duration in minutes given the parameters.
  #
  def self.get_esteemed_duration_in_mins( base_time_mins, heat_number_approx )
    if base_time_mins.to_i < 3
      heat_number_approx * 2
    else
      heat_number_approx * base_time_mins.to_i + 2
    end
  end

  # Computes the esteemed begin time of all the events given a Meeting with "enough"
  # results or entries.
  # The results (MeetingIndividualResult rows) are given priority over the entries
  # (MeetingEntry rows) to collect the exact duration time of each heat.
  # (For the entries to be considered for the heat length calc, the result rows
  # must be missing at all.)
  #
  # The specified meeting is updated while being processed if the +dry_run+ flag
  # is left to +false+. A diff SQL text is produced anyway and appended to the
  # +diff_sql_text+ variable specified.
  #
  # == Params:
  # - meeting: a Meeting instance to be processed.
  # - diff_sql_text: the string containing the SQL statements of the changes made
  # - dry_run: (default +false+) do not update the Meeting entities, but simulate the execution
  #
  # == Returns
  # +true+ only if the specified meeting has been processed, +false+ otherwise.
  #
  def self.compute_for_all( meeting, diff_sql_text, dry_run = false )
    if meeting.instance_of?( Meeting ) && diff_sql_text.instance_of?( String )
      results_count = meeting.meeting_individual_results.count
      entries_count = meeting.meeting_entries.count
      return false if results_count == 0 && entries_count == 0

      diff_sql_text << "-- --- BeginTimeCalculator: compute_for_all( #{meeting.id} )\r\n"
      diff_sql_text << "-- ----------------------------------------------------\r\n"
      athlete_rows = nil
      program_results = []
      diff_sql_text << if results_count == 0
        "-- Using ENTRIES to compute heat length.\r\n\r\n"
      else
        "-- Using RESULTS to compute heat length.\r\n\r\n"
      end

      # For each program, recreate a possible heat list:
      meeting.meeting_programs.order(:event_order).map do |mprg|
        lanes_number = mprg.meeting_session.swimming_pool.lanes_number.to_i
        # Set a default value for unknown swimming pools:
        lanes_number = 8 if lanes_number < 1
        athlete_rows = if results_count == 0
          mprg.meeting_entries.order('minutes DESC, seconds DESC, hundreds DESC').to_ary
        else
          mprg.meeting_individual_results.order('minutes DESC, seconds DESC, hundreds DESC').to_ary
        end
        # *** Esteem current session begin time: ***
        session_begin_time = nil
        session_begin_time = if mprg.meeting_session.begin_time.instance_of?(Time) && mprg.meeting_session.begin_time.hour > 0
          mprg.meeting_session.begin_time
        else # Default start time: 08:30
          mprg.meeting_session.scheduled_date.to_time + (8 * 60 * 60) + (30 * 60)
        end
        # *** Esteem current progr. heats durations: ***
        heat_durations = []
        ( 0..athlete_rows.size-1 ).step( lanes_number ) do |start_idx|
          current_heat = athlete_rows.slice( start_idx, lanes_number)
          max_timing = current_heat.map { |row| row.get_timing_instance.to_hundreds }.max
          # max_timing is in hundreds of a second; let's add 60" between each heat:
          heat_durations << max_timing + 6000
        end
        # *** Esteem Program begin time: ***
        program_begin_time = nil
        program_begin_time = if program_results.last.instance_of?(Hash)
          program_results.last[:program_begin] + program_results.last[:program_tot_secs]
        else
          session_begin_time + 120
        end
        # *** Append results to stored durations: ***
        program_results << {
          event_order: mprg.event_order,
          id: mprg.id,
          total_athletes: athlete_rows.size,
          heat_durations: heat_durations,
          program_tot_secs: heat_durations.sum / 100,
          session_begin: session_begin_time,
          program_begin: program_begin_time
        }
        diff_sql_text << "-- Event ##{mprg.event_order}, M.Prg: #{mprg.id}, tot. athletes: #{ athlete_rows.size }\r\n"
        diff_sql_text << "-- Tot. progr. duration: #{heat_durations.sum / 100} (sec), Heat durations: #{heat_durations.inspect} (hds)\r\n"
        diff_sql_text << "-- Session begin time: #{session_begin_time}, Computed begin time: #{program_begin_time}\r\n"
        diff_sql_text << "UPDATE meeting_programs SET begin_time = '#{ Format.any_datetime(program_begin_time, '%Y-%m-%d %H:%M') }'"
        diff_sql_text << " WHERE id = #{mprg.id};\r\n\r\n"
        unless dry_run
          mprg.begin_time = program_begin_time
          mprg.save!
        end
      end
      true
    else
      false
    end
  end
  #-- --------------------------------------------------------------------------
  #++

end
