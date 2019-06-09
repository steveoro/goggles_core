# frozen_string_literal: true

#
# = PersonalBestGridBuilder
#   - Goggles framework vers.:  4.00.420.20140807
#   - author: Leega (copiator...)
#
#  Uses a RecordCollector to allow the build-up of several HTML grid representing
#  the distribution of all the records & best results collected.
#
#  Dedicated Enumerators allow to loop by EventType, given
#  specific PoolType coordinates.
#
class PersonalBestGridBuilder

  # Creates a new instance.
  #
  # === Params
  # - record_collector: an instance of RecordCollector (assumed to have an already full RecordCollection)
  #
  def initialize(personal_best_collector)
    raise ArgumentError, 'the parameter must be a PersonalBestCollector instance' unless personal_best_collector.instance_of?(PersonalBestCollector)

    @collector = personal_best_collector

    # Defines record types handled by personal best grid
    @record_types = RecordType.for_swimmers

    # Retrieves pool type suitable for meetings
    # Leega: Maybe should be better to determinate pool types from EventsByPoolType
    @pool_types = PoolType.only_for_meetings
  end
  #-- --------------------------------------------------------------------------
  #++

  # Getter for the internal list.
  def collection
    @collector.collection
  end

  # Getter for the internal list #count method.
  def count
    @collector.count
  end

  # Getter for the internal list #clear method.
  def clear
    @collector.clear
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the Enumerator of the handled record types.
  #
  def record_types
    @record_types.each
  end

  # Returns the Enumerator of the allowed PoolTypes.
  #
  # Note that these are substantially different from the similar methods found
  # inside PersonalBestCollector: these return an actual Enumerator for all the allowed
  # model instances (not just unique string codes).
  def pool_types
    @pool_types.each
  end

  # Returns the Enumerator of the allowed EventTypes.
  #
  # Note that these are substantially different from the similar methods found
  # inside PersonalBestCollector: these return an actual Enumerator for all the allowed
  # model instances (not just unique string codes).
  def event_types(pool_type_id)
    PoolType.find(pool_type_id).event_types.each
  end
  #-- -------------------------------------------------------------------------
  #++

end
