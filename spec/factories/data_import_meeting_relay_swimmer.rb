# Read about factories at https://github.com/thoughtbot/factory_bot
require 'common/validation_error_tools'


FactoryBot.define do
  factory :data_import_meeting_relay_swimmer do
    data_import_session
    conflicting_id            nil
    import_text               { FFaker::Lorem.paragraph[0..250] }

    meeting_relay_result
    # The following column uses the pre-loaded seed records:
    stroke_type  do
      EventsByPoolType.only_for_meetings
        .are_relays
        .all.sort{ rand - 0.5 }[0]
        .stroke_type
    end

    minutes                   0
    seconds                   { ((rand * 59) % 59).to_i }  # Forced not to use 59
    hundreds                  { ((rand * 99) % 99).to_i }  # Forced not to use 99

    team                      { meeting_relay_result.team }
    badge do
      create(
        :badge,
        season: meeting_relay_result.team_affiliation.season,
        team: meeting_relay_result.team
      )
    end
    swimmer                   { badge.swimmer }

    user

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
