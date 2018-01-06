require 'date'
require 'ffaker'

require 'common/validation_error_tools'


FactoryBot.define do

  factory :individual_record do
    meeting_individual_result

    pool_type_id        { meeting_individual_result.meeting_program.pool_type_id }
    event_type_id       { meeting_individual_result.meeting_program.meeting_event.event_type_id }
    category_type_id    { meeting_individual_result.meeting_program.category_type_id }
    gender_type_id      { meeting_individual_result.meeting_program.gender_type_id }
    record_type_id      7  # Assumes always federation record (from seeds)

    minutes             { meeting_individual_result.minutes }
    seconds             { meeting_individual_result.seconds }
    hundreds            { meeting_individual_result.hundreds }
    is_team_record      { (rand * 100).to_i.even? }

    swimmer             { meeting_individual_result.swimmer }
    team                { meeting_individual_result.team }
    season_id           { meeting_individual_result.season.id }
    federation_type     { season.season_type.federation_type }

    before(:create) do |built_instance|
      if built_instance.invalid?
        puts "\r\nFactory def. error => " << ValidationErrorTools.recursive_error_for( built_instance )
        puts built_instance.inspect
      end
    end
  end
end
#-- ---------------------------------------------------------------------------
#++


# Quick NameSpace container for creation-tools regarding this factory.
#
module IndividualRecordFactoryTools

  # Creates (and returns) an Array of IndividualRecord rows associated
  # to the specified swimmer, each with an unique event_type_id and
  # with record_type_id forced to 1 (= "personal best").
  #
  # If the swimmer instance is +nil+, a new swimmer will be created each time,
  # thus forcing the "personal best" list to become a list of completely
  # different IndividualRecord (this allows us to create random lists of
  # omogeneous records for diffent athletes, and test the results of any record grid
  # builder instance.)
  #
  def self.create_personal_best_list( swimmer = nil, row_count = 5 )
    list = []
    event_list = EventsByPoolType.only_for_meetings.not_relays.select([:event_type_id, :pool_type_id]).sort{ rand() - 0.5 }[ 0.. row_count-1 ]
    event_list.each do |event_by_pool_type|
      swimmer ||= FactoryBot.create(:swimmer)      # use a random swimmer if none is provided
      list << FactoryBot.create( :individual_record,
        swimmer_id: swimmer.id,
        meeting_individual_result: FactoryBot.create( :meeting_individual_result,
          swimmer_id: swimmer.id,
          meeting_program: FactoryBot.create( :meeting_program,
            meeting_event: FactoryBot.create( :meeting_event,
              meeting_session: FactoryBot.create( :meeting_session,
                swimming_pool: FactoryBot.create( :swimming_pool,
                  pool_type_id: event_by_pool_type.pool_type_id )
                ),
              event_type_id: event_by_pool_type.event_type_id ),
            gender_type_id: swimmer.gender_type_id
          )
        ),
        record_type_id: 1,
        event_type_id:  event_by_pool_type.event_type_id
      )
    end
    list
  end
end
#-- ---------------------------------------------------------------------------
#++
