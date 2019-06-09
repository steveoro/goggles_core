# rubocop:disable Style/FrozenStringLiteralComment

#
# = SqlConverter
#
#   - Goggles framework vers.:  6.135
#   - author: Steve A.
#
#   Container module for methods or strategies to obtain complete SQL statements from
#   ActiveRecord object instances.
#
#   Leega: We have to ignore figurates only attributes, such `tags_by_user_list` and `tags_by_team_list`
#   because they aren't stored in DB
#
module SqlConverter
  # Re-creates an SQL INSERT statement using the attributes of the record instance specified.
  # (It assumes record.kind_of?(ActiveRecord::Base) is +true+).
  #
  def to_sql_insert(record, with_comment = true, eoln = "\r\n\r\n", explanation = nil)
    con = record.class.connection
    sql_text = with_comment ? get_sql_comment(record) : ''
    sql_text << "-- #{explanation}\r\n" if explanation
    sql_text << "INSERT INTO #{con.quote_column_name(record.class.table_name)} "
    columns = []
    values  = []
    # .reject{ |key| key == 'lock_version' }
    record.attributes
          .reject { |key| to_ignore.include?(key) }
          .each do |key, value|
      columns << con.quote_column_name(key)
      values  << con.quote(value)
    end
    sql_text << "(#{columns.join(', ')})\r\n  VALUES (#{values.join(', ')});#{eoln}"
    sql_text
  end

  # Re-creates an SQL UPDATE statement using the attributes of the record instance specified.
  # (It assumes record.kind_of?(ActiveRecord::Base) is +true+).
  #
  # By specifying an attribute_hash (in the format: column.name => column.value) it
  # is possible to compose the UPDATE statement only for the columns included in
  # the Hash.
  #
  def to_sql_update(record, with_comment = true, attribute_hash = record.attributes, eoln = "\r\n\r\n", explanation = nil)
    con = record.class.connection
    sql_text = with_comment ? get_sql_comment(record) : ''
    sql_text << "-- #{explanation}\r\n" if explanation
    sql_text << "UPDATE #{con.quote_column_name(record.class.table_name)}\r\n"
    sets = []
    # .reject{ |key| key == 'id' || key == 'lock_version' }
    attribute_hash
      .reject { |key| key == 'id' || to_ignore.include?(key) }
      .each do |key, value|
      sets << "#{con.quote_column_name(key)}=#{con.quote(value)}"
    end
    sql_text << "  SET #{sets.join(', ')}\r\n"
    sql_text << "  WHERE (#{con.quote_column_name('id')}=#{record.id});#{eoln}"
    sql_text
  end

  # Re-creates an SQL DELETE statement using the attributes of the record instance specified.
  # (It assumes record.kind_of?(ActiveRecord::Base) is +true+).
  #
  def to_sql_delete(record, with_comment = true, eoln = "\r\n\r\n", explanation = nil)
    con = record.class.connection
    sql_text = with_comment ? get_sql_comment(record) : ''
    sql_text << "-- #{explanation}\r\n" if explanation
    sql_text << "DELETE FROM #{con.quote_column_name(record.class.table_name)} "
    sql_text << "WHERE (#{con.quote_column_name('id')}=#{record.id});#{eoln}"
    sql_text
  end
  #-- -------------------------------------------------------------------------
  #++

  # Destroys the specified record (assuming is a valid instance of an).
  # ActiveRecord::Base sibling class), while capturing and returning the
  # associated SQL *DELETE* (only) statements.
  #
  # Since destroy will respects _dependent_ callback invocations, this will
  # automatically log any DELETE for any foreign key related entity specified
  # in the source Model.
  #
  # === Returns:
  #
  # The captured SQL DELETE text log in case of success, +nil+ in case of errors.
  #
  def destroy_with_sql_capture(record)
    return nil if record.nil?

    # Monkey-patch the Connection class to intercept what we need:
    record.class.connection.class.class_eval do
      attr_accessor :captured_sql_delete_text
      # Alias the adapter's execute for later use
      alias_method :old_execute, :execute
      # Re-define the execute method:
      def execute(sql, name = nil)
        @captured_sql_delete_text ||= ''
        # Intercept/log only the statement that we want and log it to the internal text:
        # DEBUG
        #        puts "\r\n---- SQL ----"
        #        puts sql
        #        puts "-------------"
        (@captured_sql_delete_text << "#{sql};\r\n") if /^(delete)/i.match(sql)
        # Always execute the SQL statement afterwards:
        old_execute(sql, name)
      end
    end

    # Issue the destroy upon the record:
    record.destroy
    result_log = record.class.connection.captured_sql_delete_text
    record.class.connection.captured_sql_delete_text = nil

    # Double Monkey-patch to stop the interception and restore original behaviour
    # (since it's almost safe)
    record.class.connection.class.class_eval do
      # Restore original implementation of execute:
      alias_method :execute, :old_execute
    end

    record.destroyed? && !result_log.empty? ? result_log : nil
  end
  #-- -------------------------------------------------------------------------
  #++

  private

  # Returns a line of comment to be included in each resulting SQL operation
  # logged.
  def get_sql_comment(record)
    user = record if record.instance_of?(User)
    # For UserSwimmerConfirmation the active subject is the :confirmator, not
    # the :user. So we give it an higher precendence:
    user ||= record.confirmator if record.respond_to?(:confirmator)
    user ||= record.user if record.respond_to?(:user)
    "-- #{user}\r\n"
  end

  # Attributes forced to be ignored
  # 'lock_version' because should use default
  # 'tags_by_user_list' and 'tags_by_team_list' because not on DB
  def to_ignore
    %w[lock_version tags_by_user_list tags_by_team_list]
  end
end

# rubocop:enable Style/FrozenStringLiteralComment
