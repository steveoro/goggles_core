# frozen_string_literal: true

require 'date'
require 'ffaker'

require 'common/validation_error_tools'

FactoryBot.define do
  trait :meeting_event_random do
    event_order               { ((rand * 100) % 15).to_i + 1 }
    meeting_session
    event_type_id do # This will include also relays
      EventsByPoolType.only_for_meetings
                      .for_pool_type_code(meeting_session.swimming_pool.pool_type.code)
                      .distance_more_than(50).distance_less_than(1500)
                      .sample.event_type_id
    end
    heat_type { HeatType.all.sample }
    user
  end
  #-- -------------------------------------------------------------------------
  #++

  factory :meeting_event do
    meeting_event_random

    before(:create) do |built_instance|
      if built_instance.invalid?
        puts "\r\nFactory def. error => " << ValidationErrorTools.recursive_error_for(built_instance)
        puts built_instance.inspect
      end
    end

    # This should yield only valid MeetingEvent rows, for individual results (not relays):
    factory :meeting_event_individual do
      event_type do
        EventsByPoolType.only_for_meetings.not_relays
                        .for_pool_type_code(meeting_session.swimming_pool.pool_type.code)
                        .distance_more_than(50).distance_less_than(1500).sample.event_type
      end
    end

    # This should yield only valid MeetingEvent rows, for relay results (not individual):
    factory :meeting_event_relay do
      event_type do
        EventsByPoolType.only_for_meetings.are_relays
                        .for_pool_type_code(meeting_session.swimming_pool.pool_type.code).sample.event_type
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
