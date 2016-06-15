# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :meeting_reservation do
    meeting               { Meeting.has_results.sort{ rand - 0.5 }[0] }
    team                  { badge.team }
    swimmer               { badge.swimmer }
    badge                 { Badge.all.sort{ rand - 0.5 }[0] }
    meeting_event         { meeting.meeting_events.all.sort{ rand - 0.5 }[0] }
    suggested_minutes     { ((rand * 2) % 2).to_i }
    suggested_seconds     { ((rand * 60) % 60).to_i }
    suggested_hundreds    { ((rand * 100) % 100).to_i }
    user
  end
end
