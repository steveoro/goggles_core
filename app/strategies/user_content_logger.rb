# encoding: utf-8

require 'sql_converter'


=begin

= UserContentLogger

  - Goggles framework vers.:  6.010
  - author: Steve A.

  Generic strategy/service class dedicated to log each user-created
  content on the site.

  Typical usage involves declaring callback filters directly on the
  models like this:

    class SwimmingPoolReview < ApplicationRecord

      before_destroy  UserContentLogger.new( 'swimming_pool_reviews' )

      # [... snip ...]

    end

  This is used to keep in synch remote and local database dumps.

  Whenever the callback gets called, a custom log file will be created or appended
  with the corresponding SQL statement of the executed change which triggered the
  callback.
  The destination folder is currently public/output.

  Note that the process that will create this file will result in nobody:nogroup
  ownership, thus the destination directory should be chown-ed to 0777 as
  permission (which is not security-wise).

  Remember also not to abuse the usage of this class, since it may slow
  down considerably the whole application.

=end
class UserContentLogger
  include SqlConverter

  # Each instance will append to a separate file, depending upon model name
  # (UGC => User Generated Content)
  LOG_BASENAME = 'ugc_'

  LOG_DESTINATION = 'public/output'

  # These attribute getters are mainly used in specs and nothing more.
  attr_reader :table_name, :log_filename, :email_on_create, :email_on_destroy
  #-- -------------------------------------------------------------------------
  #++


  # Creates a new instance, storing the Model name to which this
  # instance it refers to.
  #
  # The name must be a String (not +nil+). No checks are performed to verify
  # that the +table_name+ corresponds to an actual table on the database.
  #
  # === Supported options:
  #
  # - :email_on_create => when true, an email for the first defined Admin
  #                       will be delivered to notify the creation performed
  #                       by the user associated to the model (if any).
  #
  # - :email_on_destroy => same as above, but for a destroy action.
  #
  def initialize( table_name, options = {} )
    raise ArgumentError.new("UserContentLogger requires at least a table name as a parameter!") unless table_name.instance_of?(String)
    @table_name = table_name
    @log_filename = File.join( File.join(Rails.root, LOG_DESTINATION), "#{LOG_BASENAME}#{@table_name}.log" )
    @email_on_create  = ( options[:email_on_create] == true )
    @email_on_destroy = ( options[:email_on_destroy] == true )
  end
  #-- -------------------------------------------------------------------------
  #++


  # Callback for when a new row from the #model is created.
  # Logs the action, the instance and the linked user, if available.
  #
  def after_create( record )
    contents = to_sql_insert( record )
    to_logfile( contents )
                                                    # Send a notification to the admin, if requested:
    AgexMailer.action_notify_mail(
      record.respond_to?( :user ) ? record.user : nil,
      "#{@table_name} row CREATED",
      contents
    ).deliver if @email_on_create
  end


  # Callback for when a new row from the #model is updated.
  # Logs the action, the instance and the linked user, if available.
  #
  def after_update( record )
    contents = to_sql_update( record )
    to_logfile( contents )
  end


  # Callback for when a new row from the #model is destroyed.
  # Logs the action, the instance and the linked user, if available.
  #
  def before_destroy( record )
    contents = to_sql_delete( record )
    to_logfile( contents )
                                                    # Send a notification to the admin, if requested:
    AgexMailer.action_notify_mail(
      record.respond_to?( :user ) ? record.user : nil,
      "#{@table_name} row DELETED",
      contents
    ).deliver if @email_on_destroy
  end
  #-- -------------------------------------------------------------------------
  #++

  # Appends the specified contents on logfile.
  def to_logfile( contents )
    if contents.size > 0
      File.open( @log_filename, 'a' ) { |f| f.puts contents }
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
