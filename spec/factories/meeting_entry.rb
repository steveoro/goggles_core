# Read about factories at https://github.com/thoughtbot/factory_girl
require 'common/validation_error_tools'


FactoryGirl.define do
  factory :meeting_entry do
    meeting_program
    badge do
      create( :badge, season: SeasonFactoryTools.get_season_with_full_categories() )
    end
    team              { badge.team }
    team_affiliation  { badge.team_affiliation }
    swimmer           { badge.swimmer }

    sequence( :start_list_number )

    minutes                   0
    seconds                   { ((rand * 60) % 60).to_i }
    hundreds                  { ((rand * 100) % 100).to_i }

    before(:create) do |built_instance|
      if built_instance.invalid?
        puts "\r\nFactory def. error => " << ValidationErrorTools.recursive_error_for( built_instance )
        puts built_instance.inspect
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
