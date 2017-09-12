require 'date'
require 'ffaker'


FactoryGirl.define do

  factory :data_import_meeting_program do
    data_import_session
    common_meeting_program_fields
    conflicting_id            nil
    import_text               { FFaker::Lorem.paragraph[0..250] }
    data_import_meeting_session_id nil
    meeting_session
    event_type do
      EventsByPoolType.joins(:event_type)
        .only_for_meetings
        .for_pool_type_code( meeting_session.swimming_pool.pool_type.code )
        .where( "event_types.length_in_meters < 3000" )
        .order('RAND()')
        .first.event_type
    end
    category_type do                                # Get a coherent category according to the meeting_event:
      event_type.is_a_relay ?
        CategoryType.is_valid.only_relays.order('RAND()').first :
        CategoryType.is_valid.are_not_relays.order('RAND()').first
    end
    minutes                   { ((rand * 2) % 2).to_i }
    seconds                   { ((rand * 60) % 60).to_i }
    hundreds                  { ((rand * 100) % 100).to_i }
    is_out_of_race            false
    heat_type_id              HeatType::FINALS_ID

    # Make the circular reference between the session and the
    # season valid:
    after(:create) do |created_instance, evaluator|
      created_instance.data_import_session.season = created_instance.meeting_session.season
    end

    factory :data_import_meeting_program_individual do
      event_type do
        EventsByPoolType.joins(:event_type)
          .only_for_meetings
          .not_relays
          .for_pool_type_code( meeting_session.swimming_pool.pool_type.code )
          .where( "event_types.length_in_meters < 3000" )
          .order('RAND()')
          .first.event_type
      end
      category_type do                              # Get a coherent category according to the meeting_event:
        CategoryType.is_valid.are_not_relays.order('RAND()').first
      end
    end

    factory :data_import_meeting_program_relay do
      event_type do
        EventsByPoolType.joins(:event_type)
          .only_for_meetings
          .are_relays
          .for_pool_type_code( meeting_session.swimming_pool.pool_type.code )
          .where( "event_types.length_in_meters < 3000" )
          .order('RAND()')
          .first.event_type
      end
      category_type do                              # Get a coherent category according to the meeting_event:
        CategoryType.is_valid.only_relays.order('RAND()').first
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
