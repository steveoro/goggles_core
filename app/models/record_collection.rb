# rubocop:disable Style/FrozenStringLiteralComment

#
# = RecordCollection
#   - Goggles framework vers.:  4.00.439
#   - author: Steve A.
#
#  Wrapper class to store and manage a collection of individual results from meetings
#  or individual records.
#
#  The internal list contains only instances of IndividualRecord.
#  When a new element to be added is given, it is also converted to an IndividualRecord
#  instance before being appended to the others.
#
class RecordCollection

  include Enumerable

  # Creates a new instance. Adds directly the first member, if given.
  #
  # The given parameter can either be a single instance or a list (responding to :each)
  # of MeetingIndividualResult or IndividualRecord rows.
  #
  def initialize(individual_result_or_record = nil, record_type_code = nil)
    @list = {}
    @cached_ids = []
    @max_updated_at = 0
    initial_record_type_code = record_type_code || chose_record_type_code(individual_result_or_record)

    if individual_result_or_record.respond_to?(:each)
      individual_result_or_record.each { |row| add(row, initial_record_type_code) }
    elsif individual_result_or_record
      add(individual_result_or_record, initial_record_type_code)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Implements the basic Enumerable interface.
  # It behaves like Hash#each( key, value )
  #
  def each(&block)
    @list.each { |key, value| block.call(key, value) }
  end

  # Clears the internal list of records.
  def clear
    @list.clear
    @cached_ids = []
    @max_updated_at = 0
    self
  end

  # Removes from the internal list of records the specified (key: element) pair
  # using an already existing encoded key.
  def delete_with_key(encoded_key)
    row = @list[encoded_key]
    @cached_ids.delete(row.id) if row&.id
    @max_updated_at = 0
    @list.delete(encoded_key) ? true : false
  end

  # Removes from the internal list of records the specified element.
  def delete(individual_result_or_record, record_type_code)
    if individual_result_or_record
      encoded_key = encode_key_from_record(individual_result_or_record, record_type_code)
      delete_with_key(encoded_key)
    else
      false
    end
  end

  # Adds a new member returning its encoded key.
  #
  # Allows also a second tie-in record to be added with a special key, if the
  # result has the same timing (with same pool, event, category & gender) but
  # is from a different swimmer.
  #
  def add(individual_result_or_record, record_type_code)
    if individual_result_or_record
      encoded_key, record_candidate = get_record_candidate_and_key(individual_result_or_record, record_type_code)
      existing_record = @list[encoded_key]
      if existing_record && # Same record w/ different swimmer?
         record_candidate &&
         (existing_record.swimmer_id != record_candidate.swimmer_id) &&
         (existing_record.minutes  == record_candidate.minutes) &&
         (existing_record.seconds  == record_candidate.seconds) &&
         (existing_record.hundreds == record_candidate.hundreds)
        # Add a tie-in w/ special key ending in 'b'
        @list[encoded_key << 'b'] = record_candidate
      else # Add a normal record:
        @list[encoded_key] = record_candidate
      end
      encoded_key
    end
  end

  alias << add
  alias size count
  #-- -------------------------------------------------------------------------
  #++

  # Returns the IndividualRecord for the specified parameters or nil when not found.
  #
  # When specified as +true+, the <tt>is_tie_in</tt> parameter allows to retrieve not
  # the first record, but its tie-in (if any).
  #
  def get_record_for(record_type_code, pool_type_code, event_type_code, category_type_code, gender_type_code, is_tie_in = false)
    encoded_key = encode_key_from_codes(record_type_code, pool_type_code, event_type_code, category_type_code, gender_type_code)
    @list[is_tie_in ? encoded_key << 'b' : encoded_key]
  end

  # Returns +true+ if there is an IndividualRecord for the specified parameters or +false+ when not found.
  #
  def has_record_for(record_type_code, pool_type_code, event_type_code, category_type_code, gender_type_code)
    !get_record_for(record_type_code, pool_type_code, event_type_code, category_type_code, gender_type_code).nil?
  end

  # Returns +true+ if there are any IndividualRecord instances for the specified parameters
  # or +false+ when none are found.
  #
  # This is equivalent to test if there's any value in a row of any of the records "4x grid" view
  # (where each one of the 4 grid enlists categories on columns and events on rows).
  #
  def has_any_record_for(record_type_code, pool_type_code, event_type_code, gender_type_code)
    @list.any? { |key, _row| key =~ /#{record_type_code}\-#{pool_type_code}\-#{event_type_code}\-.{3,}\-#{gender_type_code}/ }
  end

  # Getter for the IndividualRecord for the specified key. Returns nil when not found.
  #
  def get_record_with_key(encoded_key)
    @list[encoded_key]
  end

  # Returns +true+ if there is a same-ranking (tie-in) record match for the specified parameters or +false+ when not found.
  #
  def has_tie_in_for(record_type_code, pool_type_code, event_type_code, category_type_code, gender_type_code)
    !get_record_for(record_type_code, pool_type_code, event_type_code, category_type_code, gender_type_code, true).nil?
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the encoded string key used to store the specified IndividualRecord record.
  #
  def encode_key_from_codes(record_type_code, pool_type_code, event_type_code, category_type_code, gender_type_code)
    "#{record_type_code}-#{pool_type_code}-#{event_type_code}-#{category_type_code}-#{gender_type_code}"
  end

  # Returns the encoded string key used to store the specified IndividualRecord record.
  #
  def encode_key_from_record(individual_result_or_record, record_type_code)
    if individual_result_or_record
      record_candidate = get_record_candidate(individual_result_or_record, record_type_code)
      encode_key_from_codes(
        record_type_code,
        record_candidate.pool_type     ? record_candidate.pool_type.code : '?',
        record_candidate.event_type    ? record_candidate.event_type.code : '?',
        record_candidate.category_type ? record_candidate.category_type.code : '?',
        record_candidate.gender_type   ? record_candidate.gender_type.code : '?'
      )
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Getter for a string key viable for use as a cache key for fragments involving
  # the rending of the current rows stored in this collection.
  #
  def cache_key
    @cached_ids.compact.join('-') + ":#{@max_updated_at}"
  end

  # Returns a copy of the internal list of records.
  def to_hash
    @list.dup
  end
  #-- -------------------------------------------------------------------------
  #++

  private

  # Returns a valid record candidate as an IndividualRecord instance and his encoded
  # key as a two-item array [encoded_key, record_candidate], while updating
  # the internal cache key list.
  #
  def get_record_candidate_and_key(individual_result_or_record, record_type_code)
    if individual_result_or_record
      record_candidate = get_record_candidate(individual_result_or_record, record_type_code)
      [
        encode_key_from_codes(
          record_type_code,
          record_candidate.pool_type     ? record_candidate.pool_type.code : '?',
          record_candidate.event_type    ? record_candidate.event_type.code : '?',
          record_candidate.category_type ? record_candidate.category_type.code : '?',
          record_candidate.gender_type   ? record_candidate.gender_type.code : '?'
        ),
        record_candidate
      ]
    else
      [nil, nil]
    end
  end

  # Returns a valid record candidate as an IndividualRecord instance, while updating
  # the internal cache key list.
  #
  # It assumes individual_result_or_record is not +nil+.
  #
  def get_record_candidate(individual_result_or_record, record_type_code)
    if individual_result_or_record.respond_to?(:id) && individual_result_or_record.respond_to?(:updated_at)
      @cached_ids << individual_result_or_record.id unless @cached_ids.member?(individual_result_or_record.id)
      @max_updated_at = individual_result_or_record.updated_at.to_i if @max_updated_at < individual_result_or_record.updated_at.to_i
    end
    if individual_result_or_record.instance_of?(MeetingIndividualResult)
      IndividualRecord.new.from_individual_result(
        individual_result_or_record,
        RecordType.find_by(code: record_type_code)
      )
    else
      individual_result_or_record
    end
  end

  # Choses which record type should used for the record collection.
  # Defaults to 'FOR' for undetermined rows.
  #
  # Keep in mind that the only place where record_type could be nil is
  # in the default constructor.
  #
  def chose_record_type_code(possible_list_or_row_of_result_or_record)
    single_row = if possible_list_or_row_of_result_or_record.respond_to?(:each)
      possible_list_or_row_of_result_or_record.first
    else
      possible_list_or_row_of_result_or_record
    end
    if single_row.instance_of?(IndividualRecord)
      single_row.record_type.code
    else
      'FOR'
    end
  end
  #-- -------------------------------------------------------------------------
  #++

end
# rubocop:enable Style/FrozenStringLiteralComment
