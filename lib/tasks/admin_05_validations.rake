# encoding: utf-8
require 'date'
require 'fileutils'

require 'framework/version'
require 'framework/application_constants'

require 'common/validation_error_tools'


=begin

= DB-utility tasks

  - Goggles framework vers.:  4.00.733
  - author: Steve A.

  (ASSUMES TO BE rakeD inside Rails.root)

=end
#-- ---------------------------------------------------------------------------
#++


namespace :db do

  desc <<-DESC
  Scans a specific entity or the whole database for ActiveRecord
validation errors on existing data.

This method does not alter the database unless the 'repair' option is used,
it simply outputs a list of blamed row IDs with their JSON error message(s).

  Options: [entity=<entity_name_camelcase>|'Meeting']
           [repair=<0>|1]
           [log_dir=#{LOG_DIR}]

  - entity_name_camelcase => Meeting, MeetingIndividualResult, ...

  - repair => when set (default 0), it will try to correct the following
    validation errors, writing at the end of the process an SQL diff file
    into the log dir:
      - Meeting validation => header year empty or null
      - (more to come...)

  - 'log_dir' => allows to override the default log dir destination.
  DESC
  task :check_validations do |t|
    puts "\r\n*** db:check_validations ***"
    entity = ENV.include?("entity") ? ENV["entity"].to_s.camelize : 'Meeting'
    rails_config  = Rails.configuration             # Prepare & check configuration:
    db_name       = rails_config.database_configuration[Rails.env]['database']
    db_user       = rails_config.database_configuration[Rails.env]['username']
    db_pwd        = rails_config.database_configuration[Rails.env]['password']
    db_host       = rails_config.database_configuration[Rails.env]['host']
    repair        = ENV.include?("repair") && (ENV["repair"].to_i > 0)
    log_dir       = ENV.include?("log_dir") ? ENV["log_dir"] : LOG_DIR
    puts "Requiring Rails environment to allow usage of any Model..."
    require 'rails/all'
    require File.join( Rails.root.to_s, 'config/environment' )
    klass = eval(entity.camelize)
                                                    # Display some info:
    puts "DB host: #{db_host}"
    puts "DB name: #{db_name}"
    puts "DB user: #{db_user}"
    puts "\r\nChecking validations for '#{klass.name}'..."
    puts "REPAIR MODE ON" if repair
    puts "Total rows to be processed: #{klass.count}"
    puts "\r\n---------------- 8< -------------------"
    errors_found = 0
    prev_error_at = 0
    index = 0
    sql_diff = ''

    klass.find_each(batch_size: 250) do |row|
      if row.invalid?
        puts "" unless prev_error_at == index-1
        puts "ID: #{row.id} => #{row.errors().messages.to_json}"
        puts "Backtracing source of error..."
        puts '=> ' + ValidationErrorTools.recursive_error_for( row )
        puts ''
        errors_found += 1
        prev_error_at = index
                                                    # Repair mode:
        if repair && row.instance_of?( Meeting )
          sql_diff << "-- Meeting ##{row.id}: header year fix\r\n"
          sql_diff << V2::MeetingHeaderYearChecker.check_and_fix( row )
        end
      else
        putc '.'
      end
      index += 1
    end
    puts "\r\n---------------- 8< -------------------"
    puts "\r\nTotal validation errors found: #{errors_found > 0 ? errors_found : 'NONE found! ...Yeay! Rejoyce and dance! :)'}"
                                                    # Write an SQL diff file when repairing errors:
    if repair && sql_diff.size > 0
      file_name = File.join(
        log_dir, "#{ DateTime.now.strftime("%Y%m%d%H%M") }prod_validations_fix.sql"
      )
      File.open( file_name, 'w' ) { |f| f.puts sql_diff }
      puts "Repair done. SQL diff file created: #{file_name}."
    end
    puts "\r\nDone."
  end
  #-- -------------------------------------------------------------------------
  #++


desc <<-DESC
Checks current DB in config for duplicated events in the specified Meeting IDs.

** WARNING: **
THIS TASK WILL UPDATE THE DATABASE WHILE TRYING TO FIX THE ERRORS FOUND *WITHOUT*
CREATING AN SQL DIFF FILE.

  Options: meeting_ids=<meeting_1_id>[,<meeting_2_id>,...]
           [Rails.env=#{Rails.env}]

DESC
  task :check_dup_events => ['utils:script_status', 'utils:chk_needed_dirs'] do
    puts "\r\n*** db:check_dup_events ***"
    # Environment setup
    rails_config  = Rails.configuration             # Prepare & check configuration:
    db_name       = rails_config.database_configuration[Rails.env]['database']
    db_user       = rails_config.database_configuration[Rails.env]['username']
    db_pwd        = rails_config.database_configuration[Rails.env]['password']
    db_host       = rails_config.database_configuration[Rails.env]['host']
    # Verify parameters
    unless ENV.include?("meeting_ids")
      puts("Needs at least a 'meeting_ids' parameter.")
      exit
    end
    puts "Requiring Rails environment to allow usage of any Model..."
    require 'rails/all'
    require File.join( Rails.root.to_s, 'config/environment' )
    # Display some info:
    puts "DB host: #{db_host}"
    puts "DB name: #{db_name}"
    puts "DB user: #{db_user}"

    meeting_ids = ENV["meeting_ids"].split(',').map{ |s| s.to_i }
    meeting_ids.each do |meeting_id|
      meeting = Meeting.find( meeting_id )
      puts "\r\n---------------- 8< -------------------"
      puts "Meeeting: ID #{meeting.id}, code: #{meeting.code}, header date: #{meeting.header_date}, '#{meeting.description}'"
      puts "Processing..."
      check_and_fix_duplicated_events( meeting_id )
    end

    puts "\r\nDone.\r\n\r\n"
  end
  #-- -------------------------------------------------------------------------
  #++


desc <<-DESC
  Checks a specific Season or the whole seasons set in search of Swimmers with
duplicate Badges/TeamAffiliations for the same season.

(Each Swimmer can have only 1 team affiliation per season, since each season
 may belong to just one single Federation -- that is, each athlete may compete for
 only 1 Team inside the same Season/Federation.)

  Options: [season=<season_id>]
           [log_dir=#{LOG_DIR}]

  - season => the Season.id to be used for the search; when not set, all
    Seasons are scanned.

  - 'log_dir' => allows to override the default log dir destination.
  DESC
  task :check_dup_badges do |t|
    puts "\r\n*** db:check_dup_badges ***"
    season_id = ENV.include?("season") ? ENV["season"].to_i : nil
    rails_config  = Rails.configuration             # Prepare & check configuration:
    db_name       = rails_config.database_configuration[Rails.env]['database']
    db_user       = rails_config.database_configuration[Rails.env]['username']
    db_pwd        = rails_config.database_configuration[Rails.env]['password']
    db_host       = rails_config.database_configuration[Rails.env]['host']
    log_dir       = ENV.include?("log_dir") ? ENV["log_dir"] : LOG_DIR
    puts "Requiring Rails environment to allow usage of any Model..."
    require 'rails/all'
    require File.join( Rails.root.to_s, 'config/environment' )
                                                    # Display some info:
    puts "DB host: #{db_host}"
    puts "DB name: #{db_name}"
    puts "DB user: #{db_user}"
    seasons = season_id ? [Season.find( season_id )] : Season.all

    seasons.each do |season|
      puts "\r\n\r\nChecking season ##{season.id}..."
      puts "---------------- 8< -------------------"
      dup_swimmers = V2::BadgeDuplicateChecker.get_swimmers_with_duplicates( season )
      dup_teams = []
      if dup_swimmers.size == 0
        puts "No problems found."
      else
        puts "#{dup_swimmers.size} Swimmer(s) with duplicate badges found!"
        swimmer_ids = dup_swimmers.map{ |swimmer| swimmer.id }
        puts swimmer_ids.inspect
                                                    # For each dup_swimmer found:
        dup_swimmers.each do |swimmer|
          dup_teams_for_single_swimmer = []
          dup_badges = swimmer.get_badges_array( season )
          puts "\r\n- Swimmer ##{swimmer.id}, #{swimmer.complete_name} => #{dup_badges.size} badges for season #{season.id}:"
                                                    # For each dup_badge of a swimmer:
          dup_badges.each do |badge|
            puts "  => Badge ##{badge.id}, Team '#{badge.team.name}', T.Aff. ##{badge.team_affiliation_id}"
            dup_teams_for_single_swimmer << badge.team
          end
                                                    # Add possible team dup. tuple to the list:
          dup_teams << dup_teams_for_single_swimmer
        end
      end
      dup_teams.uniq!
      if dup_teams.size > 0
        puts"\r\n*** Summary ***\r\n==============="
        puts"\r\nTeams found linked to duplicates (possibly duplicates themselves):"
        dup_teams.each do |dup_team_row|
          puts dup_team_row.map{ |team| ("%8s" % "##{team.id}:") + ("%-40s" % " '#{team.name}'") }.inspect
        end
        puts "\r\nEither #{dup_teams.size} possible team-merge(s) to be done or issue(s) of same-named Swimmers!"
        puts "\r\nKeep in mind:"
        puts "Every Swimmer MUST HAVE A SINGLE AFFILIATION per Season (since Seasons are divided by type & Federation)."
        puts "Whenever a reported badge duplication in the list above refers to a couple of teams that are actually the same but with a slightly different name, then it is a genuine case of Badge duplication."
        puts "Check out the results and take action.\r\nDO NOT MERGE TEAMS if you are not sure they are actually the same!"
      end
      puts "---------------- 8< -------------------"
    end
    puts "\r\nDone."
  end
  #-- -------------------------------------------------------------------------
  #++
end
#-- ---------------------------------------------------------------------------
#++


# Checks the specified meeting_id for duplicated MeetingEvents and tries to fix them
# by searching for pre-existing MeetingEvents that are the "original" version of the same row.
#
# Normally, duplicated MeetingEvents may happen only due to errors during the data-import
# process. Thus, this method assumes that the only possible ("fixable") duplicated M.E.
# come from the data-import and have the +is_autofilled+ flag on.
# These are the only one actually checked for duplication in the current implementation.
#
def check_and_fix_duplicated_events( meeting_id )
  ms_ids = MeetingSession.where( meeting_id: meeting_id ).map { |r| r.id }
  mes = MeetingEvent.where( "meeting_session_id IN (?)", ms_ids )
  puts "-> Tot. events #{mes.size}, IDs: #{mes.map{ |r| r.id }.inspect}"
  # Find the list of possibly duplicated MeetingEvents (only the ones from data-import):
  mes_preexisting = mes.select { |r| !r.is_autofilled }
  mes_duplicated  = mes.select { |r| r.is_autofilled }
  puts "   pre-existing, non-autofilled ME: #{mes_preexisting.map{ |r| r.id }}"
  puts "   autofilled with data-import  ME: #{mes_duplicated.map{ |r| r.id }}" if mes_duplicated.size > 0
  if mes_preexisting.size > 0
    puts "   Searching for possible duplicated MEs as candidates for removal..."
  else
    puts "   Everything seems fine..."
  end

  # Foreach pre-existing row, find the extra rows among the possible duplicates:
  mes_preexisting.each do |me_preexisting|
    puts "\r\nChecking duplication for ME #{me_preexisting.id}, event type #{me_preexisting.event_type_id}, heat: #{me_preexisting.heat_type_id}"
    mes_extra = mes_duplicated.select do |me_duplicated|
      ( me_preexisting.event_type_id == me_duplicated.event_type_id ) &&
      ( me_preexisting.heat_type_id == me_duplicated.heat_type_id )
    end
    puts "-> Duplication: #{mes_extra.size}, ME IDs: #{mes_extra.map{ |r| r.id }.inspect}"
    puts "   -- WARNING! -- More than 1 candidate for removal found. You may need to run this task more than once to fix everything." if mes_extra.size > 1
    me_candidate_for_removal = mes_extra.first
# DEBUG
#    puts "   first: #{me_candidate_for_removal.inspect}"
    if me_candidate_for_removal
      check_and_fix_single_meeting_event( me_candidate_for_removal, me_preexisting )
    else
      puts "   No existing duplicates found for this ME. MPRGs are not duplicated. Nothing else to fix here. :-)"
    end
  end
end


# Given a possibly duplicated MeetingEvent instance and another pre-existing MeetingEvent
# (assumed to be pre-existing to the duplicate and, thus, a fit candidate for substitution
# of the copy), this method checks any linked entities, updates the link to the
# duplicate row with the pre-existing candidate and, at the end, removes the
# duplicate.
#
# Entities to be checked for MeetingEvent:
#
# - MeetingProgram
#
def check_and_fix_single_meeting_event( me_duplicated, me_preexisting )
  puts "   ME #{me_duplicated.id} (MS #{me_duplicated.meeting_session_id})  <==[ OVERWRITE with: ]  #{me_preexisting.id} (MS #{me_preexisting.meeting_session_id})"
  # Find the list of possibly duplicated MeetingPrograms:
  mprgs_preexisting = MeetingProgram.where( meeting_event_id: me_preexisting.id )
  mprgs_duplicated  = MeetingProgram.where( meeting_event_id: me_duplicated.id )
  puts "   pre-existing MPRG (@ MS #{me_preexisting.meeting_session_id}): #{mprgs_preexisting.map{ |r| r.id }}"
  puts "   to-be-fixed  MPRG (@ MS #{me_duplicated.meeting_session_id}): #{mprgs_duplicated.map{ |r| r.id }}" if mprgs_duplicated.size > 0

  # Assign the correct (previously existing) MeetingEvent to the "corrupted" MPRGs:
  puts "   Updating all MPRGs @ duplicated ME #{me_duplicated.id}  <==|  " +
       "with pre-existing ME #{me_preexisting.id}..." if mprgs_duplicated.size > 0
  mprgs_duplicated.each do |mprg_duplicated|
    puts "   - updating MPRG #{mprg_duplicated.id}"
    mprg_duplicated.meeting_event_id = me_preexisting.id
    mprg_duplicated.save!
  end
  puts "   -- Check for DELETION required: pre-existing MPRG found. --" if mprgs_preexisting.size > 0

  # Foreach pre-existing row, find the extra rows among the possible duplicates:
  mprgs_preexisting.each do |mprg_preexisting|
    puts "\r\n\tChecking duplication for MPRG #{mprg_preexisting.id}, category_type #{mprg_preexisting.category_type_id}, gender_type: #{mprg_preexisting.gender_type_id}"
    mprgs_extra = mprgs_duplicated.select do |mprg_duplicated|
      ( mprg_preexisting.category_type_id == mprg_duplicated.category_type_id ) &&
      ( mprg_preexisting.gender_type_id == mprg_duplicated.gender_type_id )
    end
    puts "\t-> Duplication: #{mprgs_extra.size}, MPRG IDs: #{mprgs_extra.map{ |r| r.id }.inspect}"
    puts "\t   -- WARNING! -- More than 1 candidate for removal found. You may need to run this task more than once to fix everything." if mprgs_extra.size > 1
    mprg_candidate_for_removal = mprgs_extra.first
# DEBUG
#    puts "   first: #{mprg_candidate_for_removal.inspect}"
    if mprg_candidate_for_removal
      check_and_fix_single_meeting_program( mprg_candidate_for_removal, mprg_preexisting )
    else
      puts "\t   No existing duplicates found for this MPRG. Good. :-)"
    end
  end

  puts "-> Destroying duplicated ME #{me_duplicated.id}"
  me_duplicated.destroy
end
#-- ---------------------------------------------------------------------------
#++


# Given a possibly duplicated MeetingProgram instance and another pre-existing MeetingProgram
# (assumed to be pre-existing to the duplicate and, thus, a fit candidate for substitution
# of the copy), this method checks any linked entities, updates the link to the
# duplicate row with the pre-existing candidate and, at the end, removes the
# duplicate.
#
# Entities to be checked for MeetingProgram:
#
# - MeetingEntry
# - MeetingIndividualResult
# - MeetingRelayResult
# - Passages
# - DataImportMeetingIndividualResult
# - DataImportMeetingRelayResult
#
def check_and_fix_single_meeting_program( mprg_duplicated, mprg_preexisting )
  puts "\t   MPRG #{mprg_duplicated.id} (cat.#{mprg_duplicated.category_type_id}, gender:#{mprg_duplicated.gender_type_id})  <==[ OVERWRITE with: ]  #{mprg_preexisting.id}  (cat.#{mprg_preexisting.category_type_id}, gender:#{mprg_preexisting.gender_type_id})"

  check_and_fix_linked_rows( mprg_duplicated, mprg_preexisting, MeetingIndividualResult, 'MIR' ) do |mir_dup, mir_ok|
    ( mir_ok.swimmer_id == mir_dup.swimmer_id ) && ( mir_ok.team_id == mir_dup.team_id ) &&
    ( mir_ok.minutes == mir_dup.minutes ) && ( mir_ok.seconds == mir_dup.seconds ) &&
    ( mir_ok.hundreds == mir_dup.hundreds )
  end
  check_and_fix_linked_rows( mprg_duplicated, mprg_preexisting, MeetingRelayResult, 'MRR' ) do |mrr_dup, mrr_ok|
    ( mrr_ok.team_id == mrr_dup.team_id ) && ( mrr_ok.standard_points == mrr_dup.standard_points ) &&
    ( mrr_ok.meeting_points == mrr_dup.meeting_points ) &&
    ( mrr_ok.minutes == mrr_dup.minutes ) && ( mrr_ok.seconds == mrr_dup.seconds ) &&
    ( mrr_ok.hundreds == mrr_dup.hundreds )
  end
  check_and_fix_linked_rows( mprg_duplicated, mprg_preexisting, MeetingEntry, 'MENT' ) do |ment_dup, ment_ok|
    ( ment_ok.swimmer_id == ment_dup.swimmer_id ) && ( ment_ok.team_id == ment_dup.team_id ) &&
    ( ment_ok.minutes == ment_dup.minutes ) && ( ment_ok.seconds == ment_dup.seconds ) &&
    ( ment_ok.hundreds == ment_dup.hundreds )
  end
  check_and_fix_linked_rows( mprg_duplicated, mprg_preexisting, Passage, 'PAS' ) do |pas_dup, pas_ok|
    ( pas_ok.swimmer_id == pas_dup.swimmer_id ) && ( pas_ok.team_id == pas_dup.team_id ) &&
    ( pas_ok.minutes == pas_dup.minutes ) && ( pas_ok.seconds == pas_dup.seconds ) &&
    ( pas_ok.hundreds == pas_dup.hundreds )
  end

  check_and_fix_linked_rows( mprg_duplicated, mprg_preexisting, DataImportMeetingIndividualResult, 'DI_MIR' ) do |dimir_dup, dimir_ok|
    ( dimir_ok.swimmer_id == dimir_dup.swimmer_id ) && ( dimir_ok.team_id == dimir_dup.team_id ) &&
    ( dimir_ok.minutes == dimir_dup.minutes ) && ( dimir_ok.seconds == dimir_dup.seconds ) &&
    ( dimir_ok.hundreds == dimir_dup.hundreds )
  end
  check_and_fix_linked_rows( mprg_duplicated, mprg_preexisting, DataImportMeetingRelayResult, 'DI_MRR' ) do |dimrr_dup, dimrr_ok|
    ( dimrr_ok.team_id == dimrr_dup.team_id ) && ( dimrr_ok.standard_points == dimrr_dup.standard_points ) &&
    ( dimrr_ok.meeting_points == dimrr_dup.meeting_points ) &&
    ( dimrr_ok.minutes == dimrr_dup.minutes ) && ( dimrr_ok.seconds == dimrr_dup.seconds ) &&
    ( dimrr_ok.hundreds == dimrr_dup.hundreds )
  end

  puts "\t-> Destroying duplicated MPRG #{mprg_duplicated.id}"
  mprg_duplicated.destroy
end
#-- ---------------------------------------------------------------------------
#++


# Check-and-fix submethod for any entity linked to a MeetingProgram.
# Updates the rows with a correct MeetingProgram link. Erases the duplicates.
#
# The +block_condition+ defines what makes two rows equal and is yield as selecting
# condition while looping among all the possible duplicate rows.
# The +block_condition+ receives 2 parameters, +row_duplicated+ and +row_preexisting+,
# and must return either +true+ or +false+, depending whether these 2 are considered
# as equal or not.
#
def check_and_fix_linked_rows( mprg_duplicated, mprg_preexisting, entity, entity_nickname, &block_condition )
  rows_preexisting = entity.where( meeting_program_id: mprg_preexisting.id )
  rows_duplicated  = entity.where( meeting_program_id: mprg_duplicated.id )
  puts "\t   pre-existing #{entity_nickname}s (@ MPRG #{mprg_preexisting.id}): #{rows_preexisting.map{ |r| r.id }}"
  puts "\t   to-be-fixed  #{entity_nickname}s (@ MPRG #{mprg_duplicated.id}): #{rows_duplicated.map{ |r| r.id }}" if rows_duplicated.size > 0

  # Assign the correct (previously existing) MPRG to the entity's links vs. the "extra" MPRGs:
  puts "\t   Updating all #{entity_nickname}s @ duplicated MPRG #{mprg_duplicated.id}  <==|  " +
       "with pre-existing MPRG #{mprg_preexisting.id}..." if rows_duplicated.size > 0
  rows_duplicated.each do |row_duplicated|
    puts "\t   - updating #{entity_nickname} #{row_duplicated.id}"
    row_duplicated.meeting_program_id = mprg_preexisting.id
    row_duplicated.save!
  end
  puts "\t   -- Check for DELETION required: pre-existing #{entity_nickname}s found. --" if rows_preexisting.size > 0

  # Foreach pre-existing row, find the extra rows among the possible duplicates:
  rows_preexisting.each do |row_preexisting|
    puts "\t\tChecking duplication for #{entity_nickname} #{row_preexisting.id}, PRG #{row_preexisting.meeting_program_id}" +
         ( row_preexisting.respond_to?(:swimmer_id) ? ", swimmer: #{row_preexisting.swimmer_id}" : '' ) +
         ( row_preexisting.respond_to?(:team_id)    ? ", team: #{row_preexisting.team_id}" : '' ) +
         ( row_preexisting.respond_to?(:get_timing) ? ", timing: #{row_preexisting.get_timing}" : '' )
    rows_extra = rows_duplicated.select do |row_duplicated|
      yield( row_duplicated, row_preexisting )
    end
    puts "\t\t-> Duplication: #{rows_extra.size}, #{entity_nickname} IDs: #{rows_extra.map{ |r| r.id }.inspect}"
    puts "\t\t   -- WARNING! -- More than 1 candidate for removal found. You may need to run this task more than once to fix everything." if rows_extra.size > 1
    row_candidate_for_removal = rows_extra.first
# DEBUG
#    puts "\t\t   first: #{row_candidate_for_removal.inspect}"
    if row_candidate_for_removal
      puts "\t\t   -> Destroying duplicated #{entity_nickname} #{row_candidate_for_removal.id}, PRG #{row_candidate_for_removal.meeting_program_id}" +
           ( row_candidate_for_removal.respond_to?(:swimmer_id) ? ", swimmer: #{row_candidate_for_removal.swimmer_id}" : '' ) +
           ( row_candidate_for_removal.respond_to?(:team_id)    ? ", team: #{row_candidate_for_removal.team_id}" : '' ) +
           ( row_candidate_for_removal.respond_to?(:get_timing) ? ", timing: #{row_candidate_for_removal.get_timing}" : '' )
      row_candidate_for_removal.destroy
    else
      puts "\t\t   No existing duplicates found for this #{entity_nickname}. Good. :-)"
    end
  end
end
#-- ---------------------------------------------------------------------------
#++
