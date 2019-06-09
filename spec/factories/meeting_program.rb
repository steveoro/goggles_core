# frozen_string_literal: true

require 'date'
require 'ffaker'

require 'common/validation_error_tools'

FactoryBot.define do
  trait :common_meeting_program_fields do
    event_order               { ((rand * 100) % 25).to_i + 1 }
    gender_type_id            { ((rand * 10) % 2).to_i + 1 } # ASSERT: at least 2 gender types
    user
  end
  #-- -------------------------------------------------------------------------
  #++

  factory :meeting_program do
    common_meeting_program_fields
    meeting_event
    category_type do # Get a coherent category according to the meeting_event:
      meeting_event.event_type.is_a_relay ?
        CategoryType.is_valid.only_relays.sample :
        CategoryType.is_valid.are_not_relays.sample
    end
    pool_type { meeting_event.meeting_session.swimming_pool.pool_type }

    before(:create) do |built_instance|
      if built_instance.invalid?
        puts "\r\nFactory def. error => " << ValidationErrorTools.recursive_error_for(built_instance)
        puts built_instance.inspect
      end
    end

    # This should yield only valid MeetingProgram rows, for individual results (not relays):
    factory :meeting_program_individual do
      pool_type               { PoolType.only_for_meetings.sample }
      meeting_event           { create(:meeting_event_individual) }
      category_type           { CategoryType.is_valid.are_not_relays.sample }
    end

    # This should yield only valid MeetingProgram rows, for relay results (not individual):
    factory :meeting_program_relay do
      pool_type               { PoolType.only_for_meetings.sample }
      meeting_event           { create(:meeting_event_relay) }
      category_type           { CategoryType.is_valid.only_relays.sample }
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
