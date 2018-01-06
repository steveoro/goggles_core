# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :meeting_event_reservation do
    meeting               { Meeting.has_results.joins(:event_types).includes(:event_types).where('event_types.is_a_relay' => false).distinct.sort{ rand - 0.5 }[0] }
    team                  { badge.team }
    swimmer               { badge.swimmer }
    badge                 { Badge.all.sort{ rand - 0.5 }[0] }
    meeting_event         { meeting.meeting_events.are_not_relays.sort{ rand - 0.5 }[0] }
    user
    suggested_minutes     { ((rand * 2) % 2).to_i }
    suggested_seconds     { ((rand * 60) % 60).to_i }
    suggested_hundreds    { ((rand * 100) % 100).to_i }

    is_doing_this         true
  end
end
