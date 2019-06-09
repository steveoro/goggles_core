# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :data_import_passage do
    data_import_session
    conflicting_id            { nil }
    import_text               { FFaker::Lorem.paragraph[0..250] }

    meeting_individual_result
    meeting_program           { meeting_individual_result.meeting_program }

    reaction_time             { rand.round(2) }
    minutes                   { 0 }
    seconds                   { ((rand * 59) % 59).to_i }  # Forced not to use 59
    hundreds                  { ((rand * 99) % 99).to_i }  # Forced not to use 99

    swimmer                   { meeting_individual_result.swimmer }
    team                      { meeting_individual_result.team }
    user
    # The following column uses the pre-loaded seed records:
    passage_type_id { ((rand * 20) % 20).to_i + 1 }

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
