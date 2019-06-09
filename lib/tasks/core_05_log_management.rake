# frozen_string_literal: true

require 'date'
require 'fileutils'

#
#  == Log-management Rake tasks.
#
#   @author Steve A.
#   @build  2016.12.20
#
#   (ASSUMES TO BE rakeD inside Rails.root)
#  (p) FASAR Software 2007-2016
#
#-- ---------------------------------------------------------------------------
#++

namespace :log do
  desc <<~DESC
      Creates a new (bzipped) backup of each log file, truncating then the current ones
    and clearing also the temp output dir.

      Options: [output_dir=#{LOG_BACKUP_DIR}]
               [max_backup_kept=#{MAX_BACKUP_KEPT}]

  DESC
  task(log_rotate: [:check_needed_dirs]) do
    puts '*** Task: Log rotate ***'
    puts 'Saving backups of the current log files...'
    # Prepare & check configuration:
    time_signature  = Time.zone.now.strftime('%Y%m%d.%H%M%S')
    max_backups     = ENV.include?('max_backup_kept') ? ENV['max_backup_kept'].to_i : MAX_BACKUP_KEPT
    backup_folder   = ENV.include?('output_dir') ? ENV['output_dir'] : LOG_BACKUP_DIR

    # Create a backup of each log, if the log directory exists:
    if File.directory?(LOG_DIR)
      # Clean /tmp system dir from any residual log file:
      puts 'Cleaning /tmp from residual logs...'
      FileUtils.rm_f(Dir.glob(File.join('/tmp', '*.log')))
      # Make a copy of all the logs, since they can be updated while archiving:
      puts 'Making a temp. copy of all the logs and UGC output files...'
      FileUtils.cp(Dir.glob(File.join(LOG_DIR, '*.log')), '/tmp')
      FileUtils.cp(Dir.glob(File.join(OUTPUT_DIR, '*.log')), '/tmp') if File.directory?(OUTPUT_DIR)

      Dir.chdir('/tmp') do
        puts 'Archiving all copied logs...'
        dest_archive_name = "goggles_logs_#{time_signature}.log.tar.bz2"
        result = `tar --bzip2 -cf #{ dest_archive_name } *.log`
        puts "Command 'tar --bzip2 -cf #{dest_archive_name} *.log' returned '#{result}'"
        puts 'Moving log archive into backup folder...'
        FileUtils.mv(dest_archive_name, backup_folder)
      end

      puts 'Cleaning /tmp again...'
      FileUtils.rm_f(Dir.glob(File.join('/tmp', '*.log')))

      # The following will zero-len all *.log files found in the log dir.
      # Note that simply invoking Rake::Task['log:clear'].invoke will not clear
      # non-environment log files, like access.log and error.log
      puts 'Truncating all current log files...'
      Dir.chdir(LOG_DIR) do
        result = `truncate *.log --size 0`
        puts "Command 'truncate *.log --size ' returned '#{result}'"
      end

      # Remove all user-generated-content logs, already stored in back-up files:
      puts 'Cleaning any User-Generated content output (log) files...'
      FileUtils.rm_f(Dir.glob(File.join(OUTPUT_DIR, 'ugc*.log'))) if File.directory?(OUTPUT_DIR)
      # Remove any UCG log file created by any previous version (which used LOG_DIR instead of OUTPUT_DIR)
      FileUtils.rm_f(Dir.glob(File.join(LOG_DIR, 'ugc*.log')))

      # Rotate the backups leaving only the newest ones: (log files are 4x normal backups,
      # since these are the 'access', 'errors', 'braintree' and 'production' logs)
      rotate_backups(backup_folder, max_backups * 4)
    else
      puts 'Log dir not found. Skipping...'
    end
    puts "Done.\r\n\r\n"
  end
  #-- -------------------------------------------------------------------------
  #++
end
#-- ---------------------------------------------------------------------------
#++
