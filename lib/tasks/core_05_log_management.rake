# encoding: utf-8

require 'date'
require 'fileutils'


=begin

 == Log-management Rake tasks.

  @author Steve A.
  @build  2016.06.14

  (ASSUMES TO BE rakeD inside Rails.root)
 (p) FASAR Software 2007-2016

=end
#-- ---------------------------------------------------------------------------
#++


namespace :log do

  desc <<-DESC
  Creates a new (bzipped) backup of each log file, truncating then the current ones
and clearing also the temp output dir.

  Options: [output_dir=#{LOG_BACKUP_DIR}]
           [max_backup_kept=#{MAX_BACKUP_KEPT}]

DESC
  task( log_rotate: [:check_needed_dirs] ) do
    puts "*** Task: Log rotate ***"
    puts "Saving backups of the current log files..."
                                                    # Prepare & check configuration:
    time_signature  = DateTime.now.strftime("%Y%m%d.%H%M%S")
    max_backups     = ENV.include?("max_backup_kept") ? ENV["max_backup_kept"].to_i : MAX_BACKUP_KEPT
    backup_folder   = ENV.include?("output_dir") ? ENV["output_dir"] : LOG_BACKUP_DIR

    if File.directory?(LOG_DIR)                     # Create a backup of each log, if the log directory exists:
      Dir.chdir( LOG_DIR ) do |curr_path|
        for log_filename in Dir.glob(File.join("#{curr_path}",'*.log'), File::FNM_PATHNAME)
          puts "Processing #{log_filename}..."
          Dir.chdir( backup_folder )
          # Make first a copy on /tmp, so that we may archive it even if it's currently
          # being modified:
          temp_file = File.join('/tmp', "#{ File.basename(log_filename) }")
          puts "Making a temp. copy on #{temp_file}..."
          sh "cp #{log_filename} #{ temp_file }"
          puts "Archiving contents..."
          sh "tar --bzip2 -cf #{File.basename(log_filename, '.log') + time_signature + '.log.tar.bz2'} #{temp_file}"
          puts "Removing temp. file..."
          FileUtils.rm( temp_file )
          # (We'll leave the tar file just created under the log dir, so that the #rotate_backups
          #  will be able to treat it properly.)
        end
      end
      Dir.chdir( Dir.pwd.to_s )
      puts "Truncating all current log files..."
      Rake::Task['log:clear'].invoke

      # Rotate the backups leaving only the newest ones: (log files are 4x normal backups,
      # since these are the 'access', 'errors', 'braintree' and 'production' logs)
      rotate_backups( backup_folder, max_backups * 4 )
    else
      puts "Log dir not found. Skipping..."
    end
    puts "Done.\r\n\r\n"
  end
  #-- -------------------------------------------------------------------------
  #++
end
#-- ---------------------------------------------------------------------------
#++
