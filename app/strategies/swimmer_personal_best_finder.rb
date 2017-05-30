require 'wrappers/timing'

=begin

= SwimmerPersonalBestFinder

 - Goggles framework vers.:  6.093
 - author: Leega, Steve A.

 Finder class for swimmer personal-best timings results

=end
class SwimmerPersonalBestFinder

  attr_reader :swimmer


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
  # If season type given the scan is limited to seasons
  # of given type
  # In no given season type it scans all seasons
  # If eneded_before date is given the scan is limted to seasons ended before given date
  def get_closed_seasons_involved_into( season_type = nil, ended_before = nil )
    seasons = season_type ?
     @swimmer.seasons.for_season_type(season_type).is_ended.sort_season_by_begin_date( 'DESC' ) :
     @swimmer.seasons.is_ended.sort_season_by_begin_date( 'DESC' )
    if ended_before
      seasons = seasons.reject{ |s| s.end_date > ended_before }
    end
    seasons
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


  # Finds the personal-best MIR for a given season type, event type and pool type.
  # Returns +nil+ when not found.
  #
  def get_season_type_best_mir_for_event( season_type, event_type, pool_type )
    @swimmer.meeting_individual_results.for_season_type( season_type ).for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.count > 0 ?
      @swimmer.meeting_individual_results.for_season_type( season_type ).for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.sort_by_timing('ASC').first :
      nil
  end

  # Finds the personal best Timing for a given season type, event type and pool type.
  # Returns +nil+ when not found.
  #
  def get_season_type_best_for_event( season_type, event_type, pool_type )
    # XXX [Steve] Previous implementation:
