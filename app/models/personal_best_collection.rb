# encoding: utf-8

=begin

= PersonalBestCollection
  - Goggles framework vers.:  4.00.439
  - author: Leega, Steve A.

 Wrapper class to store and manage a collection of individual results from meetings.

 The internal list contains only instances of IndividualRecord.
 When a new element to be added is given, it is also converted to an IndividualRecord
 instance before being appended to the others.

=end
class PersonalBestCollection
  include Enumerable

  # Creates a new instance. Adds directly the first member, if given.
  #
  # The given parameter can either be a single instance or a list (responding to :each)
  # of MeetingIndividualResult or IndividualRecord rows.
  # The record_type parameter can be safely skipped if the main parameter is
  # an instance of IndividualRecord.
  #
  def initialize( individual_result_or_record = nil, record_type_code = nil )
    @list = {}
    initial_record_type_code = record_type_code || chose_record_type_code( individual_result_or_record )

    if individual_result_or_record.respond_to?(:each)
      individual_result_or_record.each { |row| add(row, initial_record_type_code) }
    elsif individual_result_or_record
      add( individual_result_or_record, initial_record_type_code )
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Implements the basic Enumerable interface.
  # It behaves like Hash#each( key, value )
  #
  def each( &block )
    @list.each{ | key, value | block.call( key, value ) }
  end

  # Clears the internal list of records.
  def clear()
    @list.clear
    self
  end

  # Removes from the internal list of records the specified (key: element) pair
  # using an already existing encoded key.
  def delete_with_key( encoded_key )
    row = @list[encoded_key]
    @list.delete( encoded_key ) ? true : false
  end

  # Removes from the internal list of records the specified element.
  def delete( individual_result_or_record, record_type_code )
    if individual_result_or_record
      encoded_key = encode_key_from_record( individual_result_or_record, record_type_code )
      delete_with_key( encoded_key )
    else
      false
    end
  end

  # Adds a new member returning its encoded key.
  def add( individual_result_or_record, record_type_code )
    if individual_result_or_record
      encoded_key, record_candidate = get_record_candidate_and_key( individual_result_or_record, record_type_code )
      existing_record = @list[ encoded_key ]
      if ( existing_record &&                       # Same record w/ different swimmer?
           record_candidate &&
           (existing_record.swimmer_id != record_candidate.swimmer_id) &&
           (existing_record.minutes  == record_candidate.minutes) &&
           (existing_record.seconds  == record_candidate.seconds) &&
           (existing_record.hundreds == record_candidate.hundreds)
         )                                          # Add a tie-in w/ special key ending in 'b'
        @list[ encoded_key << 'b' ] = record_candidate
      else                                          # Add a normal record:
        @list[ encoded_key ] = record_candidate
      end
      encoded_key
    else
      nil
    end
  end

  alias :<< :add
  alias :size :count
  #-- -------------------------------------------------------------------------
  #++

  # Returns the IndividualRecord for the specified parameters or nil when not found.
  #
  # When specified as +true+, the <tt>is_tie_in</tt> parameter allows to retrieve not
  # the first record, but its tie-in (if any).
  #
  def get_record_for( record_type_code, pool_type_code, event_type_code, is_tie_in = false )
    encoded_key = encode_key_from_codes( record_type_code, pool_type_code, event_type_code )
    @list[ is_tie_in ? encoded_key << 'b' : encoded_key ]
  end

  # Returns +true+ if there is an IndividualRecord for the specified parameters or +false+ when not found.
  #
  def has_record_for( record_type_code, pool_type_code, event_type_code )
    ! get_record_for( record_type_code, pool_type_code, event_type_code ).nil?
  end

  # Returns +true+ if there is an IndividualRecord for the specified parameters or +false+ when not found.
  # Doesn't consider the record type
  #
  def has_any_record_for( pool_type_code, event_type_code )
    @list.any? { |key, row| key =~ /#{pool_type_code}\-#{event_type_code}/ }
  end

  # Getter for the IndividualRecord for the specified key. Returns nil when not found.
  #
  def get_record_with_key( encoded_key )
    @list[ encoded_key ]
  end

  # Returns +true+ if there is a same-ranking (tie-in) record match for the specified parameters or +false+ when not found.
  #
  def has_tie_in_for( record_type_code, pool_type_code, event_type_code, category_type_code, gender_type_code )
    ! get_record_for( record_type_code, pool_type_code, event_type_code, category_type_code, gender_type_code, true ).nil?
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the encoded string key used to store the specified IndividualRecord record.
  #
  def encode_key_from_codes( record_type_code, pool_type_code, event_type_code )
    "#{record_type_code}-#{pool_type_code}-#{event_type_code}"
  end


  # Returns the encoded string key used to store the specified IndividualRecord record.
  #
  # The record_type_code parameter can be safely skipped if the main parameter is
  # an instance of IndividualRecord.
  #
  def encode_key_from_record( individual_result_or_record, record_type_code )
    if individual_result_or_record
      record_candidate = get_record_candidate( individual_result_or_record, record_type_code )
      encode_key_from_codes(
        record_type_code,
        individual_result_or_record.pool_type   ? individual_result_or_record.pool_type.code   : '?',
        individual_result_or_record.event_type  ? individual_result_or_record.event_type.code  : '?'
      )
    else
      nil
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns a copy of the internal list of records.
  def to_hash()
    @list.dup
  end
  #-- -------------------------------------------------------------------------
  #++


  private


  # Returns a valid record candidate as an IndividualRecord instance and his encoded
  # key as a two-item array [encoded_key, record_candidate].
  #
  def get_record_candidate_and_key( individual_result_or_record, record_type_code )
    if individual_result_or_record
      record_candidate = get_record_candidate( individual_result_or_record, record_type_code )
      [
        encode_key_from_codes(
          record_type_code,
          individual_result_or_record.pool_type  ? individual_result_or_record.pool_type.code  : '?',
          individual_result_or_record.event_type ? individual_result_or_record.event_type.code : '?'
        ),
        record_candidate
      ]
    else
      [nil, nil]
    end
  end


  # Returns a valid record candidate as an IndividualRecord instance.
  # It assumes individual_result_or_record is not +nil+.
  #
  def get_record_candidate( individual_result_or_record, record_type_code )
    if individual_result_or_record.instance_of?( MeetingIndividualResult )
      IndividualRecord.new.from_individual_result(
        individual_result_or_record,
        RecordType.find_by_code( record_type_code )
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
  def chose_record_type_code( possible_list_or_row_of_result_or_record )
    single_row = if possible_list_or_row_of_result_or_record.respond_to?(:each)
      possible_list_or_row_of_result_or_record.first
    else
      possible_list_or_row_of_result_or_record
    end
    if single_row.instance_of?( IndividualRecord )
      single_row.record_type.code
    else
      'FOR'
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
