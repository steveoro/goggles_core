# frozen_string_literal: true

require 'date'
require 'rubygems'
require 'fileutils'

#
# = DB-maintenance tasks
#
#   - Goggles framework vers.:  4.00.773
#   - author: Leega, Steve A.
#
#   (ASSUMES TO BE rakeD inside Rails.root)
#
#-- ---------------------------------------------------------------------------
#++

namespace :db do
  desc <<~DESC
      Saves season team ranking of given seasons or season types in a permanent structure.
    This will alter the DB but it can be safely re-run since it uses updates.

      Options: season_ids='season1_id[, season2_id, ...]' (takes precedence over the following)
               season_type=['MASCSI'|'MASFIN'|...]
  DESC
  task :save_season_team_ranking do
    puts "\r\n*** db:save_season_team_ranking ***"

    # Environment setup
    rails_config  = Rails.configuration # Prepare & check configuration:
    db_name       = rails_config.database_configuration[Rails.env]['database']
    db_user       = rails_config.database_configuration[Rails.env]['username']
    db_pwd        = rails_config.database_configuration[Rails.env]['password']
    db_host       = rails_config.database_configuration[Rails.env]['host']
    puts 'Requiring Rails environment to allow usage of any Model...'
    require 'rails/all'
    require Rails.root.join('config', 'environment')

    # Verify parameters
    raise ArgumentError, "Needs at least a 'season_ids' or a 'season_type' parameter" unless ENV.include?('season_ids') || ENV.include?('season_type')

    # Display some info:
    puts "DB host: #{db_host}"
    puts "DB name: #{db_name}"
    puts "DB user: #{db_user}"
    season_ids = []
    if ENV.include?('season_ids')
      season_ids = ENV['season_ids'].split(',')
      # Check if all seasons IDs are valid ([Steve] This is quite an useless check, since an error'd have been thrown anyway)
      season_ids.each do |id|
        raise ArgumentError, "Season #{id} not found!" unless Season.find(id)
      end
    else
      season_ids = Season.includes(:season_type).where('season_types.code' => ENV['season_type']).map(&:id)
      puts "SeasonType code: #{ENV['season_type']}"
    end
    puts "Season IDs to be processed: #{season_ids.inspect}"
    puts "\r\n---------------- 8< -------------------"

    season_saved = 0
    season_ids.each do |id|
      if season = Season.find(id)
        puts "\r\nSaving team ranking for season '#{season.get_full_name}'..."
        # Creates the season ranking and save teh first 3 elements
        if ChampionshipRankingCalculator.new(season).save_computed_season_rank
          saved_data = season.computed_season_ranking
          puts 'Season ranking correctly stored:'
          saved_data.each do |computed_season_rank|
            puts "#{computed_season_rank.rank}. #{computed_season_rank.team.name}: #{computed_season_rank.total_points}"
          end
          season_saved += 1
        else
          puts "\r\nError occurred during saving data process!"
          puts "\r\nTask failed!"
        end
      else
        puts "\r\nSeason #{season_id} misteriously disappers!"
        puts 'Task stopped!'
        raise ArgumentError, 'Season not found'
      end
    end
    puts "\r\nSeason(s) saved: #{season_saved}"
    puts 'Done'
  end
  #-- -------------------------------------------------------------------------
  #++

  desc <<~DESC
      Saves a specified text file into the Meeting invitation/manifest column.
    The text file is read integrally and saved in the column for the row
    having the specified ID.

      Options: meeting_id=<meeting_id>
               file=<path_to_file>
               [warm_up=<warm_up_time> begin=<begin_time> [day_part=<day_part_type.code>]]

    If 'warm_up' and 'begin' are specified, the first meeting_session of
    the meeting will be updated with the specified values.

    'day_part' defaults to 'P'.
  DESC
  task :store_meeting_manifest do
    puts "\r\n*** db:store_meeting_manifest ***"
    # Environment setup
    rails_config  = Rails.configuration # Prepare & check configuration:
    db_name       = rails_config.database_configuration[Rails.env]['database']
    db_user       = rails_config.database_configuration[Rails.env]['username']
    db_pwd        = rails_config.database_configuration[Rails.env]['password']
    db_host       = rails_config.database_configuration[Rails.env]['host']
    # Verify parameters
    unless ENV.include?('meeting_id') && ENV.include?('file')
      puts("It needs at least a 'meeting_id' and a 'file' parameter.")
      exit
    end
    puts 'Requiring Rails environment to allow usage of any Model...'
    require 'rails/all'
    require Rails.root.join('config', 'environment')

    # Display some info:
    puts "DB host: #{db_host}"
    puts "DB name: #{db_name}"
    puts "DB user: #{db_user}"
    meeting_id = ENV['meeting_id'].to_i
    full_pathname = ENV['file']
    meeting = Meeting.find(meeting_id)
    puts "Meeeting: ID #{meeting.id}, code: #{meeting.code}, header date: #{meeting.header_date}, '#{meeting.description}'"
    puts "Full pathname: #{full_pathname}"
    text_file_contents = File.read(full_pathname)
    puts "File size: #{text_file_contents.size}"
    puts 'Processing meeting row...'
    meeting.invitation = text_file_contents
    meeting.has_invitation = true
    meeting.is_confirmed = true
    meeting.save!

    warm_up_time = ENV.include?('warm_up') ? ENV['warm_up'] : nil
    begin_time = ENV.include?('begin') ? ENV['begin'] : nil
    day_part_type_code = ENV.include?('day_part') ? ENV['day_part'] : 'P'

    unless warm_up_time.nil? || begin_time.nil?
      puts 'Updating also warm_up, begin_time & day_part_type_id (just for the 1st session)...'
      ms = meeting.meeting_sessions.first
      ms.warm_up_time = warm_up_time
      ms.begin_time = begin_time
      ms.day_part_type_id = DayPartType.find_by(code: day_part_type_code).id
      ms.save!
    end
    puts 'Done'
  end

  desc <<~DESC
      Saves a specified text file into the Season.rules column.
    The text file is read integrally and saved in the column for the row
    having the specified ID.

      Options: season_id=<season_id>
               file=<path_to_file>
  DESC
  task :store_season_rules do
    puts "\r\n*** db:store_season_rules ***"
    # Environment setup
    rails_config  = Rails.configuration # Prepare & check configuration:
    db_name       = rails_config.database_configuration[Rails.env]['database']
    db_user       = rails_config.database_configuration[Rails.env]['username']
    db_pwd        = rails_config.database_configuration[Rails.env]['password']
    db_host       = rails_config.database_configuration[Rails.env]['host']
    # Verify parameters
    unless ENV.include?('season_id') && ENV.include?('file')
      puts("Needs at least a 'season_id' and a 'file' parameter")
      exit
    end
    puts 'Requiring Rails environment to allow usage of any Model...'
    require 'rails/all'
    require Rails.root.join('config', 'environment')

    # Display some info:
    puts "DB host: #{db_host}"
    puts "DB name: #{db_name}"
    puts "DB user: #{db_user}"
    season_id = ENV['season_id'].to_i
    full_pathname = ENV['file']
    season = Season.find(season_id)
    puts "Season: ID #{season.id}, header year: #{season.header_year}, '#{season.description}'"
    puts "Full pathname: #{full_pathname}"
    text_file_contents = File.read(full_pathname)
    puts "File size: #{text_file_contents.size}"
    puts 'Processing...'
    season.rules = text_file_contents
    season.save!
    puts 'Done'
  end
  #-- -------------------------------------------------------------------------
  #++
end
#-- ---------------------------------------------------------------------------
#++
