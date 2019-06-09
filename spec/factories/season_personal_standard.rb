# frozen_string_literal: true

require 'date'
require 'ffaker'

FactoryBot.define do
  factory :season_personal_standard do
    season
    swimmer
    pool_type_id              { PoolType.only_for_meetings[((rand * 100) % PoolType.only_for_meetings.count).to_i].id } # From seeds
    event_type_id             { EventType.are_not_relays[((rand * 100) % EventType.are_not_relays.count).to_i].id } # From seeds
    minutes                   { ((rand * 100) % 2).to_i }
    seconds                   { ((rand * 60) % 60).to_i }
    hundreds                  { ((rand * 100) % 100).to_i }

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
