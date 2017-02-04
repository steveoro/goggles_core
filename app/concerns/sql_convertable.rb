require 'active_support'
require 'wrappers/timing'
require_relative '../strategies/sql_converter'


=begin

= SqlConvertable

  - version:  6.072
  - author:   Leega, Steve A.

  Container module for interfacing common "sql_convertable" startegies
  and method functions.

=end
module SqlConvertable
  extend ActiveSupport::Concern

  include ::SqlConverter

  # Returns the overall SQL diff/log for all the SQL operations that should
  # be carried out by for replicating the changes (already done by this instance) on
  # another instance of the same Database (for example, to apply the changes on
  # a production DB after testing them on a staging version of the same DB).
  # It is never +nil+, empty at first.
  #
  def sql_diff_text_log
    @sql_diff_text_log ||= ''
  end
  # ----------------------------------------------------------------------------
  #++

  # Reset diff sql file
  #
  def reset_sql_diff_text_log
    @sql_diff_text_log = ''
  end
  # ----------------------------------------------------------------------------
  #++

  # Create a diff sql file header
  #
  def create_sql_diff_header( diff_header = nil )
    sql_diff_text_log << "--\r\n"
    sql_diff_text_log << "-- #{diff_header}\r\n" if diff_header
    sql_diff_text_log << "-- #{DateTime.now.strftime(format="%d %B %Y %H:%M:%S")}\r\n"
    sql_diff_text_log << "-- Begin script\r\n"
    sql_diff_text_log << "--\r\n"
    sql_diff_text_log << "\r\n"
  end
  # ----------------------------------------------------------------------------
  #++

  # Create a diff sql file footer
  #
  def create_sql_diff_footer( diff_footer = nil )
    sql_diff_text_log << "\r\n"
    sql_diff_text_log << "-- #{diff_footer}\r\n" if diff_footer
    sql_diff_text_log << "-- Script ended"
  end
  # ----------------------------------------------------------------------------
  #++

  # Add a diff sql file comment
  #
  def add_sql_diff_comment( comment = nil )
    sql_diff_text_log << "--"
    sql_diff_text_log << " #{comment}" if comment
    sql_diff_text_log << "\r\n"
  end
  # ----------------------------------------------------------------------------
  #++

  # Stores the current contents of the #sql_diff_text_log
  # to the designated full_diff_pathname, adding a 'BEGIN TRANSACTION'
  # at the beginning and a 'COMMIT' at the end.
  #
  def save_diff_file( full_diff_pathname )
    File.open( full_diff_pathname, 'w' ) do |f|
      f.puts "-- #{ full_diff_pathname }\r\n"
      f.puts "SET SQL_MODE = \"NO_AUTO_VALUE_ON_ZERO\";"
      f.puts "SET AUTOCOMMIT = 0;"
      f.puts "START TRANSACTION;"
      f.puts "SET time_zone = \"+00:00\";"
      f.puts "/*!40101 SET NAMES utf8 */;"
      f.puts "\r\n--\r\n"

      f.puts sql_diff_text_log

      f.puts "\r\n--\r\n"
      f.puts "COMMIT;"
    end
  end
  # ----------------------------------------------------------------------------
  #++
end
