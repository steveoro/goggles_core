# encoding: utf-8

=begin

= PersonalBestCollector
  - Goggles framework vers.:  4.00.439
  - author: Leega, Steve A.

 Collector strategy class for individual all time personal bests stored into
 a newly created PersonalBestCollection instance.

 Records are collected according to the filtering parameters set using the
 constructor.

=end
class PersonalBestCollector

  # Creates a new instance while setting the filtering parameters for the records
  # selection.
  #
  # === Initialization options:
  # - list: an object responding to :each, containing a list of row instances to
  #         be added to the internal collection during initialization.
  #         (These will be converted to IndividualRecord(s) and indexed by their values)
  #
  # - record_type_code: a valid RecordType.code string to categorize the collected records.
  # - record_type: a valid RecordType instance to categorize the collected records.
  # (The last two are mutually exclusive but both supported. These are required when the list
  # contains MeetingIndividualResult elements)
  #
  # === Supported filtering options:
  # When provided, any of these options are combined together and will be used
  # to filter out the results during the collection loops.
  #
  # - swimmer: a Swimmer instance
  # - team: a filtering Team instance (mutually exclusive with season_type)
  # - season_type: a filtering SeasonType instance (mutually exclusive with team, takes precedence over team)
  # - season: a filtering Season instance (this filter is ignored when looping on IndividualRecords)
  # - meeting: a Meeting instance (this filter is ignored when looping on IndividualRecords)
  #
  def initialize( swimmer, options = {} )
    raise ArgumentError.new("The swimmer parameter is not a valid instance of Swimmer!") unless swimmer.instance_of?( Swimmer )
    @swimmer      = swimmer

    # Options safety check:
    @season_type  = options[:season_type] if options[:season_type].instance_of?( SeasonType )
    @season       = options[:season] if options[:season].instance_of?( Season )
    @start_date   = options[:start_date] if options[:start_date].instance_of?( Date )
    @end_date     = options[:end_date] if options[:end_date].instance_of?( Date )

    # If the list of rows is given each element should be qualified with record type
    # In particular when the list is made from MeetingIndividualResult it's necessary
    # to specify record type intended for
    list_of_rows  = options[:list].respond_to?(:each) ? options[:list] : nil

    record_type_code = options[:record_type_code] if options[:record_type_code].instance_of?( String )
    record_type_code = options[:record_type].code if options[:record_type].instance_of?( RecordType )
    if list_of_rows && list_of_rows[0].instance_of?( MeetingIndividualResult )
      raise ArgumentError.new("Missing a valid record_type or record_type_code parameter!") unless record_type_code
    end

    @collection   = PersonalBestCollection.new( list_of_rows, record_type_code )

    # Cache the unique codes lists:
    #@events_by_pool_types = EventsByPoolType.not_relays
  end
  #-- --------------------------------------------------------------------------
  #++

  # Getter for the internal SeasonType parameter. +nil+ when not defined.
  def season_type
    @season_type
  end

  # Getter for the internal Season parameter. +nil+ when not defined.
  def season
    @season
  end

  # Getter for the internal start date parameter. +nil+ when not defined.
  def start_date
    @start_date
  end

  # Getter for the internal end date parameter. +nil+ when not defined.
  def end_date
    @end_date
  end

  # Getter for the internal list.
  def collection
    @collection
  end

  # Getter for the internal list #count method.
  def count
    @collection.count
  end

  # Clears the internal list of records.
  def clear
    @collection.clear
  end
  #-- --------------------------------------------------------------------------
  #++


  # Setter for the internal Meeting parameter. +nil+ when not defined.
  def set_start_date( start_date )
    @start_date = start_date
  end

  # Setter for the internal Meeting parameter. +nil+ when not defined.
  def set_end_date( end_date )
    @end_date = end_date
  end
  #-- --------------------------------------------------------------------------
  #++


  # Returns the internal RecordCollection instance updated with the records collected using
  # the specified parameters.
  #
  # This method works by scanning existing MeetingIndividualResult(s) on DB.
  #
  def collect_from_all_category_results_having( events_by_pool_type, record_type_code )
    mir = @swimmer.meeting_individual_results.is_valid.has_time.for_event_by_pool_type( events_by_pool_type )
    mir = mir.joins( :season ).where( ['seasons.id = ?', @season.id]) if @season
    mir = mir.joins( :season_type ).where( ['season_types.id = ?', @season_type.id]) if @season_type
    mir = mir.joins( :meeting ).where( ['(meetings.header_date >= ?) AND (meetings.header_date <= ?)', @start_date, @end_date]) if @start_date
    update_and_return_collection_with_first_results( mir, record_type_code )
  end


  # Returns the internal RecordCollection instance updated with the records collected using
  # the specified parameters.
  #
  # This method works by scanning existing MeetingIndividualResult(s) on DB.
  #
  def collect_last_results_having( events_by_pool_type, record_type_code )
    mir = @swimmer.meeting_individual_results.is_valid.has_time.for_event_by_pool_type( events_by_pool_type ).sort_by_date('DESC').limit(1)
    mir = mir.joins( :season ).where( ['seasons.id = ?', @season.id]) if @season
    mir = mir.joins( :season_type ).where( ['season_types.id = ?', @season_type.id]) if @season_type
    update_and_return_collection_with_first_results( mir, record_type_code )
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the list of allowed Events by PoolType codes
  def events_by_pool_type_list
    EventsByPoolType.not_relays
  end


  # Executes the block while passing iteratively self plus all the codes combinations
  # of PoolType(s) & EventType(s) as parameters
  # for the block -- which must have the same signature as #collect_from_records_having()
  # or #collect_from_results_having().
  #
  # This allows to loop on either one of the above methods while filling the internal
  # record collection for each possible combinatory tuple.
  #
  # This will yield a RecordCollection instance filled with all the best results
  # available for each particular combination of filtering parameters specified
  # in the constructor. As in:
  #
  #     collector.full_scan() do |this, pool_code, event_code|
  #       this.collect_from_records_having( pool_code, event_code )
  #     end
  #
  # ...Or:...
  #
  #     collector.full_scan() do |this, pool_code, event_code|
  #       this.collect_from_results_having( pool_code, event_code )
  #     end
  #
  # Please, be aware that an unfiltered full scan using #collect_from_results_having
  # may take several minutes to complete (depending on Server speed & power).
  #
  # While the latter method is painstakingly slow, it can be used to fill the entries into
  # the individual_records table. These can be later retrieved and stored on another
  # RecordCollection with the former method.
  #
  def full_scan( &block )
    self.events_by_pool_type_list.each do |events_by_pool_type|
      yield( self, events_by_pool_type ) if block_given?
    end
    @collection
  end
  #-- -------------------------------------------------------------------------
  #++


  private


  # Returns the internal collection after having added the first +limit+ results
  # among the ones specified.
  #
  # <tt>prefiltered_results</tt> is a Relation of either IndividualRecord or
  # MeetingIndividualResult instances.
  #
  def update_and_return_collection_with_first_results( prefiltered_results, record_type_code, limit = 3 )
    # Store these max first ranking results:
    # Order by time only if necessary.
    # If prefiltered_results contains only one record it's not necessary and
    # it should be not performed not to override previous sorting
    if prefiltered_results.size > 1
      first_recs = prefiltered_results.order( :minutes, :seconds, :hundreds ).limit(limit)
      if first_recs.size > 0                          # Compute the first timing result value
        first_timing_value = first_recs.first.minutes*6000 + first_recs.first.seconds*100 + first_recs.first.hundreds
        # [Steve, 20160916] Old implementation:
        # Exclude from the result all other rows that have a greater timing result (keep same ranking results)
#        first_recs.reject!{ |row| first_timing_value < (row.minutes*6000 + row.seconds*100 + row.hundreds) }
        # [Steve, 20160916] New implementation:
        first_recs = first_recs.where(["minutes*6000 + seconds*100 + hundreds <= ?", first_timing_value])
      end
    else
      first_recs = prefiltered_results
    end
    first_recs.each { |rec| @collection.add(rec, record_type_code) } # Add the first records to the collection
    @collection
  end
  #-- -------------------------------------------------------------------------
  #++
end
