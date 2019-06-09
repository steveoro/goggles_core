# frozen_string_literal: true

#
# = SeasonalEventBestDAO
#
#   - Goggles framework vers.:  6.111
#   - author: Leega
#
#  DAO class containing the structure for managing the event seasonal best
#
class SeasonalEventBestDAO

  # Manage the single event best performance
  class SingleEventBestDAO

    # These must be initialized on creation:
    attr_reader :gender_type, :category_type, :event_type

    # These can be edited later on:
    attr_accessor :time_swam, :is_converted, :total_events, :events_swam
    #-- -------------------------------------------------------------------------
    #++

    # Creates a new instance from a meeting_individual_result.
    #
    def initialize(gender_type, category_type, event_type, time_swam, is_converted, total_events, events_swam)
      @gender_type   = gender_type
      @category_type = category_type
      @event_type    = event_type
      @time_swam     = time_swam
      @is_converted  = is_converted
      @total_events  = total_events
      @events_swam   = events_swam
    end
    #-- -------------------------------------------------------------------------
    #++

  end

  # These must be initialized on creation:
  attr_reader :season

  # These can be edited later on:
  attr_accessor :event_bests, :timing_converter
  #-- -------------------------------------------------------------------------
  #++

  # Creates a new instance from a meeting_individual_result.
  #
  def initialize(season)
    raise ArgumentError, 'Seasonal ranking per event needs a season' unless season&.instance_of?(Season)

    @season           = season
    @event_bests      = []
    @timing_converter = TimingCourseConverter.new(season)

    scan_for_gender_category_and_event
  end
  #-- -------------------------------------------------------------------------
  #++

  # Computes the event best timing for a given gender and category.
  #
  # The method finds the best timing associated for the same event in both short-course (25 m.)
  # and long-course (50m.) events.
  #
  # It compares all best 50m. & 25 m. results found, converting all long-course results
  # into their equivalent shor-course counterparts and chooses the best one.
  #
  # === Returns:
  #
  # A SingleEventBestDAO instance, for the event converted as a short-course event
  #  (pool type: 25m.)
  # Typically, the result should never be nil.
  #
  def calculate_event_best(gender_type, category_type, event_type, event_total, event_swam)
    # DEBUG
    #    puts "\r\n=> #calculate_event_best:"
    #    puts "- gender: #{gender_type.inspect}"
    #    puts "- category: #{category_type.inspect}"
    #    puts "- event: #{event_type.inspect}"
    #    puts "- total_events: #{event_total}, events_swam: #{event_swam}"

    # If event_type doesn't refer to a 50-meters event, no conversion is needed
    is_converted = false

    best_mir = MeetingIndividualResult.is_valid
                                      .joins(:meeting_program, :meeting_event, :meeting_session, :meeting)
                                      .includes(:meeting_program, :meeting_event, :meeting)
                                      .where('meetings.season_id = ?', @season.id)
                                      .where('meeting_programs.gender_type_id = ?', gender_type.id)
                                      .where('meeting_programs.category_type_id = ?', category_type.id)
                                      .where('meeting_events.event_type_id = ?', event_type.id)
                                      .sort_by_timing
                                      .first
    # [Steve, 20180612] Previous unoptimized version:
    #
    # @season.meeting_individual_results
    #   .is_valid
    #   .for_gender_type(gender_type)
    #   .for_category_type(category_type)
    #   .for_event_type(event_type)
    #   .sort_by_timing
    #   .first

    if best_mir
      # DEBUG
      #      puts "\r\nbest_mir found! => #{ best_mir.inspect }"
      time_swam = best_mir.get_timing_instance

      # If best_mir refers to a 50 metres pool, it typically doesn't need any additional checks
      # (simply because a long-course timing usually takes a little longer than a short-course one),
      # thus we'll just convert it to short-course timing and we are done:
      if best_mir.pool_type.length_in_meters == 50
        # DEBUG
        #        puts "best_mir pool_type = 50"
        is_converted = true
        time_swam = @timing_converter.convert_time_to_short(time_swam, gender_type, event_type)

      # If the best MIR found was referring to a short-course event and the event
      # allows conversion, then we seek if there's a long-course event with an apparent
      # "worst" timing (since long-course events take usually more time).
      # If we find one, we convert it and, if it's really better than the original
      # short-course result found, then we use it to build up the DAO instance.
      else
        # DEBUG
        #        puts "best_mir pool_type != 50"
        if @timing_converter.is_conversion_possible?(gender_type, event_type)
          #          puts "conversion possible!"

          # Find a possibly better event swam in 50 meters (that, without conversion,
          # may have slipped past the initial query above as apparently "worse"):
          best_mir_50 = MeetingIndividualResult.is_valid
                                               .joins(:meeting_program, :meeting_event, :meeting_session, :meeting)
                                               .includes(:meeting_program, :meeting_event, :meeting)
                                               .where('meetings.season_id = ?', @season.id)
                                               .where('meeting_programs.pool_type_id = ?', PoolType::MT50_ID)
                                               .where('meeting_programs.gender_type_id = ?', gender_type.id)
                                               .where('meeting_programs.category_type_id = ?', category_type.id)
                                               .where('meeting_events.event_type_id = ?', event_type.id)
                                               .sort_by_timing
                                               .first
          # [Steve, 20180612] Previous unoptimized version:
          #
          # @season.meeting_individual_results
          #  .is_valid
          #  .for_gender_type(gender_type)
          #  .for_category_type(category_type)
          #  .for_event_type(event_type)
          #  .for_pool_type( PoolType.find_by_code( '50' ) )
          #  .sort_by_timing
          #  .first

          if best_mir_50
            # DEBUG
            #            puts "best_mir_50 found!"
            time_swam_50 = best_mir_50.get_timing_instance
            time_swam_50 = @timing_converter.convert_time_to_short(time_swam_50, gender_type, event_type)
            if time_swam_50.to_hundreds < time_swam.to_hundreds
              time_swam = time_swam_50
              is_converted = true
            end
          end
        end
      end

      # DEBUG
      #      puts "creating new SingleEventBestDAO..."
      SingleEventBestDAO.new(gender_type, category_type, event_type, time_swam, is_converted, event_total, event_swam)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Calculate the event best time for all genders and categories
  #
  # [FIXME, Steve] WHAT DOES IT RETURN? WHAT'S ITS DEFAULT?
  #
  def scan_for_gender_category_and_event
    EventType.are_not_relays.for_season(@season.id).distinct.sort_by_style.each do |event_type|
      event_total = EventType.for_season(@season.id).where(code: event_type.code).count
      event_swam  = EventType.for_season(@season.id).where(code: '50SL', "meetings.are_results_acquired": true).count
      next unless event_swam > 0

      GenderType.individual_only.sort_by_courtesy.each do |gender_type|
        @season.category_types.are_not_relays.sort_by_age.each do |category_type|
          next unless @season.meeting_individual_results.is_valid
                             .for_gender_type(gender_type)
                             .for_category_type(category_type)
                             .for_event_type(event_type).exists?

          set_best_for_gender_category_and_event(gender_type, category_type, event_type, event_total, event_swam)
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Set the best event time given gender and category
  #
  # [FIXME, Steve] WHAT DOES IT RETURN? WHAT'S ITS DEFAULT?
  #
  def set_best_for_gender_category_and_event(gender_type, category_type, event_type, event_total, event_swam)
    @event_bests << calculate_event_best(gender_type, category_type, event_type, event_total, event_swam)
  end
  #-- -------------------------------------------------------------------------
  #++

  # Get the best event time for gender and category
  #
  # [FIXME, Steve] WHAT DOES IT RETURN? WHAT'S ITS DEFAULT?
  #
  def get_best_for_gender_category_and_event(gender_type, category_type, event_type)
    @event_bests.select do |element|
      (element.gender_type == gender_type) && (element.category_type == category_type) &&
      (element.event_type == event_type)
    end.first
  end
  #-- -------------------------------------------------------------------------
  #++

end
