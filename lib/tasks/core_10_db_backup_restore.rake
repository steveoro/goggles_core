# encoding: utf-8

require 'date'
require 'rubygems'
require 'find'
require 'fileutils'

require 'common/format'


=begin

= Local Deployment helper tasks

  - (p) FASAR Software 2007-2016
  - Goggles framework vers.:  5.00
  - author: Steve A.

  (ASSUMES TO BE rakeD inside Rails.root)

=end


# [Steve, 20130808] The following will remove the task db:test:prepare
# to avoid having to wait each time a test is run for the db test to reset
# itself:
Rake::TaskManager.class_eval do
  def remove_task(task_name)
    @tasks.delete(task_name.to_s)
  end
end
Rake.application.remove_task 'db:reset'
Rake.application.remove_task 'db:test:prepare'



namespace :db do

  namespace :test do
    task :prepare do |t|
      # rewrite the task to not do anything you don't want
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  desc <<-DESC
  This is an override of the standard Rake db:reset task.
It actually DROPS the Database, recreates it using a mysql shell command.

( LEGACY USAGE -- NOT ACTUALLY USED ANYMORE )

Options: [Rails.env=#{Rails.env}]

  DESC
  task :reset do |t|
    puts "*** Task: Custom DB RESET ***"
    rails_config  = Rails.configuration             # Prepare & check configuration:
    db_name       = rails_config.database_configuration[Rails.env]['database']
    db_user       = rails_config.database_configuration[Rails.env]['username']
    db_pwd        = rails_config.database_configuration[Rails.env]['password']
    db_host       = rails_config.database_configuration[Rails.env]['host']
                                                    # Display some info:
    puts "DB name:      #{db_name}"
    puts "DB user:      #{db_user}"
    puts "\r\nDropping DB..."
    sh "mysql --host=#{db_host} --user=#{db_user} --password=\"#{db_pwd}\" --execute=\"drop database if exists #{db_name}\""
    puts "\r\nRecreating DB..."
    sh "mysql --host=#{db_host} --user=#{db_user} --password=\"#{db_pwd}\" --execute=\"create database #{db_name}\""
  end
  #-- -------------------------------------------------------------------------
  #++


  desc <<-DESC
  Recreates the current DB from scratch.
Invokes the following tasks in in one shot:

  - db:reset           ...to clear the current DB (default: development);
  - db:migrate         ...to run migrations;
  - db:seed            ...to run any scripted seed row in db/seeds.rb;

Keep in mind that, when not in production, the test DB must then be updated
using the db:clone_to_test dedicated task.

( LEGACY USAGE -- NOT ACTUALLY USED ANYMORE )

Options: [Rails.env=#{Rails.env}]

  DESC
  task :rebuild_from_scratch do
    puts "*** Task: Compound DB RESET + MIGRATE + DB:SEED ***"
    Rake::Task['db:reset'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:seed'].invoke
    puts "Done."
  end
  #-- -------------------------------------------------------------------------
  #++


  desc <<-DESC
  Similarly to sql:dump, db:dump creates a bzipped MySQL dump of the whole DB for
later restore.
The resulting file does not contain any "create database" statement and it can be
executed freely on any empty database with any name of choice.

The file is stored as:

  - 'db/dump/#{Rails.env}.sql.bz2'

This is assumed to be kept under the source tree repository and used for a quick recovery
of the any of the DB structures using the dedicated task "db:rebuild_from_dump".

Options: [Rails.env=#{Rails.env}]

  DESC
  task( dump: [:check_needed_dirs] ) do
    puts "*** Task: DB dump for quick recovery ***"
                                                    # Prepare & check configuration:
    rails_config  = Rails.configuration
    db_name       = rails_config.database_configuration[Rails.env]['database']
    db_user       = rails_config.database_configuration[Rails.env]['username']
    db_pwd        = rails_config.database_configuration[Rails.env]['password']
    db_host       = rails_config.database_configuration[Rails.env]['host']
    db_dump( db_host, db_user, db_pwd, db_name, Rails.env )
  end


  # Performs the actual operations required for a DB dump update given the specified
  # parameters.
  #
  # Note that the dump takes the name of the Environment configuration section.
  #
  def db_dump( db_host, db_user, db_pwd, db_name, dump_basename )
    puts "\r\nUpdating recovery dump '#{ dump_basename }' (from #{db_name} DB)..."
    zip_pipe = ' | bzip2 -c'
    file_ext = '.sql.bz2'                           # Display some info:
    puts "DB name: #{ db_name }"
    puts "DB user: #{ db_user }"
    file_name = File.join( DB_DUMP_DIR, "#{ dump_basename }#{ file_ext }" )
    puts "\r\nProcessing #{ db_name } => #{ file_name } ...\r\n"
    # To disable extended inserts, add this option: --skip-extended-insert
    # (The Resulting SQL file will be much longer, though -- but the bzipped
    #  version can result more compressed due to the replicated strings, and it is
    #  indeed much more readable and editable...)
    sh "mysqldump --host=#{ db_host } -u #{ db_user } --password=\"#{db_pwd}\" -l --triggers --routines -i --skip-extended-insert --no-autocommit --single-transaction #{ db_name } #{ zip_pipe } > #{ file_name }"
    puts "\r\nRecovery dump created.\r\n\r\n"
  end
  #-- -------------------------------------------------------------------------
  #++


  desc <<-DESC
  Recreates the current DB from a recovery dump created with db:dump.

Options: [Rails.env=#{Rails.env}]
         [from=dump_base_name|<#{Rails.env}>]
         [to='production'|'development'|'test']

  - from: when not specified, the source dump base name will be the same of the
        current Rails.env

  - to: when not specified, the destination database will be the same of the
        current Rails.env

  DESC
  task( rebuild_from_dump: [:check_needed_dirs] ) do
    puts "*** Task: DB rebuild from dump ***"
                                                    # Prepare & check configuration:
    rails_config  = Rails.configuration
    db_name       = rails_config.database_configuration[Rails.env]['database']
    db_user       = rails_config.database_configuration[Rails.env]['username']
    db_pwd        = rails_config.database_configuration[Rails.env]['password']
    db_host       = rails_config.database_configuration[Rails.env]['host']
    dump_basename = ENV.include?("from") ? ENV["from"] : Rails.env
    output_db     = ENV.include?("to")   ? rails_config.database_configuration[ENV["to"]]['database'] : db_name
    file_ext      = '.sql.bz2'

    rebuild_from_dump( dump_basename, output_db, db_host, db_user, db_pwd, file_ext )
  end


  # Performs the actual sequence of operations required by a single db:rebuild_from_dump
  # task, given the specified parameters.
  #
  # The source_basename comes from the name of the file dump.
  # Note that the dump takes the name of the Environment configuration section.
  #
  def rebuild_from_dump( source_basename, output_db, db_host, db_user, db_pwd, file_ext = '.sql.bz2' )
    puts "\r\nRebuilding..."
    puts "DB name: #{ source_basename } (dump) => #{ output_db } (DEST)"
    puts "DB user: #{ db_user }"

    file_name = File.join( DB_DUMP_DIR, "#{ source_basename }#{ file_ext }" )
    sql_file_name = File.join( 'tmp', "#{ source_basename }.sql" )

    puts "\r\nUncompressing dump file '#{ file_name }' => '#{ sql_file_name }'..."
    sh "bunzip2 -ck #{ file_name } > #{ sql_file_name }"

    puts "\r\nDropping destination DB '#{ output_db }'..."
    sh "mysql --host=#{ db_host } --user=#{ db_user } --password=\"#{db_pwd}\" --execute=\"drop database if exists #{ output_db }\""
    puts "\r\nRecreating destination DB..."
    sh "mysql --host=#{ db_host } --user=#{ db_user } --password=\"#{db_pwd}\" --execute=\"create database #{ output_db }\""

    puts "\r\nExecuting '#{ file_name }' on #{ output_db }..."
    sh "mysql --host=#{ db_host } --user=#{ db_user } --password=\"#{db_pwd}\" --database=#{ output_db } --execute=\"\\. #{ sql_file_name }\""
    puts "Deleting uncompressed file '#{ sql_file_name }'..."
    FileUtils.rm( sql_file_name )

    puts "Rebuild from dump for '#{ source_basename }', done.\r\n\r\n"
  end
  #-- -------------------------------------------------------------------------
  #++


  desc <<-DESC
  Clones the development or production database to the test database (according to
Rails environment; default is obviously 'development').

Assumes development db name ends in '_development' and production db name doesn't
have any suffix.

Options: [Rails.env=#{Rails.env}]

  DESC
  task( clone_to_test: [:check_needed_dirs] ) do
    puts "*** Task: Clone DB on TEST DB ***"
    if (Rails.env == 'test')
      puts "You must specify either 'development' or 'production'!"
      exit
    end
                                                    # Prepare & check configuration:
    rails_config  = Rails.configuration
    db_name       = rails_config.database_configuration[Rails.env]['database']
    db_user       = rails_config.database_configuration[Rails.env]['username']
    db_pwd        = rails_config.database_configuration[Rails.env]['password']
    db_host       = rails_config.database_configuration[Rails.env]['host']
    output_folder = ENV.include?("output_dir") ? ENV["output_dir"] : DB_BACKUP_DIR
                                                    # Display some info:
    puts "DB name: #{db_name}"
    puts "DB user: #{db_user}"
    file_name = File.join( output_folder, "#{db_name}-clone.sql" )
    puts "\r\nDumping #{db_name} on #{file_name} ...\r\n"
    sh "mysqldump --host=#{db_host} -u #{db_user} --password=\"#{db_pwd}\" --triggers --routines -i -e --no-autocommit --single-transaction #{db_name} > #{file_name}"
    base_db_name = db_name.split('_development')[0]
    puts "\r\nDropping Test DB '#{base_db_name}_test'..."
    sh "mysql --host=#{db_host} --user=#{db_user} --password=\"#{db_pwd}\" --execute=\"drop database if exists #{base_db_name}_test\""
    puts "\r\nRecreating DB..."
    sh "mysql --host=#{db_host} --user=#{db_user} --password=\"#{db_pwd}\" --execute=\"create database #{base_db_name}_test\""
    puts "\r\nExecuting '#{file_name}' on #{base_db_name}_test..."
    sh "mysql --host=#{db_host} --user=#{db_user} --password=\"#{db_pwd}\" --database=#{base_db_name}_test --execute=\"\\. #{file_name}\""
    puts "Deleting dump file '#{file_name}'..."
    FileUtils.rm( file_name )

    puts "Clone on Test DB done.\r\n\r\n"
  end
  #-- -------------------------------------------------------------------------
  #++

end
# =============================================================================
