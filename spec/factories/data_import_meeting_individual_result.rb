require 'date'
require 'ffaker'


FactoryGirl.define do

  factory :data_import_meeting_individual_result do
    data_import_session
    conflicting_id            nil
    import_text               { FFaker::Lorem.paragraph[0..250] }
    common_meeting_individual_result_fields
    meeting_program_id        nil
    data_import_swimmer_id    nil
    data_import_team_id       nil
    data_import_badge_id      nil

    badge                     { create(:badge) }
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
    after(:create) do |created_instance, evaluator|
      created_instance.data_import_session.season = created_instance.data_import_meeting_program.meeting_session.season
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
#-- ---------------------------------------------------------------------------
#++