#    @swimmer.meeting_individual_results.for_season_type( season_type ).for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.count > 0 ?
#      @swimmer.meeting_individual_results.for_season_type( season_type ).for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.sort_by_timing('ASC').first.get_timing_instance :
#      nil
    season_type_best_mir = get_season_type_best_mir_for_event( season_type, event_type, pool_type )
    season_type_best_mir ? season_type_best_mir.get_timing_instance : nil
  end
  #-- --------------------------------------------------------------------------
  #++

  # Finds the personal-best *MIR* searching amidst the specified involved seasons,
  # event type and pool type.
  # Returns +nil+ when not found.
  #
  def get_involved_season_best_mir_for_event( involved_seasons, event_type, pool_type )
    best = nil
    involved_seasons.each do |season|
      if ( @swimmer.meeting_individual_results.for_season( season )
             .for_pool_type( pool_type )
             .for_event_type( event_type )
             .is_not_disqualified.count > 0 )
        tmp_best = @swimmer.meeting_individual_results.for_season( season )
            .for_pool_type( pool_type )
            .for_event_type( event_type )
            .is_not_disqualified
            .sort_by_timing('ASC')
            .first
        best = tmp_best if best == nil || best.get_timing_instance.to_hundreds > tmp_best.get_timing_instance.to_hundreds
      end
    end
    return best
  end

  # Finds the personal-best *Timing* searching amidst the specified involved seasons,
  # event type and pool type.
  # Returns +nil+ when not found.
  #
  def get_involved_season_best_for_event( involved_seasons, event_type, pool_type )
    best = nil
    involved_seasons.each do |season|
      if ( @swimmer.meeting_individual_results.for_season( season )
             .for_pool_type( pool_type )
             .for_event_type( event_type )
             .is_not_disqualified.count > 0 )
        tmp_best = @swimmer.meeting_individual_results.for_season( season )
            .for_pool_type( pool_type )
            .for_event_type( event_type )
            .is_not_disqualified
            .sort_by_timing('ASC')
            .first
            .get_timing_instance
        best = tmp_best if best == nil || best.to_hundreds > tmp_best.to_hundreds
      end
    end
    return best
  end
  #-- --------------------------------------------------------------------------
  #++


  # Finds the last MeetingIndividualResult row for a certain event and pool type.
  #
  # == Returns:
  # The MeetingIndividualResultrow or +nil+ when not found.
  #
  def get_last_mir_for_event( event_type, pool_type )
    @swimmer.meeting_individual_results.for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.count > 0 ?
      @swimmer.meeting_individual_results.for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.sort_by_date('DESC').first :
      nil
  end
  #-- --------------------------------------------------------------------------
  #++


  # Finds the personal-best's MeetingIndividualResult instance associated with
  # the given event and pool type.
  #
  # == Returns:
  # The personal-best's MeetingIndividualResult instance or +nil+ when not found.
  #
  def get_best_mir_for_event( event_type, pool_type )
    @swimmer.meeting_individual_results.for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.count > 0 ?
      @swimmer.meeting_individual_results.for_pool_type( pool_type ).for_event_type( event_type ).is_personal_best.first :
      nil
  end

  # Finds the personal-best's Timing instance associated with the given event and
  # pool type.
  #
  # == Returns:
  # The personal-best's Timing instance or +nil+ when not found.
  #
  def get_best_for_event( event_type, pool_type )
    # XXX Old implementation:
    #@swimmer.meeting_individual_results.for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.count > 0 ?
    #  @swimmer.meeting_individual_results.for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.sort_by_timing('ASC').first.get_timing_instance :
    #  nil
    best_mir = get_best_mir_for_event( event_type, pool_type )
    best_mir ? best_mir.get_timing_instance : nil
  end

  # Finds the personal-best's Timing instance for the given event and
  # pool type.
  #
  # == Returns:
  # The personal-best's Timing instance or +nil+ when not found.
  #
  def find_best_for_event( event_type, pool_type )
    @swimmer.meeting_individual_results.for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.count > 0 ?
      @swimmer.meeting_individual_results.for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.sort_by_timing('ASC').first.get_timing_instance :
      nil
  end

  # Finds the personal-best's Timing instance for the given event and
  # pool type.
  #
  # == Returns:
  # The personal-best's Timing instance or +nil+ when not found.
  #
  def find_best_mir_for_event( event_type, pool_type )
    @swimmer.meeting_individual_results.for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.count > 0 ?
      @swimmer.meeting_individual_results.for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.sort_by_timing('ASC').first :
      nil
  end
  #-- --------------------------------------------------------------------------
  #++


  # Finds the personal-best's MeetingIndividualResult instance for the specified
  # meeting, event and pool type.
  #
  # This will consider all the existing meeting editions.
  #
  # == Returns:
  # The personal-best MeetingIndividualResult instance for the Meeting event, or
  # +nil+ when not found.
  #
  def get_best_mir_for_meeting( meeting, event_type, pool_type )
    @swimmer.meeting_individual_results.for_meeting_editions( meeting ).for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.count > 0 ?
      @swimmer.meeting_individual_results.for_meeting_editions( meeting ).for_pool_type( pool_type ).for_event_type( event_type ).is_not_disqualified.sort_by_timing('ASC').first :
      nil
  end

  # Finds the personal-best's Timing instance for the specified
  # meeting, event and pool type.
  #
  # This will consider all the existing meeting editions.
  #
  # == Returns:
  # The personal-best Timing instance for the Meeting event, or
  # +nil+ when not found.
  #
  def get_best_timing_for_meeting( meeting, event_type, pool_type )
    best_mir = get_best_mir_for_meeting( meeting, event_type, pool_type )
    best_mir ? best_mir.get_timing_instance : nil
  end
  #-- --------------------------------------------------------------------------
  #++


  # Check if the result is the personal best
  # without considering the apposite flag
  # This is intended for new results or to handle
  # best results with same timing.
  # == Returns
  # true if the result is the personal best
  # false in any other cases
  def is_personal_best?( meeting_individual_result )
    is_personal_best = false
    unless meeting_individual_result.nil? || (meeting_individual_result && meeting_individual_result.is_disqualified)
      best_result = find_best_for_event( meeting_individual_result.event_type, meeting_individual_result.pool_type )
      is_personal_best = best_result && best_result < meeting_individual_result.get_timing_instance ? false : true
    end
    is_personal_best
  end
  #-- --------------------------------------------------------------------------
  #++
  
  
  # Finds the appropriate personal-best's Timing instance for the specified
  # meeting, event and pool type according to the swimmer badge setting.
  # If no result found will try to convert from other pool type, if possible.
  #
  # == Returns:
  # The personal-best Timing instance for the Meeting event, or
  # +nil+ when not found.
  #
  def get_entry_best_timing( badge, meeting, event_type, pool_type, convert_pool_type = false )
    best_mir = nil
    time_converted = nil

    # Perform check only if not in manual mode and swimmer already swam event type    
    if badge && badge.get_entry_time_type_code != 'M' && @swimmer.meeting_individual_results.for_event_type( event_type )
      best_mir = retrieve_entry_time_by_type( badge.get_entry_time_type_code, meeting, event_type, pool_type ) 
    
      # If not found and convert_pool_type set check for other pool_type
      if best_mir == nil && convert_pool_type
        pool_type = pool_type.code == '25' ? PoolType.find_by_code('50') : PoolType.find_by_code('25')
        best_mir = retrieve_entry_time_by_type( badge.get_entry_time_type_code, meeting, event_type, pool_type )
        
        # Convert timing
        if best_mir
          timing_converter = TimingCourseConverter.new( meeting.season )
          if timing_converter.is_conversion_possible?( best_mir.gender_type, best_mir.event_type )
            time_converted = pool_type.code == '25' ? 
             timing_converter.convert_time_to_long( best_mir.get_timing_instance, best_mir.gender_type, best_mir.event_type ) :
             timing_converter.convert_time_to_short( best_mir.get_timing_instance, best_mir.gender_type, best_mir.event_type )
          end
        end
      end
    end

    time_converted ? time_converted :     
     best_mir ? best_mir.get_timing_instance : nil
  end
  
  # Retrieve the appropriate entry time
  # according to the given entry type
  # Assuming that algorithm having those entry time types:
  #  M->Manual (Nothing to do)
  #  P->Personal best
  #  U->Last result
  #  G->GoggleCup standard time (current GoggleCup)
  #  A->Previous edition of same meeting
  #  
  #  In a first approach could be the reverse order of the types shown above.
  #  So if "A" but not present, use "G"
  #  If "G" but not present, use "U"
  #  If "U" but not present, use "P" (that's surely not present, so use "M")
  #  If "P" but not present, use "M"
  #  If "M" step out of my balls
  def retrieve_entry_time_by_type( entry_time_type_code, meeting, event_type, pool_type )
    best_mir = nil
    
    case entry_time_type_code
    when 'U'   # Last swam
      best_mir = get_last_mir_for_event( event_type, pool_type ) 
    when 'G'   # Goggle Cup or last swam
      best_mir = nil # TODO - Use Google cup standard
      best_mir = get_last_mir_for_event( event_type, pool_type ) if !best_mir 
    when 'A'   # Previous meeting edition (or Goggle Cup or last swam)
      best_mir = get_best_mir_for_meeting( meeting, event_type, pool_type )
      # TODO goggle cup if nil
      best_mir = get_last_mir_for_event( event_type, pool_type ) if !best_mir 
    else       # Personal best
      best_mir = get_best_mir_for_event( event_type, pool_type )
    end
    
    best_mir
  end
  #-- --------------------------------------------------------------------------
  #++
end
