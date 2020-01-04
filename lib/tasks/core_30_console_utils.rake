# frozen_string_literal: true

require 'date'
require 'rubygems'
require 'find'
require 'fileutils'

require 'framework/console_logger'

#
# = Command line utilities
#
#   - Goggles framework vers.:  5.00
#   - Author: Leega
#
#   Holds all things you shuold remember to ask to a DB or simply you should know,
#   but sadly your internal memory buffer still refuses to retain. :-P
#
#   (ASSUMES TO BE rakeD inside Rails.root)
#

# rubocop:disable Metrics/BlockLength
namespace :ut do
  desc <<~DESC
    Find meetings for a given code
    Resulting log files are stored into '#{LOG_DIR}'.

    Presents an header date ordered list
    of meetings with code matching to search criteria

    Options: code=<meeting_code> log_dir=#{LOG_DIR}]

    - 'code'     meeting code or part of meeting code to search for.
    - 'log_dir'  allows to override the default log dir destination.

  DESC
  task :meeting_find_by_code do |_t|
    puts '*** ut:meeting_find_by_code ***'
    meeting_code    = ENV.include?('code') ? ENV['code'] : nil
    rails_config    = Rails.configuration # Prepare & check configuration:
    db_name         = rails_config.database_configuration[Rails.env]['database']
    db_user         = rails_config.database_configuration[Rails.env]['username']
    db_pwd          = rails_config.database_configuration[Rails.env]['password']
    log_dir         = ENV.include?('log_dir') ? ENV['log_dir'] : LOG_DIR

    # Verify parameters
    unless meeting_code
      puts('This needs a code, or a part of a code to search for.')
      exit
    end

    # Display some info:
    puts "DB name:          #{db_name}"
    puts "DB user:          #{db_user}"
    puts "log_dir:          #{log_dir}"
    puts "\r\n"
    logger = ConsoleLogger.new

    puts 'Requiring Rails environment to allow usage of any Model...'
    require 'rails/all'
    require Rails.root.join('config', 'environment')

    # Search meetings
    meeting_found = 0
    logger.info("\r\nSearch meetings with code like '%#{meeting_code}%'")
    logger.info("\r\n<------------------------------------------------------------>\r\n")
    Meeting.where("code like '%#{meeting_code}%'").sort_by_date.each do |meeting|
      meeting_found += 1
      pool_type = meeting.get_pool_type
      logger.info(
        "\r\n#{meeting.id} - #{meeting.get_meeting_date} #{meeting.get_full_name} (#{meeting.code} #{pool_type&.code} " \
        "- #{meeting.get_data_import_file_name})#{': OK' if meeting.are_results_acquired}" \
        "#{': Annullato' if meeting.is_cancelled}\r\n"
      )
    end

    # If no meetings found log warning
    logger.info("\r\nNo meetings found with #{meeting_code}. Perhaps you mispelled it.\r\n") if meeting_found == 0
    logger.info("\r\n\r\n")
  end
  #-- -------------------------------------------------------------------------
  #++

  desc <<~DESC
    Find team matching a given name part
    Resulting log files are stored into '#{LOG_DIR}'.

    Search teams and team affiliations for teams
    which names contains the searc string

    Options: name=<team_name_part> log_dir=#{LOG_DIR}]

    - 'name'     team name or part of team name to search for.
    - 'log_dir'  allows to override the default log dir destination.

  DESC
  task :team_find_by_name do |_t|
    puts '*** ut:team_find_by_name ***'
    team_name       = ENV.include?('name') ? ENV['name'] : nil
    rails_config    = Rails.configuration # Prepare & check configuration:
    db_name         = rails_config.database_configuration[Rails.env]['database']
    db_user         = rails_config.database_configuration[Rails.env]['username']
    db_pwd          = rails_config.database_configuration[Rails.env]['password']
    log_dir         = ENV.include?('log_dir') ? ENV['log_dir'] : LOG_DIR

    # Verify parameters
    unless team_name
      puts('This needs a team name, or a part of a team name to search for.')
      exit
    end

    # Display some info:
    puts "DB name:          #{db_name}"
    puts "DB user:          #{db_user}"
    puts "log_dir:          #{log_dir}"
    puts "\r\n"
    logger = ConsoleLogger.new

    puts 'Requiring Rails environment to allow usage of any Model...'
    require 'rails/all'
    require Rails.root.join('config', 'environment')

    # Search meetings
    teams_found = []
    logger.info("\r\nSearch teams with names like '%#{team_name}%'")
    logger.info("\r\n<------------------------------------------------------------>\r\n")
    Team.where("name like '%#{team_name}%' or editable_name like '%#{team_name}%' or name_variations like '%#{team_name}%'").each do |team|
      teams_found << team
    end
    TeamAffiliation.where("name like '%#{team_name}%'").each do |team_affiliation|
      teams_found << team_affiliation.team unless teams_found.include?(team_affiliation.team)
    end

    # Log teams found and affiliations
    teams_found.sort { |a, b| a.name <=> b.name }.each do |team|
      logger.info("\r\n#{team.id} - #{team.get_verbose_name} (#{team.name} / #{team.editable_name})")
      logger.info('<------------------------------------------------------------>')
      team.team_affiliations.sort_team_affiliation_by_season('ASC').each do |team_affiliation|
        logger.info(" - #{team_affiliation.season_id}: #{team_affiliation.name} (#{team_affiliation.id})")
      end
      logger.info("\r\n\r\n")
    end

    # If no meetings found log warning
    logger.info("\r\nNo teams found with #{team_name}. Perhaps you mispelled it.\r\n") if teams_found.empty?
    logger.info("\r\n\r\n")
  end
  #-- -------------------------------------------------------------------------
  #++

  desc <<~DESC
    Find meetings with ne results acquired for a given season
    Resulting log files are stored into '#{LOG_DIR}'.

    Presents an header date ordered list
    of meetings without results acquired for the given season

    Options: season=<season_id> [past=false log_dir=#{LOG_DIR}]

    - 'season'   id of teh season to search for.
    - 'past'     limt the search to meetings with past scheduled date
    - 'log_dir'  allows to override the default log dir destination.

  DESC
  task :meetings_without_results do |_t|
    puts '*** ut:meetings_without_results ***'
    season_id       = ENV.include?('season')  ? ENV['season'] : nil
    past            = ENV.include?('past')    ? ENV['past'] == 'true' : false
    rails_config    = Rails.configuration # Prepare & check configuration:
    db_name         = rails_config.database_configuration[Rails.env]['database']
    db_user         = rails_config.database_configuration[Rails.env]['username']
    db_pwd          = rails_config.database_configuration[Rails.env]['password']
    log_dir         = ENV.include?('log_dir') ? ENV['log_dir'] : LOG_DIR

    logger = ConsoleLogger.new
    logger.info( "Requiring Rails environment to allow usage of any Model..." )
    require Rails.root.join('config', 'environment')
    require 'rails/all'

    # Verify parameters
    unless season_id && Season.exists?(id: season_id)
      puts "\r\n"
      puts('This needs a valid season id to search for.')
      puts "\r\n"
      exit
    end

    # Display some info:
    puts "DB name:          #{db_name}"
    puts "DB user:          #{db_user}"
    puts "log_dir:          #{log_dir}"
    puts "\r\n"

    season = Season.find(season_id)

    # Creates a csv file
    titles = %w[id date meeting code import_data_file effective_date days_to_move]
    csv_file = File.open("#{LOG_DIR}/season_#{season_id}_meets_without_results.csv", 'w')
    csv_file.puts titles.join(';')

    # Search meetings
    meeting_found = 0
    logger.info("\r\nSearch meetings without results for season #{season.get_full_name}")
    logger.info("\r\n<------------------------------------------------------------>\r\n")
    season.meetings.is_not_cancelled.has_not_results.sort_by_date.each do |meeting|
      next unless !past || !meeting.meeting_date_to_iso || meeting.meeting_date_to_iso <= Time.zone.now.strftime('%Y%m%d')

      meeting_found += 1
      pool_type = meeting.get_pool_type
      logger.info(
        "\r\n#{meeting.id} - #{meeting.get_meeting_date} #{meeting.get_full_name} (#{meeting.code})" \
        " #{pool_type&.code} #{meeting.meeting_individual_results.count if meeting.meeting_individual_results.exists?} " \
        "-> #{meeting.get_data_import_file_name}\r\n"
      )

      meeting_row = ''
      meeting_row += "#{meeting.id};"
      meeting_row += "#{meeting.get_meeting_date};"
      meeting_row += "#{meeting.get_full_name};"
      meeting_row += "#{meeting.code};"
      meeting_row += "#{meeting.get_data_import_file_name};"
      meeting_row += ';'
      csv_file.puts meeting_row
    end

    # If no meetings found log warning
    if meeting_found == 0
      logger.info("\r\nNo meetings without results found for season #{season.get_full_name}\r\n")
    else
      logger.info("\r\nFound #{meeting_found} meetings without results for season #{season.get_full_name}\r\n")
    end
    logger.info("\r\n\r\n")
  end
  #-- -------------------------------------------------------------------------
  #++

  desc <<~DESC
    Find meetings scheduled on next given day number
    from systema date (eventually offset)

    Presents an header date ordered list
    of meetings with scheduled_date between
    system date and the date obtained adding given day number
    Default day number is 7

    Options: [from=0 days=7]

    - 'from'     number of days to add to system date
    - 'days'     number of days to scan

  DESC
  task :meetings_on_next_days do |_t|
    puts '*** ut:meetings_on_next_days ***'
    from            = ENV.include?('from')  ? ENV['from'].to_i : 0
    days            = ENV.include?('days')  ? ENV['days'].to_i : 7
    rails_config    = Rails.configuration # Prepare & check configuration:
    db_name         = rails_config.database_configuration[Rails.env]['database']
    db_user         = rails_config.database_configuration[Rails.env]['username']
    db_pwd          = rails_config.database_configuration[Rails.env]['password']

    # Display some info:
    puts "DB name:          #{db_name}"
    puts "DB user:          #{db_user}"
    puts "\r\n"
    logger = ConsoleLogger.new

    puts 'Requiring Rails environment to allow usage of any Model...'
    require 'rails/all'
    require Rails.root.join('config', 'environment')

    begin_date = Date.today + from
    end_date = begin_date + days

    # Search meetings
    meeting_found = 0
    logger.info("\r\nSearch meetings with header date between #{begin_date} and #{end_date}")
    logger.info("\r\n<------------------------------------------------------------>\r\n")
    Meeting.where(['header_date between ? and ?', begin_date, end_date]).sort_by_date.each do |meeting|
      meeting_found += 1
      pool_type = meeting.get_pool_type
      logger.info(
        "\r\n#{meeting.id} - #{meeting.get_meeting_date} #{meeting.get_full_name} (#{meeting.code}) #{pool_type&.code} " \
        "#{meeting.meeting_individual_results.count if meeting.meeting_individual_results.exists?} -> " \
        "#{meeting.get_data_import_file_name} #{'- ANNULLATO' if meeting.is_cancelled}\r\n"
      )
    end

    # If no meetings found log warning
    if meeting_found == 0
      logger.info("\r\nNo meetings with header date between #{begin_date} and #{end_date}\r\n")
    else
      logger.info("\r\nFound #{meeting_found} meetings with header date between #{begin_date} and #{end_date}\r\n")
    end
    logger.info("\r\n\r\n")
  end
  #-- -------------------------------------------------------------------------
  #++

  desc <<~DESC
    Show meeting schedule
    Resulting log files are stored into '#{LOG_DIR}'.

    Presents an event_order ordered list
    of events scheduled for the meeting matching to search criteria

    Options: meeting=<meeting_id> log_dir=#{LOG_DIR}]

    - 'meeting'  meeting id of meeting to search for.
    - 'log_dir'  allows to override the default log dir destination.

  DESC
  task :meeting_schedule do |_t|
    puts '*** ut:meeting_schedule ***'
    meeting_id      = ENV.include?('meeting') ? ENV['meeting'] : nil
    rails_config    = Rails.configuration # Prepare & check configuration:
    db_name         = rails_config.database_configuration[Rails.env]['database']
    db_user         = rails_config.database_configuration[Rails.env]['username']
    db_pwd          = rails_config.database_configuration[Rails.env]['password']
    log_dir         = ENV.include?('log_dir') ? ENV['log_dir'] : LOG_DIR

    # Verify parameters
    unless meeting_id
      puts('This needs a meeting id to search for.')
      exit
    end

    # Display some info:
    puts "DB name:          #{db_name}"
    puts "DB user:          #{db_user}"
    puts "log_dir:          #{log_dir}"
    puts "\r\n"
    logger = ConsoleLogger.new

    puts 'Requiring Rails environment to allow usage of any Model...'
    require 'rails/all'
    require Rails.root.join('config', 'environment')

    # Search meetings
    logger.info("\r\nSearch meeting schedule for '%#{meeting_id}%'")
    logger.info("\r\n<------------------------------------------------------------>\r\n")
    meeting = Meeting.find(meeting_id)
    unless meeting
      puts('This needs a valid meeting id to search for.')
      exit
    end

    ms = MeetingSchedule.new( meeting )
    ms.retrieve_schedule_data
    msdao = MeetingScheduleDAODecorator.new( ms.set_meeting_schedule_dao )
    #msdao = ms.set_meeting_schedule_dao.decorate
    logger.info("\r\n#{msdao.get_meeting_header}")

    # Cycle meeting sessions
    msdao.get_session_keys.each do |session_key|
      # Session info
      mss = MeetingScheduleDAODecorator.new( msdao.get_session( session_key ))
      logger.info(
        "- #{mss.session_order}. #{mss.date_to_s(mss.scheduled_date)} " \
        "#{mss.get_pool_header}: " \
        "#{mss.warm_up_time}/#{mss.begin_time} -> #{mss.session_id}\r\n"
      )
      # Cycle session events
      mss.get_event_keys.each do |event_key|
        # Event info
        #msse = MeetingScheduleDAODecorator.new( mss.get_event( event_key ))
        msse = mss.get_event( event_key )
        logger.info(
          "  - #{msse.event_order}. #{msse.event_code} -> #{msse.event_id}\r\n"
        )
      end
    end

    logger.info("\r\n\r\n")
  end
  #-- -------------------------------------------------------------------------
  #++
end
# rubocop:enable Metrics/BlockLength
# =============================================================================
