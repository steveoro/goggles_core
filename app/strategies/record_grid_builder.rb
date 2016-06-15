# encoding: utf-8

=begin

= RecordGridBuilder
  - Goggles framework vers.:  4.00.509
  - author: Steve A.

 Uses a RecordCollector to allow the build-up of several HTML grid representing
 the distribution of all the records & best results collected.

 Dedicated Enumerators allow to loop by CategoryType or by EventType, given
 specific PoolType & GenderType coordinates.

=end
class RecordGridBuilder

  # Creates a new instance.
  #
  # === Params
  # - record_collector: an instance of RecordCollector (assumed to have an already full RecordCollection)
  #
  def initialize( record_collector, record_type_code = 'FOR' )
    raise ArgumentError.new("the parameter must be a RecordCollector instance") unless record_collector.instance_of?( RecordCollector )
    @collector  = record_collector
    @record_type_code = record_type_code

    @pool_types = PoolType.where{ code != '33' }   # (uses Squeel DSL syntax)
    # This will create an Hash with all the tuples made by (pool_type.id => event_type lists),
    # with each event list built using the distribution of events found inside EventsByPoolType:

    @event_types_by_pool = {}
    @pool_types.each do |pool_type|
      event_by_pool_type_ids = EventsByPoolType
        .where( pool_type_id: pool_type.id )
        .includes( :event_type )
        .where{ event_types.is_a_relay == false }
        .select( :event_type_id )
      @event_types_by_pool[ pool_type.id ] = EventType.where( id: event_by_pool_type_ids )
    end

    # TODO Refactor this mess:

    # Build the list of allowed/request CategoryType(s) by retrieving first all the
    # possible SeasonType(s) from the RecordCollector configuration.
    # We may have 3 cases:
    # - filtering by Team (more than 1 SeasonType may be available)
    # - filtering by SeasonType (just 1)
    # - no filtering (either by list addition or by swimmer filtering => more than 1 SeasonType may be available)
    season_types = if @collector.season_type
      [ @collector.season_type ]
    elsif @collector.team
      @collector.team.season_types.uniq
    else
      @collector.get_collected_season_types.values
    end
    # Get the list of Ids from all the most recent Season(s), by available SeasonType (uses Squeel DSL syntax):
    season_ids = season_types.map{ |st| Season.where{ season_type_id == st.id }.max.id }
    # Get the list of available CategoryType(s) filtered by Season#id (uses Squeel DSL syntax):
    category_types = CategoryType.is_valid.are_not_relays.is_divided.sort_by_age.where{ season_id.in season_ids }
    uniq_codes = category_types.map{ |c| c.code }.uniq
    # Filter out duplicate categories by code:
    @category_types = []
    category_types.each do |category_type|
      if uniq_codes.include?( category_type.code )
        @category_types << category_type
        uniq_codes.delete( category_type.code )
      end
    end

    # Extract acceptable gender types from the list: if the collector has been filtered
    # by swimmer, limit the grid genders to only his/hers.
    @gender_types = if @collector.swimmer
      [ @collector.swimmer.gender_type ]
    else
      GenderType.where{ code != 'X' } # (uses Squeel DSL syntax)
    end
  end
  #-- --------------------------------------------------------------------------
  #++

  # Getter for a unique text cache key associated with this instance and its internal collection.
  #
  # This will generate a different string from the one returned by #collection.cache_key
  # if the internal RecordCollector instance has been pre-filtered with a swimmer
  # instance.
  #
  # (This allows the grid builder to be initialized with a special collector created
  # from an already existing colletion of records, where the swimmer pre-filter is being
  # used just to highlight his/her results among the others, while having different
  # cache hits for pages regarding the essential same collection but highlighted in a
  # different way.)
  #
  def cache_key
    if @collector.swimmer
      # "RGB" stands for "RecordGridBuilder", to uniquely identify this type of cache key
      "RGB:#{I18n.locale.to_s}:#{@collector.swimmer.id}:#{@collector.collection.cache_key}"
    else
      "RGB:#{I18n.locale.to_s}:#{@collector.collection.cache_key}"
    end
  end

  # Getter for the internal list.
  def collection
    @collector.collection
  end

  # Getter for the internal list #count method.
  def count
    @collector.count
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the Enumerator of the allowed PoolTypes.
  #
  # Note that these are substantially different from the similar methods found
  # inside RecordCollector: these return an actual Enumerator for all the allowed
  # model instances (not just unique string codes).
  def pool_types
    @pool_types.each
  end

  # Returns the Enumerator of the allowed EventTypes.
  #
  # Note that these are substantially different from the similar methods found
  # inside RecordCollector: these return an actual Enumerator for all the allowed
  # model instances (not just unique string codes).
  def event_types( pool_type_id )
    @event_types_by_pool.has_key?(pool_type_id) ? @event_types_by_pool[pool_type_id].each : [].each
  end

  # Returns the Enumerator of the allowed CategoryTypes.
  #
  # Note that these are substantially different from the similar methods found
  # inside RecordCollector: these return an actual Enumerator for all the allowed
  # model instances (not just unique string codes).
  def category_types
    @category_types.each
  end

  # Returns the Enumerator of the allowed GenderTypes.
  #
  # Note that these are substantially different from the similar methods found
  # inside RecordCollector: these return an actual Enumerator for all the allowed
  # model instances (not just unique string codes).
  def gender_types
    @gender_types.each
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the record type the grif builder was initialized for
  #
  def get_record_type_code
    @record_type_code
  end
  #-- -------------------------------------------------------------------------
  #++
end
