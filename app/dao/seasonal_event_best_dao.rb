# encoding: utf-8

=begin

= SeasonalEventBestDAO

  - Goggles framework vers.:  4.00.777
  - author: Leega

 DAO class containing the structure for managing the event seasonal best

=end
class SeasonalEventBestDAO

  # Manage the single event best performance
  class SingleEventBestDAO
    # These must be initialized on creation:
    attr_reader :gender_type, :category_type, :event_type

    # These can be edited later on:
    attr_accessor :gender_type, :category_type, :event_type, :time_swam, :is_converted, :total_events, :events_swam
    #-- -------------------------------------------------------------------------
    #++

    # Creates a new instance from a meeting_individual_result.
    #
    def initialize( gender_type, category_type, event_type, time_swam, is_converted, total_events, events_swam )
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
  attr_accessor :season, :event_bests, :timing_converter
  #-- -------------------------------------------------------------------------
  #++

  # Creates a new instance from a meeting_individual_result.
  #
  def initialize( season )
    unless season && season.instance_of?( Season )
      raise ArgumentError.new("Seasonal ranking per event needs a season")
    end
    @season           = season
    @event_bests      = []
    @timing_converter = TimingCourseConverter.new( season )

    scan_for_gender_category_and_event
  end
  #-- -------------------------------------------------------------------------
  #++

  # Calculate the event best time for given gender and category
  # Find the best event time for 25 meters and 50 meters
  # Compare the 50 meters converted in 25 meters anc choose the best
  #
  # [FIXME, Steve] WHAT DOES IT RETURN? WHAT'S ITS DEFAULT?
  # nil or new SingleEventBestDAO? Why can't update self?
  #
  def calculate_event_best( gender_type, category_type, event_type, event_total, event_swam )
    # If event_type hasn't 50 meters event no conversion needed
    is_converted = false
    best_mir = @season.meeting_individual_results
      .is_valid
      .for_gender_type(gender_type)
      .for_category_type(category_type)
      .for_event_type(event_type)
      .sort_by_timing
      .first

    if best_mir
      time_swam = best_mir.get_timing_instance

      # If best_mir is in 50 metes pool should convert and stop
      if best_mir.pool_type.length_in_meters == 50
        is_converted = true
        time_swam = @timing_converter.convert_time_to_short( time_swam, gender_type, event_type )
      # If event type has 50 meters event needs to convert and to compare
      else
        if @timing_converter.is_conversion_possible?( gender_type, event_type )
          # Find best event swam in 50 meters
          best_mir_50 = @season.meeting_individual_results
            .is_valid
            .for_gender_type(gender_type)
            .for_category_type(category_type)
            .for_event_type(event_type)
            .for_pool_type( PoolType.find_by_code( '50' ) )
            .sort_by_timing
            .first

          if best_mir_50
            time_swam_50 = best_mir_50.get_timing_instance
            time_swam_50 = @timing_converter.convert_time_to_short( time_swam_50, gender_type, event_type )
            if time_swam_50.to_hundreds < time_swam.to_hundreds
              time_swam = time_swam_50
              is_converted = true
            end
          end
        end
      end

      SingleEventBestDAO.new( gender_type, category_type, event_type, time_swam, is_converted, event_total, event_swam )
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Calculate the event best time for all genders and categories
  #
  # [FIXME, Steve] WHAT DOES IT RETURN? WHAT'S ITS DEFAULT?
  #
  def scan_for_gender_category_and_event
    @season.event_types.are_not_relays.uniq.sort_by_style.each do |event_type|
      event_total = @season.event_types.where(['event_types.code = ?', event_type.code]).count
      event_swam  = @season.event_types.where(['event_types.code = ? and meetings.are_results_acquired', event_type.code]).count
      if event_swam > 0
        GenderType.individual_only.sort_by_courtesy.each do |gender_type|
          @season.category_types.are_not_relays.sort_by_age.each do |category_type|
            if @season.meeting_individual_results.is_valid.for_gender_type(gender_type).for_category_type(category_type).for_event_type(event_type).count > 0
              set_best_for_gender_category_and_event( gender_type, category_type, event_type, event_total, event_swam )
            end
          end
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
  def set_best_for_gender_category_and_event( gender_type, category_type, event_type, event_total, event_swam )
    @event_bests << calculate_event_best( gender_type, category_type, event_type, event_total, event_swam )
  end
  #-- -------------------------------------------------------------------------
  #++

  # Get the best event time for gender and category
  #
  # [FIXME, Steve] WHAT DOES IT RETURN? WHAT'S ITS DEFAULT?
  #
  def get_best_for_gender_category_and_event( gender_type, category_type, event_type )
    @event_bests.select{|element| element.gender_type == gender_type and element.category_type == category_type and element.event_type == event_type }.first
  end
  #-- -------------------------------------------------------------------------
  #++
end
