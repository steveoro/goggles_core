# encoding: utf-8


=begin

= SqlConverter

  - Goggles framework vers.:  4.00.733
  - author: Steve A.

  Container module for methods or strategies to obtain complete SQL statements from
  ActiveRecord object instances.

=end
module SqlConverter

  # Re-creates an SQL INSERT statement using the attributes of the record instance specified.
  # (It assumes record.kind_of?(ActiveRecord::Base) is +true+).
  #
  def to_sql_insert( record, with_comment = true, eoln = "\r\n\r\n", explanation = nil )
    con = record.connection
    sql_text = with_comment ? get_sql_comment(record) : ''
    sql_text << "-- #{explanation}\r\n" if explanation 
    sql_text << "INSERT INTO #{ con.quote_column_name( record.class.table_name ) } "
    columns = []
    values  = []
    record.attributes
      .reject{ |key| key == 'lock_version' }
      .each do |key, value|
      columns << con.quote_column_name( key )
      values  << con.quote( value )
    end
    sql_text << "(#{ columns.join(', ') })\r\n  VALUES (#{ values.join(', ') });#{ eoln }"
    sql_text
  end


  # Re-creates an SQL UPDATE statement using the attributes of the record instance specified.
  # (It assumes record.kind_of?(ActiveRecord::Base) is +true+).
  #
  # By specifying an attribute_hash (in the format: column.name => column.value) it
  # is possible to compose the UPDATE statement only for the columns included in
  # the Hash.
  #
  def to_sql_update( record, with_comment = true, attribute_hash = record.attributes, eoln = "\r\n\r\n", explanation = nil )
    con = record.connection
    sql_text = with_comment ? get_sql_comment(record) : ''
    sql_text << "-- #{explanation}\r\n" if explanation 
    sql_text << "UPDATE #{ con.quote_column_name( record.class.table_name ) }\r\n"
    sets = []
    attribute_hash
      .reject{ |key| key == 'id' || key == 'lock_version' }
      .each do |key, value|
      sets << "#{ con.quote_column_name(key) }=#{ con.quote(value) }"
    end
    sql_text << "  SET #{ sets.join(', ') }\r\n"
    sql_text << "  WHERE (#{ con.quote_column_name('id') }=#{ record.id });#{ eoln }"
    sql_text
  end


  # Re-creates an SQL DELETE statement using the attributes of the record instance specified.
  # (It assumes record.kind_of?(ActiveRecord::Base) is +true+).
  #
  def to_sql_delete( record, with_comment = true, eoln = "\r\n\r\n", explanation = nil )
    con = record.connection
    sql_text = with_comment ? get_sql_comment(record) : ''
    sql_text << "-- #{explanation}\r\n" if explanation 
    sql_text << "DELETE FROM #{ con.quote_column_name( record.class.table_name ) } "
    sql_text << "WHERE (#{ con.quote_column_name('id') }=#{ record.id });#{ eoln }"
    sql_text
  end
  #-- -------------------------------------------------------------------------
  #++


  private


  # Returns a line of comment to be included in each resulting SQL operation
  # logged.
  def get_sql_comment( record )
    user = record if record.instance_of?( User )
    # For UserSwimmerConfirmation the active subject is the :confirmator, not
    # the :user. So we give it an higher precendence:
    user ||= record.confirmator if record.respond_to?( :confirmator )
    user ||= record.user if record.respond_to?( :user )
    "-- #{user}\r\n"
  end
end