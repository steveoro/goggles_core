require 'wrappers/timing'

#
# == SwimmerBestFinder
#
# Strategy Pattern implementation for swimmer best result retrieving
#
# @author   Leega
# @version  4.00.837
#
class SwimmerBestFinder
  include SqlConvertable

  # These can be edited later on:
  attr_accessor :swimmer

  # Initialization
  #
  # == Params:
  # An instance of swimmer
  #
  def initialize( swimmer )
    unless swimmer && swimmer.instance_of?( Swimmer )
      raise ArgumentError.new("Needs a valid swimmer")
    end

    @swimmer = swimmer
  end
  #-- --------------------------------------------------------------------------
  #++

  # Collect closed seasons in which the swimmer was involved
  # If season type given tha scan is limited to seasons
  # of given type
  # In no given season type it scans all seasons
  def get_closed_seasons_involved_into( season_type = nil )
    season_type ?
     @swimmer.seasons.for_season_type(season_type).is_ended.sort_season_by_begin_date( 'DESC' ) :
     @swimmer.seasons.is_ended.sort_season_by_begin_date( 'DESC' )
  end
  #-- --------------------------------------------------------------------------
  #++

  # Collect curent open seasons in which the swimmer was involved
  # If season type given tha scan is limited to seasons
  # of given type
  # In no given season type it scans all seasons
  def get_current_seasons_involved_into( season_type = nil )
    season_type ? @swimmer.seasons.for_season_type(season_type).is_not_ended : @swimmer.seasons.is_not_ended
  end
  #-- --------------------------------------------------------------------------
  #++

  # Collect contemporary seasons in which the swimmer was involved
  # starting from begin and end season dates of a given season
  # Contemporary seasons are those which has at least one day
  # in the range of given one
  def get_contemporary_seasons_involved_into( season )
    @swimmer.seasons.is_in_range( season.begin_date, season.end_date )
  end
  #-- --------------------------------------------------------------------------
  #++

  # Find personal last best for given involved seasons, event type and pool type
  # Last best is the best time swam in the more recent involved season
  # Scan the closed seasons startng from most recent backwards
  def get_involved_season_last_best_for_event( involved_seasons, event_type, pool_type )
    involved_seasons.each do |season|
      if @swimmer.meeting_individual_results.for_season( season ).for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.count > 0
        return @swimmer.meeting_individual_results.for_season( season ).for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.sort_by_timing('ASC').first.get_timing_instance
      end
    end
    return nil
  end

  # Find personal last best for given involved seasons, event type and pool type
  # useing events by pool type instead of independent pool type and event type
  def get_involved_season_last_best_for_key( involved_seasons, event_by_pool_type_key )
    event_by_pool_type = EventsByPoolType.find_by_key( event_by_pool_type_key )
    event_by_pool_type ? get_involved_season_last_best_for_event( involved_seasons, event_by_pool_type.event_type, event_by_pool_type.pool_type ) : nil
  end
  #-- --------------------------------------------------------------------------
  #++

  # Find personal best for given season type, event type and pool type
  def get_season_type_best_for_event( season_type, event_type, pool_type )
    @swimmer.meeting_individual_results.for_season_type( season_type ).for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.count > 0 ?
      @swimmer.meeting_individual_results.for_season_type( season_type ).for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.sort_by_timing('ASC').first.get_timing_instance :
      nil
  end
  #-- --------------------------------------------------------------------------
  #++

  # Find personal best for given involved seasons, event type and pool type
  def get_involved_season_best_for_event( involved_seasons, event_type, pool_type )
    best = nil
    involved_seasons.each do |season|
      if @swimmer.meeting_individual_results.for_season( season ).for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.count > 0
        tmp_best = @swimmer.meeting_individual_results.for_season( season ).for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.sort_by_timing('ASC').first.get_timing_instance
        best = tmp_best if best == nil || best.to_hundreds > tmp_best.to_hundreds
      end
    end
    return best
  end

  # Find personal best for given event type and pool type
  def get_best_for_event( event_type, pool_type )
    @swimmer.meeting_individual_results.for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.count > 0 ?
      @swimmer.meeting_individual_results.for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.sort_by_timing('ASC').first.get_timing_instance :
      nil
  end

  # Find personal best for given event type and pool type
  def get_best_for_event_result( event_type, pool_type )
    @swimmer.meeting_individual_results.for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.count > 0 ?
      @swimmer.meeting_individual_results.for_pool_type( pool_type ).for_event_type( event_type ).is_personal_best.first :
      nil
  end

  # Check if the result is the personal best
  # without considering the apposite flag
  # This is intended for new results or to handle
  # best results with same timing.
  # == Returns
  # true if the result ise the personal best
  # false in any other cases
  def is_personal_best( meeting_individual_result )
    is_personal_best = false
    unless meeting_individual_result.nil? || (meeting_individual_result && meeting_individual_result.is_disqualified)
      best_result = get_best_for_event( meeting_individual_result.event_type, meeting_individual_result.pool_type )
      is_personal_best = best_result && best_result < meeting_individual_result.get_timing_instance ? false : true
    end
    is_personal_best
  end
  #-- --------------------------------------------------------------------------
  #++

  # Find personal best for given event in the meeting
  # It will consider all the given meeting editions
  def get_best_for_meeting_event( meeting, event_type, pool_type )
    @swimmer.meeting_individual_results.for_meeting_editions( meeting ).for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.count > 0 ?
      @swimmer.meeting_individual_results.for_meeting_editions( meeting ).for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.sort_by_timing('ASC').first.get_timing_instance :
      nil
  end
  #-- --------------------------------------------------------------------------
  #++

  # Reset the personal best indicator (set to false)
  # for the current swimmer, given the specified event by pool type
  #
  # == Parameters
  # event by pool type
  #
  def reset_personal_best( event_by_pool_type )
    sql_attributes = {}
    @swimmer.meeting_individual_results.for_event_by_pool_type(event_by_pool_type).is_personal_best.select( 'meeting_individual_results.id' ).each do |mir_only_id|
      mir = MeetingIndividualResult.find_by_id( mir_only_id.id )
      mir.is_personal_best = false
      mir.save
      comment = "#{@swimmer.get_full_name}: Reset #{event_by_pool_type.i18n_description} (was #{mir.get_timing_instance})"
      sql_attributes['is_personal_best'] = mir.is_personal_best
      sql_diff_text_log << to_sql_update( mir, false, sql_attributes, "\r\n", comment )
    end
  end

  # Reset all the personal best indicator (sets the new value to false)
  # for the current swimmer.
  #
  def reset_all_personal_bests
    @swimmer.meeting_individual_results
      .where( is_personal_best: true )
      .update_all( is_personal_best: false )
    sql_diff_text_log << "update meeting_individual_results set is_personal_best = false where swimmer_id = #{@swimmer.id} and is_personal_best = true;\r\n"
  end

  # Set the personal best indicator to true
  # for the current swimmer, given the event by pool type
  #
  # Parameters
  # event by pool type
  # reset previous results
  # new personal best id
  #
  # == Returns
  # Best timing or nil
  #
  def set_personal_best( event_by_pool_type, reset = true, mir_id = nil )
    # TODO Handle multiple bests for same event... maybe
    sql_attributes = {}
    if @swimmer.meeting_individual_results.for_event_by_pool_type( event_by_pool_type ).is_not_disqualified.count > 0
      self.reset_personal_best( event_by_pool_type ) if reset
      mir_id = @swimmer.meeting_individual_results.for_event_by_pool_type( event_by_pool_type ).is_not_disqualified.sort_by_timing( :asc ).first.id if not mir_id
      mir = MeetingIndividualResult.find( mir_id )
      mir.is_personal_best = true
      mir.save
      comment = "#{@swimmer.get_full_name} #{event_by_pool_type.i18n_description}: #{mir.get_timing_instance}"
      sql_attributes['is_personal_best'] = mir.is_personal_best
      sql_diff_text_log << to_sql_update( mir, false, sql_attributes, "\r\n", comment )
      mir.get_timing_instance
    end
  end

  # Scan events by pool type for finding out the
  # personal best timings for the current swimmer.
  #
  # == Returns
  # Swimmer personal bests found number
  #
  def scan_for_personal_bests
    create_sql_diff_header( "Scanning swimmer #{@swimmer.get_full_name} [#{@swimmer.id}] for personal bests" )
    self.reset_all_personal_bests
    EventsByPoolType.not_relays.each do |event_by_pool_type|
      #self.reset_personal_best( event_by_pool_type ) # Better doing an unique update
      self.set_personal_best( event_by_pool_type, false )
    end
    create_sql_diff_footer( "Swimmer #{@swimmer.get_full_name}: #{@swimmer.meeting_individual_results.is_personal_best.count} personal bests found" )
    @swimmer.meeting_individual_results.is_personal_best.count
  end
  #-- --------------------------------------------------------------------------
  #++
end
