# frozen_string_literal: true

require 'date'
require 'ffaker'

FactoryBot.define do
  factory :data_import_meeting_relay_result do
    data_import_session
    conflicting_id            nil
    import_text               { FFaker::Lorem.paragraph[0..250] }
    common_meeting_relay_result_fields
    association :data_import_meeting_program, factory: :data_import_meeting_program_relay
    meeting_program_id        nil
    data_import_team_id       nil
    team_affiliation_id       nil # (If needed, this must be set externally to work: too much hierachy-tree dependency between needed entities)

    # Make the circular reference between the session and the
    # season valid:
    after(:create) do |created_instance, _evaluator|
      created_instance.data_import_session.season = created_instance.data_import_meeting_program.meeting_session.season
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
#-- ---------------------------------------------------------------------------
#++
