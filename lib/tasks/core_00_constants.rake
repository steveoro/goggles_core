# encoding: utf-8

require 'date'
require 'fileutils'


=begin

 == Constants container for all the Rake tasks.

 In order to be loaded first, this file should be named accordingly.
 Put here anything that should be re-used among more than one task.

  @author Steve A.
  @build  2016.12.20

  (ASSUMES TO BE rakeD inside Rails.root)
 (p) FASAR Software 2007-2016

=end
#-- ---------------------------------------------------------------------------
#++


# Script revision number
SCRIPT_VERSION = '1.1.1' unless defined? SCRIPT_VERSION

#The following 3 are assumed to be already existing directories:
# Log dir
LOG_DIR = File.join( Rails.root, 'log' ) unless defined? LOG_DIR
# Output dir (PDF creation, ugc_XXX.log files creation, used by log management tasks)
OUTPUT_DIR = File.join( Rails.root, 'public', 'output' ) unless defined? OUTPUT_DIR
# Upload dir (user avatars & whatever - Not currently required by any rake task in the core engine)
# UPLOADS_DIR = File.join( Rails.root, 'public', 'uploads' ) unless defined? UPLOADS_DIR


# External base directory used for support files, backups and dumps for all the framework
EXTERNAL_BASE_DIR =  File.join( File.absolute_path( File.join(Dir.pwd, '..') ), 'goggles.docs' ) unless defined? EXTERNAL_BASE_DIR

# DB Dumps have the same name as current environment and are considered as "current".
# Moreover, a DB dump can quickly be restored using the dedicated rake task.
DB_DUMP_DIR       = File.join( Rails.root, 'db', 'dump' ) unless defined? DB_DUMP_DIR

# DB Backups use a timestamp and are archived in a common directory.
DB_BACKUP_DIR     = File.join( EXTERNAL_BASE_DIR, 'backup.db' ) unless defined? DB_BACKUP_DIR
LOG_BACKUP_DIR    = File.join( EXTERNAL_BASE_DIR, 'backup.log' ) unless defined? LOG_BACKUP_DIR

# Maximum number of DB backups kept
MAX_BACKUP_KEPT   = 30 unless defined? MAX_BACKUP_KEPT

# List of "required" directories by the maintenance tasks:
NEEDED_DIRS = [
    EXTERNAL_BASE_DIR,
    DB_DUMP_DIR,
    DB_BACKUP_DIR,
    LOG_BACKUP_DIR
] unless defined? NEEDED_DIRS


# Steps used in displaying task progress:
PROGRESS_BAR_STEPS  = 10 unless defined? PROGRESS_BAR_STEPS
#-- ---------------------------------------------------------------------------
#++

# Display current versioning each time Rake gets executed:
puts "\r\n*** Goggles Core base scripts vers.: #{SCRIPT_VERSION} ***"
puts " "


desc "Check and creates missing directories needed by the structure assumed by some of the maintenance tasks."
task(:check_needed_dirs) do                         # Check the needed folders & create if missing:
  for folder in NEEDED_DIRS
    puts "Checking existance of #{folder} (and creating it if missing)..."
    FileUtils.mkdir_p(folder) unless File.directory?(folder)
  end
  puts "\r\n"
end
#-- ---------------------------------------------------------------------------
#++


# Rotate backups inside a specific 'backup_folder' allowing only a maximum
# number of 'max_backups' (for each backup type) and deleting in rotation the
# oldest ones.
#
def rotate_backups( backup_folder, max_backups )
    puts "Rotating backups (max: #{ max_backups })..."
    all_backups = Dir.glob(File.join(backup_folder, '*'), File::FNM_PATHNAME).sort.reverse
    unwanted_backups = all_backups[max_backups..-1] || []
                                                    # Remove the backups in excess:
    for unwanted_backup in unwanted_backups
      puts "Deleting older backup #{unwanted_backup} ..."
      FileUtils.rm( unwanted_backup )
    end
    puts "Removed #{unwanted_backups.length} backups, #{all_backups.length - unwanted_backups.length} backups available."
end
#-- -------------------------------------------------------------------------
#++


# Returns the full path of a directory with respect to current Application root dir, terminated
# with a trailing slash.
# Current working directory will also be set to Dir.pwd (application root dir) anyways.
#
def get_full_path( sub_path )
  File.join( Dir.pwd, sub_path )
end
#-- ---------------------------------------------------------------------------
#++
