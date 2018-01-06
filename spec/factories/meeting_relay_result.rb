require 'date'
require 'ffaker'

require 'common/validation_error_tools'


FactoryBot.define do

  trait :common_meeting_relay_result_fields do
    rank                      { ((rand * 100) % 25).to_i + 1 }
    is_play_off               true
    is_out_of_race            false
    is_disqualified           false
    standard_points           { (rand * 1000).to_i}
    meeting_points            { standard_points }
    minutes                   { ((rand * 4) % 4).to_i }
    seconds                   { ((rand * 60) % 60).to_i }
    hundreds                  { ((rand * 100) % 100).to_i }
    team
    relay_header              { FFaker::Lorem.paragraph[0..50] }
    reaction_time             { rand.round(2) }
    entry_minutes             { ((rand * 4) % 4).to_i }
    entry_seconds             { ((rand * 60) % 60).to_i }
    entry_hundreds            { ((rand * 100) % 100).to_i }
    entry_time_type_id        { EntryTimeType::LAST_RACE_ID }
    # No disqualify:
    disqualification_code_type nil # { DisqualificationCodeType.all.sort{ rand - 0.5 }[0] }
    user
  end
  #-- -------------------------------------------------------------------------
  #++


  factory :meeting_relay_result do
    association :meeting_program, factory: :meeting_program_relay
    common_meeting_relay_result_fields
    team_affiliation do
      create(
        :team_affiliation,
        team:   team,
        season: meeting_program.season # (by ActiveRecord relation)
      )
    end

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
#-- ---------------------------------------------------------------------------
#++
