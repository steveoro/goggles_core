# encoding: utf-8

=begin

= SeasonPonderatedBestsDAO

  - Goggles framework vers.:  6.111
  - author: Leega

 DAO class containing the structure for managing the overall event bests

=end
class SeasonPonderatedBestsDAO
  include SqlConvertable

  # Manage the single event best performance
  class EventPonderatedBestDAO
    # These must be initialized on creation:
    attr_reader :season, :gender_type, :category_type, :event_type, :pool_type, :max_results, :bests_to_be_ignored

    # These can be edited later on:
    attr_accessor :season_type, :best_results, :total_results
    #-- -------------------------------------------------------------------------
    #++

    # Creates a new instance.
    #
    def initialize( season, gender_type, category_type, event_type, pool_type, max_results, bests_to_be_ignored )
      @season              = season
      @season_type         = season.season_type
      @gender_type         = gender_type
      @category_type       = category_type
      @event_type          = event_type
      @pool_type           = pool_type
      @max_results         = max_results
      @bests_to_be_ignored = bests_to_be_ignored

      @total_results       = MeetingIndividualResult
                              .for_season_type( season_type )
                              .for_gender_type( gender_type )
                              .for_category_code( category_type.code )
                              .for_pool_type( pool_type )
                              .for_event_type( event_type )
                              .count

      @best_results        = self.collect_event_bests
      @ponderated_time     = self.set_ponderated_best
    end
    #-- -------------------------------------------------------------------------
    #++

    # Find the desidered number of best results for the overall meeting individual resuts
    # of the seasons with the same type of the given one
    # It colelcts exactly max_results + bests_to_be_ignored results it more are presents
    # otherwise the maximum number of results
    #
    def collect_event_bests
      # TODO
      # Limit the results to the season older than the target one

      MeetingIndividualResult
        .for_season_type( @season_type )
        .for_gender_type( @gender_type )
        .for_category_code( @category_type.code )
        .for_pool_type( @pool_type )
        .for_event_type( @event_type )
        .for_date_range( Date.new( 0 ), @season.begin_date - 1 )
        .sort_by_timing
        .limit( @bests_to_be_ignored + @max_results )

      # TODO
      # Verify where for_category_type scope is used!!!
    end

    # Calculate and set the ponderated best time swam
    # The ponderated best is the everage time calculated on the bests @max_results
    # excluding the first bests_to_be_ignored.
    # If the total amount of meeting individual results is less than
    # bests_to_be_ignored + max_results, all the reuslts will be considered
    #
    def set_ponderated_best
      total_time        = 0
      result_considered = 0
      result_collected  = @best_results.count
      everage_time      = 0

      # If no results, no action performed
      if result_collected > 0
        # If total best results collected >= (bests_to_be_ignored + max_results)
        # excludes first @bests_to_be_ignored results
        if result_collected >= ( @bests_to_be_ignored + @max_results )
          @best_results.each_with_index do |mir, index|
            if index >= @bests_to_be_ignored
              total_time += mir.get_timing_instance.to_hundreds
            end
          end
          result_considered = @max_results
        else
          @best_results.each do |mir|
            total_time += mir.get_timing_instance.to_hundreds
          end
          result_considered = result_collected
        end
        everage_time = (total_time / result_considered).round(0)
      end
      @ponderated_time = Timing.new(everage_time)
    end

    # Gets the ponderated best time
    #
    def get_ponderated_best
      # Maybe better trace if no results collected
      #@best_results.exists? ? Timing.new() : @ponderated_time
      @ponderated_time
    end

    # Gets the max results number to be considered
    #
    def get_max_results
      @max_results
    end

    # Gets the number of top best results to be ignored
    #
    def get_bests_to_be_ignored
      @bests_to_be_ignored
    end
  end

  # These must be initialized on creation:
  attr_reader :season, :max_results, :bests_to_be_ignored

  # These can be edited later on:
  attr_accessor :event_types, :categories, :single_events, :insert_events, :update_events
  #-- -------------------------------------------------------------------------
  #++

  # Creates a new instance for a given season
  # If no additional parameters set assumes 10 best results and 1 best to be ignored,
  # that is the FIN standard
  #
  def initialize( season, max_results = 10, bests_to_be_ignored = 1)
    unless season && season.instance_of?( Season )
      raise ArgumentError.new("Seasonal ponderated best calculation per event needs a season")
    end
    @season              = season
    @max_results         = max_results
    @bests_to_be_ignored = bests_to_be_ignored
    @event_types         = self.find_season_type_events
    @categories          = self.find_season_type_category_codes
    @single_events       = []
    @insert_events       = []
    @update_events       = []
  end
  #-- -------------------------------------------------------------------------
  #++

  # Scan for different gender, category and event (pool) to be considered
  # For the season type of the target season
  # For each item found i creates an element in single_events
  #
  def scan_for_gender_category_and_event
    # Scan genders, than Category, than events, than pool types
    # An element occurs if at least one meeting individual result is present
    GenderType.individual_only.each do |gender_type|
      PoolType.only_for_meetings.each do |pool_type|
        @event_types.each do |event_type|
          @categories.each do |category_code|
            # If at least on meeting individual result add an element
            if MeetingIndividualResult
              .for_season_type( @season.season_type )
              .for_gender_type( gender_type )
              .for_category_code( category_code )
              .for_pool_type( pool_type )
              .for_event_type( event_type )
              exists?
              @single_events << SeasonPonderatedBestsDAO::EventPonderatedBestDAO.new(
                @season,
                gender_type,
                CategoryType.for_season( @season ).find_by_code(category_code),
                event_type,
                pool_type,
                @max_results,
                @bests_to_be_ignored )
            end
          end
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Prepare collectyed data to DB store
  # Splits the collected data into insert and update arrays
  # for DB storage
  #
  def prepare_to_store
    # Check if data already collected and collect if needed
    scan_for_gender_category_and_event if @single_events.count == 0
    @single_events.each do |event|
      # Check if time standard already exists and create or update
      if TimeStandard.exists?(
          season_id:        @season.id,
          gender_type_id:   event.gender_type.id,
          category_type_id: event.category_type.id,
          pool_type_id:     event.pool_type.id,
          event_type_id:    event.event_type.id
      )
        # Exists. Needs update
        @update_events << event
      else
        # Doesn't exist. Needs insert
        @insert_events << event
      end
    end
    @update_events.count + @insert_events.count == @single_events.count
  end
  #-- -------------------------------------------------------------------------
  #++

  # Find different catgeories of the season type
  # The categories are those that have at least one meeting result
  # in a meeting of the season type and are still present in the target season
  #
  def find_season_type_category_codes()
    CategoryType.are_not_relays.is_divided.for_season_type(@season.season_type)
      .for_season(@season)
      .sort_by_age
      .pluck(:code).uniq
  end
  #-- -------------------------------------------------------------------------
  #++

  # Find different events of the season type
  # The events are those that have at least one meeting result
  # in a meeting of the season type
  #
  def find_season_type_events()
    EventType.are_not_relays.for_season_type( @season.season_type )
      .sort_by_style.distinct
  end
  #-- -------------------------------------------------------------------------
  #++

  # Create a CSV file (; delimited) with season ponderated calculation data
  #
  def to_csv( csv_file_name = 'ponderated_season_' + @season.id.to_s )
    # Check if data already collected and collect if needed
    scan_for_gender_category_and_event if @single_events.count == 0

    rows = []

    File.open( csv_file_name + '.csv', 'w' ) do |f|
      titles = ['gender',  'category', 'event', 'pool', 'total_results', 'ponderated best', 'best results']
      rows << titles.join(';')

      @single_events.each do |event|
        event_row = ''
        event_row += event.gender_type.code + ';'
        event_row += event.category_type.code + ';'
        event_row += event.event_type.code + ';'
        event_row += event.pool_type.code + ';'
        event_row += event.total_results.to_s + ';'
        event_row += event.get_ponderated_best.to_s + ';'
        event_row += event.best_results.map{ |mir| mir.get_timing.to_s }.join(';')
        rows << event_row
      end
      f.puts rows.map{ |row| row }
    end
  end

  # Store collected data to the db structure of standard time
  #
  def to_db!()
    # Check if data already collected and collect if needed
    prepare_to_store if @insert_events.count == 0 && @update_events.count == 0

    create_sql_diff_header( "Season ponderated best for season #{@season.get_full_name}" )

    # Store collected data into time_standard structure for event not already presents
    @insert_events.each do |event|
      ponderated_time                = event.get_ponderated_best
      time_standard                  = TimeStandard.new()
      time_standard.season_id        = @season.id
      time_standard.gender_type_id   = event.gender_type.id
      time_standard.category_type_id = event.category_type.id
      time_standard.pool_type_id     = event.pool_type.id
      time_standard.event_type_id    = event.event_type.id
      time_standard.minutes          = ponderated_time.minutes
      time_standard.seconds          = ponderated_time.seconds
      time_standard.hundreds         = ponderated_time.hundreds
      time_standard.save
      time_standard.reload
      comment = "#{event.pool_type.code} #{event.gender_type.code}-#{event.category_type.code} #{event.event_type.code}: #{event.get_ponderated_best.to_s}"
      sql_diff_text_log << to_sql_insert( time_standard, false, "\r\n", comment )
    end

    # Store collected data into time_standard structure for event already presents
    sql_fields = {}
    @update_events.each do |event|
      ponderated_time        = event.get_ponderated_best
      time_standard          = TimeStandard.where(
        season_id:        @season.id,
        gender_type_id:   event.gender_type.id,
        category_type_id: event.category_type.id,
        pool_type_id:     event.pool_type.id,
        event_type_id:    event.event_type.id
      ).first
      time_standard.minutes  = ponderated_time.minutes
      time_standard.seconds  = ponderated_time.seconds
      time_standard.hundreds = ponderated_time.hundreds
      time_standard.save
      sql_fields['minutes']  = ponderated_time.minutes
      sql_fields['seconds']  = ponderated_time.seconds
      sql_fields['hundreds'] = ponderated_time.hundreds
      comment = "#{event.pool_type.code} #{event.gender_type.code}-#{event.category_type.code} #{event.event_type.code}: #{event.get_ponderated_best.to_s}"
      sql_diff_text_log << to_sql_update( time_standard, false, sql_fields, "\r\n", comment )
    end

    create_sql_diff_footer( "Season ponderated best for season #{@season.get_full_name} collected" )
  end
end
