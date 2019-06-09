# frozen_string_literal: true

require 'date'
require 'ffaker'

require 'common/validation_error_tools'

FactoryBot.define do
  trait :common_meeting_session_fields do
    description               'FINALS'
    session_order             { ((rand * 100) % 4).to_i + 1 }
    meeting
    # The following column uses the pre-loaded seed records:
    day_part_type_id          { ((rand * 100) % 4).to_i + 1 } # ASSERT: at least 4 timing types
    scheduled_date            { Date.today }
    warm_up_time              { Time.zone.now }
    begin_time                { Time.zone.now }
    swimming_pool # this will yield pools with type "only_for_meetings"
    user
  end
  #-- -------------------------------------------------------------------------
  #++

  factory :meeting_session do
    common_meeting_session_fields

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
