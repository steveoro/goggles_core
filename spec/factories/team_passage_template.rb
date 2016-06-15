require 'ffaker'


FactoryGirl.define do

  factory :team_passage_template do
    team
    pool_type_id        { ((rand * 10) % 2).to_i + 1 }  # ASSERT: 25 and 50 meters type should exists
    event_type_id do
      EventsByPoolType.only_for_meetings
        .for_pool_type_code( pool_type_id == 1 ? '25' : '50' )
        .sort{ rand - 0.5 }[0]
        .event_type_id
    end
    passage_type        { PassageType.all.sort{ rand - 0.5 }[0] }
  end
  #-- -------------------------------------------------------------------------
  #++
end
