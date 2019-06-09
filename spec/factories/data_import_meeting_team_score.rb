# frozen_string_literal: true

require 'date'
require 'ffaker'

FactoryBot.define do
  factory :data_import_meeting_team_score do
    data_import_session
    conflicting_id            { nil }
    import_text               { FFaker::Lorem.paragraph[0..250] }
    team_affiliation
    team                      { team_affiliation.team }
    data_import_team_id       { nil }
    season                    { team_affiliation.season }
    meeting                   { create(:meeting, season: season) }
    data_import_meeting_id    { nil }
    common_meeting_team_score_fields

    factory :data_import_meeting_team_score_with_relay_results do
      after(:create) do |created_instance, _evaluator|
        ms  = create(:meeting_session, meeting: created_instance.meeting)
        me  = create(:meeting_event_relay, meeting_session: ms)
        mps = create_list(
          :data_import_meeting_program_relay,
          ((rand * 3) % 2).to_i + 1,
          meeting_session: ms,
          event_type: me.event_type
        )
        mps.each do |mp|
          create_list(
            :data_import_meeting_relay_result,
            ((rand * 3) % 2).to_i + 1,
            data_import_meeting_program: mp,
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
