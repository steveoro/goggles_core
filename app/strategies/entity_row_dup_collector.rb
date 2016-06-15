# encoding: utf-8


=begin

= EntityRowDupCollector

  - Goggles framework vers.:  4.00.731
  - author: Steve A.

 Typically used during Team-merge operations.

 Allows to collect 2 arrays of rows from the same entity class (of type ActiveRecord::Base),
 the first of "duplicated" rows ("dups", for brevity), the second of "non-duplicate"
 rows ("non-dups").

 Both "dups" & "non-dups" arrays are collected comparing between them a source/slave
 array of rows versus a destination/master array of rows extracted from the same
 entity.

 A row  is considered a "duplicate" if present in the source array while having
 values that appera to be identical or equivalent to the ones of any existing
 destination row.

=end
class EntityRowDupCollector

  attr_reader :duplicate_rows, :non_duplicates_rows, :source_rows, :dest_rows

  # Creates a new instance
  #
  def initialize( entity_class )
    @entity_class = entity_class
    @duplicate_rows = []
    @non_duplicates_rows = []
  end
  #-- -------------------------------------------------------------------------
  #++


  # Collects the two member array of rows from the entity class specified in the
  # constructor: the 'duplicate' and the 'non-duplicates' row arrays.
  # The first contains the rows that can be deleted (because found as duplicates
  # of existing destination ones).
  # The second contains the rows that require an update for the merging to be complete.
  #
  # A row is considered 'a duplicate' when there's an 'equal' counterpart of its
  # values inside the master/destination array of rows selected for the merge.
  #
  # Given the entity class, the source/slave and master/destination array of rows
  # are collected using the specified lambda conditions.
  # Each lambda condition expects only 1 parameter.
  #
  # ==== Typical definition case:
  #
  #   filtering_lamdba  = ->(id) { where( team_id: id ) }
  #
  # For the equality check, the block given will receive two parameters:
  #
  # 1) the currently processed source/slave row
  # 2) a destination/master row for each destination row found with the above dest_lambda
  #
  # The source row should be compared against the destination inside the block in search
  # of "equalities".
  # The block should always return either +true+ or +false+ (so that the source
  # rows may be splitted between "dups" and "non-dups").
  #
  # ==== Typical equality check:
  #
  #   (dest_row.meeting_program_id == src_row.meeting_program_id) &&
  #   (dest_row.rank == src_row.rank)
  #
  #
  # === Example invocation (for Badge):
  #
  #   collector = EntityRowDupCollector.new( Badge )
  #   filter = ->(id) { where( team_id: id ) }
  #
  #   collector.process( slave_id, filter, master_id, filter ) do |src_row, dest_row|
  #     (dest_row.swimmer_id == src_row.swimmer_id) &&
  #     (dest_row.season_id == src_row.season_id)
  #   end
  #
  def process( src_param, src_lamdba, dest_param, dest_lambda, &equality_check )
    @duplicate_rows = []                            # Reset the destination arrays
    @non_duplicates_rows = []
                                                    # Collect source & destionation lists:
    @source_rows = @entity_class.instance_exec( src_param, &src_lamdba )
    @dest_rows   = @entity_class.instance_exec( dest_param, &dest_lambda )

    # To get the unique, non-duplicate src rows, reject all the rows from the source
    # that are equal to any destination row:
    @non_duplicates_rows = @source_rows.reject do |src_row|
      ( @dest_rows.size > 0 ) &&                    # Do not reject anything if the dest. rows array is empty
      @dest_rows.any? do |dest_row|
        yield( src_row, dest_row ) if block_given?
      end
    end

    @duplicate_rows = @source_rows.reject do |src_row|
      @non_duplicates_rows.any?{ |nondup_row| nondup_row.id == src_row.id }
    end
  end
  #-- -------------------------------------------------------------------------
  #++

end
