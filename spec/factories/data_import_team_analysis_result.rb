# frozen_string_literal: true

require 'date'
require 'ffaker'

FactoryBot.define do
  factory :data_import_team_analysis_result do
    data_import_session
    analysis_log_text         { FFaker::Lorem.paragraph[0..128] }
    sql_text                  ''

    desired_season_id         { create(:season).id }
    chosen_team_id            nil
    searched_team_name        nil

    team_match_name           nil
    team_match_score          9.9
    best_match_name           nil
    best_match_score          9.9

    after(:create) do |created_instance, _evaluator|
      team = create(:team)
      created_instance.chosen_team_id     = team.id
      created_instance.searched_team_name = team.name
      created_instance.team_match_name    = team.name
      created_instance.best_match_name    = team.name
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
