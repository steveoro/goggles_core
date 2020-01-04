# encoding: utf-8
require 'common/format'

=begin

= FinCalendarBaseBuilder

  - Goggles framework vers.:  6.127
  - author: Steve A.

 Base common class for all FinCalendar builders.

=end
class FinCalendarBaseBuilder
  include SqlConvertable

  attr_reader :has_updated, :has_created, :has_errors

  # Creates a new instance, given the current user that has "recorded" this batch
  # of operations.
  #
  def initialize( current_user )
    raise ArgumentError.new('current_user must be defined!') unless current_user.instance_of?( User )
    @current_user = current_user
    @report_log = []
    @has_updated = false
    @has_created = false
    @has_errors  = false
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns true if the builder instance has changed the DB (and the DB-diff can be saved).
  #
  def has_changes?
    @has_updated || @has_created
  end
  #-- -------------------------------------------------------------------------
  #++


  # Outputs the report log of the actions performed.
  # It does nothing in case the display object does not respond to the specified
  # display method.
  #
  def report( display_object = Kernel, display_method = :puts )
    return if display_method.nil? || !display_object.respond_to?( display_method )

    @report_log.each do |log_line|
      display_object.send( display_method, log_line )
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  # Base finder/creator method. It does nothing.
  # => To be overridden in siblings. <=
  #
  def find_or_create!()
  end
  #-- -------------------------------------------------------------------------
  #++


  protected


  # Adds the specified text_message to the @report_log, adding also a newline at the end.
  #
  def add_to_log( text_message )
    @report_log << "#{ text_message }\r\n"
# DEBUG
#    puts text_message
  end
  #-- -------------------------------------------------------------------------
  #++


  # Creates a new instance, logging the outcome.
  #
  def create_new( entity_instance, caller_class_name )
    # Serialize the creation:
    if entity_instance.save
      sql_diff_text_log << to_sql_insert( entity_instance, false, "\r\n" )
      add_to_log( "New #{ entity_instance.class.name } created. ID: #{ entity_instance.id }" )
      @has_created = true
    else
      if entity_instance.invalid?
        sql_diff_text_log << "-- INSERT VALIDATION FAILURE in #{ caller_class_name }: #{ ValidationErrorTools.recursive_error_for( entity_instance ) }\r\n"
        add_to_log( "INSERT VALIDATION FAILURE in #{ caller_class_name }: #{ ValidationErrorTools.recursive_error_for( entity_instance ) }" )
        @has_errors = true
      end
      if $!
        sql_diff_text_log << "-- INSERT FAILURE in #{ caller_class_name }: #{ $! }\r\n" if $!
        add_to_log( "INSERT FAILURE in #{ caller_class_name }: #{ $! }" )
        @has_errors = true
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  # Updates an existing instance, logging the outcome.
  # The sql_attributes specify which attributes are to be considered as "changed".
  #
  def update_existing( entity_instance, sql_attributes, caller_class_name )
    # Serialize the update:
    if entity_instance.save
      sql_diff_text_log << to_sql_update( entity_instance, false, sql_attributes, "\r\n" )
      add_to_log( "#{ entity_instance.class.name } updated. => #{ entity_instance.inspect }" )
      @has_updated = true
    else
      if entity_instance.invalid?
        sql_diff_text_log << "-- UPDATE VALIDATION FAILURE in #{ caller_class_name }: #{ ValidationErrorTools.recursive_error_for( entity_instance ) }\r\n"
        add_to_log( "UPDATE VALIDATION FAILURE in #{ caller_class_name }: #{ ValidationErrorTools.recursive_error_for( entity_instance ) }" )
        @has_errors = true
      end
      if $!
        sql_diff_text_log << "-- UPDATE FAILURE in #{ caller_class_name }: #{ $! }\r\n"
        add_to_log( "UPDATE FAILURE in #{ caller_class_name }: #{ $! }" )
        @has_errors = true
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
