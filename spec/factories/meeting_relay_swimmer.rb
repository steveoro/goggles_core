# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot
require 'common/validation_error_tools'

FactoryBot.define do
  factory :meeting_relay_swimmer do
    meeting_relay_result
    # The following column uses the pre-loaded seed records:
    stroke_type do
      EventsByPoolType.only_for_meetings
                      .are_relays
                      .all.min { rand - 0.5 }
                      .stroke_type
    end

    relay_order               { ((rand * 4) % 4).to_i }

    reaction_time             { ((rand * 59) % 59).to_i }  # Forced not to use 59
    minutes                   { 0 }
    seconds                   { ((rand * 59) % 59).to_i }  # Forced not to use 59
    hundreds                  { ((rand * 99) % 99).to_i }  # Forced not to use 99

    badge do
      create(
        :badge,
        season: meeting_relay_result.team_affiliation.season,
        team: meeting_relay_result.team
      )
    end
    swimmer { badge.swimmer }

    user

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
