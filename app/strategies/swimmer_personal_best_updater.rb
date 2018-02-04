# encoding: utf-8


=begin

= SwimmerPersonalBestUpdater

 - Goggles framework vers.:  6.093
 - author: Steve A.

 Strategy class used to update MIR's #is_personal_best flag column.
 Creates a scrited DB-diff text of all the peformed updates.

 The serialization of the #sql_diff_text_log member is delagated to any external
 caller method.

=end
class SwimmerPersonalBestUpdater

  include SqlConvertable

  attr_reader :swimmer


  # Initialization
  #
  # == Params:
  # An instance of swimmer
  #
  def initialize( swimmer )
    raise ArgumentError.new("Needs a valid swimmer") unless swimmer && swimmer.instance_of?( Swimmer )
    @swimmer = swimmer
  end
  #-- --------------------------------------------------------------------------
  #++


  # Reset the personal best indicator (set to false)
  # for the current swimmer, given the specified event by pool type.
  #
  # This action updates the MIR row and logs the result onto the internal
  # sql_diff_text_log member.
  #
  # == Parameters
  # event by pool type
  #
  # == Returns
  # true on success; false otherwise
  #
  def reset_personal_best!( event_by_pool_type )
    sql_attributes = {}
    @swimmer.meeting_individual_results.for_event_by_pool_type(event_by_pool_type).is_personal_best.select( 'meeting_individual_results.id' ).each do |mir_only_id|
      mir = MeetingIndividualResult.find_by_id( mir_only_id.id )
      mir.is_personal_best = false
      if mir.save
        comment = "#{@swimmer.get_full_name}: Reset #{event_by_pool_type.i18n_description} (was #{mir.get_timing_instance})"
        sql_attributes['is_personal_best'] = mir.is_personal_best
        sql_diff_text_log << to_sql_update( mir, false, sql_attributes, "\r\n", comment )
        true
      else
        false
      end
    end
  end


  # Reset all the personal best indicator (sets the new value to false)
  # for the current swimmer.
  #
  # This action updates the MIR row and logs the result onto the internal
  # sql_diff_text_log member.
  #
  def reset_all_personal_bests!
    @swimmer.meeting_individual_results
      .where( is_personal_best: true )
      .update_all( is_personal_best: false )
    sql_diff_text_log << "update meeting_individual_results set is_personal_best = false where swimmer_id = #{@swimmer.id} and is_personal_best = true;\r\n"
  end


  # Set the personal best indicator to true
  # for the current swimmer, given the event by pool type
  #
  # This action updates the MIR row and logs the result onto the internal
  # sql_diff_text_log member.
  #
  # == Parameters:
  # - event by pool type
  # - reset previous results
  # - new personal best id
  #
  # == Returns
  # The updated MIR instance or nil
  #
  def set_personal_best!( event_by_pool_type, reset = true, mir_id = nil )
    # TODO Handle multiple personal-best timings for same event... FUTUREDEV
    sql_attributes = {}
    if @swimmer.meeting_individual_results.for_event_by_pool_type( event_by_pool_type ).is_not_disqualified.exists?
      reset_personal_best!( event_by_pool_type ) if reset
      mir_id = @swimmer.meeting_individual_results.for_event_by_pool_type( event_by_pool_type ).is_not_disqualified.sort_by_timing( :asc ).first.id if not mir_id
      mir = MeetingIndividualResult.find( mir_id )
      mir.is_personal_best = true
      mir.save
      comment = "#{@swimmer.get_full_name} #{event_by_pool_type.i18n_description}: #{mir.get_timing_instance}"
      sql_attributes['is_personal_best'] = mir.is_personal_best
      sql_diff_text_log << to_sql_update( mir, false, sql_attributes, "\r\n", comment )
      mir
    else
      nil
    end
  end


  # Scan events by pool type for finding out the
  # personal best timings for the current swimmer.
  #
  # This action updates the MIR row and logs the result onto the internal
  # sql_diff_text_log member.
  #
  # == Returns
  # The total count of Swimmer personal-best timings found.
  #
  def scan_for_personal_best!
    create_sql_diff_header( "Scanning swimmer #{@swimmer.get_full_name} [#{@swimmer.id}] for personal bests" )
    reset_all_personal_bests!
    EventsByPoolType.not_relays.each do |event_by_pool_type|
      set_personal_best!( event_by_pool_type, false )
    end
    create_sql_diff_footer( "Swimmer #{@swimmer.get_full_name}: #{@swimmer.meeting_individual_results.is_personal_best.count} personal bests found" )
    @swimmer.meeting_individual_results.is_personal_best.count
  end
  #-- --------------------------------------------------------------------------
  #++
end
