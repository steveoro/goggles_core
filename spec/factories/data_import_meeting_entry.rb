# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot
require 'common/validation_error_tools'

FactoryBot.define do
  factory :data_import_meeting_entry do
    data_import_session
    conflicting_id            { nil }
    import_text               { FFaker::Lorem.paragraph[0..250] }

    sequence(:start_list_number)

    minutes                   { 0 }
    seconds                   { ((rand * 60) % 60).to_i }
    hundreds                  { ((rand * 100) % 100).to_i }
    meeting_program_id        { nil }
    data_import_swimmer_id    { nil }
    data_import_team_id       { nil }
    data_import_badge_id      { nil }
    user_id                   { 1 }

    badge do
      create(:badge, season: SeasonFactoryTools.get_season_with_full_categories)
    end
    swimmer                   { badge.swimmer }
    team                      { badge.team }
    team_affiliation          { badge.team_affiliation }
    data_import_meeting_program do
      create(
        :data_import_meeting_program_individual,
        gender_type_id: swimmer.gender_type_id
      )
    end

    athlete_name              { swimmer.complete_name }
    team_name                 { team.name }
    athlete_badge_number      { badge.number }
    year_of_birth             { swimmer.year_of_birth }

    # Make the circular reference between the session and the
    # season valid:
    after(:create) do |created_instance, _evaluator|
      created_instance.data_import_session.season = created_instance.data_import_meeting_program.meeting_session.season
    end

    before(:create) do |built_instance|
      if built_instance.invalid?
        puts "\r\nFactory def. error => " << ValidationErrorTools.recursive_error_for(built_instance)
        puts built_instance.inspect
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
