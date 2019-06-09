# frozen_string_literal: true

require 'date'
require 'ffaker'

require 'common/validation_error_tools'

FactoryBot.define do
  trait :common_meeting_team_score_fields do
    rank                      { ((rand * 100) % 25).to_i + 1 }
    sum_individual_points     { (rand * 1000).to_i }
    sum_relay_points          { (rand * 1000).to_i }
    sum_team_points           { (rand * 1000).to_i }
    meeting_individual_points { (rand * 1000).to_i }
    meeting_relay_points      { (rand * 1000).to_i }
    meeting_team_points       { (rand * 1000).to_i }
    season_individual_points  { (rand * 1000).to_i }
    season_relay_points       { (rand * 1000).to_i }
    season_team_points        { (rand * 1000).to_i }
    user
  end
  #-- -------------------------------------------------------------------------
  #++

  factory :meeting_team_score do
    team_affiliation
    team                      { team_affiliation.team }
    season                    { team_affiliation.season }
    meeting                   { create(:meeting, season: season) }
    common_meeting_team_score_fields

    before(:create) do |built_instance|
      if built_instance.invalid?
        puts "\r\nFactory def. error => " << ValidationErrorTools.recursive_error_for(built_instance)
        puts built_instance.inspect
      end
    end

    factory :meeting_team_score_with_relay_results do
      after(:create) do |created_instance, _evaluator|
        ms  = create(:meeting_session, meeting: created_instance.meeting)
        me  = create(:meeting_event_relay, meeting_session: ms)
        mps = create_list(
          :meeting_program_relay,
          ((rand * 3) % 2).to_i + 1,
          meeting_event: me
        )
        mps.each do |mp|
          create_list(
            :meeting_relay_result,
            ((rand * 3) % 2).to_i + 1,
            meeting_program: mp,
            team: created_instance.team,
            team_affiliation: created_instance.team_affiliation
          )
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
